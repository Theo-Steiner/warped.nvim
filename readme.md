### warped.nvim


> ⚠️ Warp's API is not yet stable, so this plugin might break at any point.

**warped.nvim** - keep your neovim in sync with Warp (the awesome terminal).

## Installation

```lua
-- using packer.nvim
use {
    'Theo-Steiner/warped.nvim', 
    require = {'tjdevries/colorbuddy.nvim', 'rktjmp/fwatch.nvim'}
}
```

## Setup

For an out-of-the-box experience, simply call the setup function with no additional configuration
```lua
-- simply call
require('warped').setup()
```

This will initiate a file-watcher in the background to listen for changes to your preferences file, in which Warp exposes the currently active theme. 
Whenever the file-watcher detects a change to this file, it will attempt to load the theme's colors and update the colorscheme to use those colors.
> ⚠️ Warp does not yet provide colors for its default themes, so colors will not update when selecting those themes.
<details>
<summary>random tips and pitfalls</summary>
<ul>
<li>
You can turn off background colors for nvim with this plugin, so that Warp's background-gradients and images can be seen.
```lua
vim.cmd([[
    hi Normal guifg=NONE guibg=NONE
    hi VertSplit gui=NONE guibg=NONE
    hi LineNr guibg=NONE guifg=NONE
    hi SignColumn guibg=NONE
]])
```
</li>
<li>
Lualine caches the colors it uses, so a restart of vim is necessary before the new theme applies
</li>
<li>
File watching is not perfect, and sometimes this plugin misses out on a theme change. Simply restarting vim should help with that!
</li>
</ul>
</details>


## Advanced

This is the default configuration that is applied if you call setup without any params:
```lua
Warped = require('warped')
Warped.setup({
    -- The onchange_callback is called whenever warped.nvim detects a theme change.
    -- @param theme_name: the theme's identifier as persisted by Warp
    -- @param theme_colors: a table of corresponding theme colors warp attempts to load (Can be nil)
    -- @param mapping: a table that provides a mapping from theme_colors to colorbuddy's theme
    -- @see mapping
    onchange_callback = function(theme_name, theme_colors, mapping)
        if theme_colors then
            -- loops through the mapping and updates colorbuddy's theme to use the theme's colors as specified
            for vim_color, assigned_color in pairs(mapping) do
                local derived_color = theme_colors[assigned_color]
                Warped.colorbuddy.Color.new(vim_color, derived_color or assigned_color)
            end
            -- applies the new colors and sets background to light for bright themes
            Warped.apply(theme_colors["bg"] == "light")
        end
    end,
    -- Mapping can be passed a table of colorbuddy's colors as keys and Warp theme's 16 ansi colors as values.
    -- The mapping is applied by the default onchange_callback or passed to your custom callback.
    mapping = {
        background = "background",
        foreground = "foreground",
        white = "normal_white",
        black = "normal_black",
        red = "normal_red",
        green = "bright_green",
        yellow = "normal_blue",
        blue = "normal_cyan",
        orange = "normal_yellow",
        aqua = "bright_blue",
        cyan = "normal_green",
        purple = "normal_magenta",
        violet = "bright_cyan",
        brown = "normal_white",
        seagree = "bright_red",
        turquoise = "bright_magenta",
        pink = "bright_yellow"
    },
    -- TODO: provide theme colors for themes that are not in Warp's theme repository
    extend_themes = {}
})
```

### Provide a Custom Color Mapping

To be completely honest with you, I arrived at the current default mapping by simple trial and error for what matched my aesthetics the most, with the themes I enjoy the most (Dracula and Solarized Dark).
Since this is obviously very subjective, I included a ``mapping`` param in the setup as an escape hatch.

There you can provide a table that maps the 16 ansi colors + ``bg: 'light' | 'dark'`` + Warps ``accent`` color to [colorbuddy's](https://github.com/tjdevries/colorbuddy.nvim) colors.

You also have complete control over Colorbuddy (A straightforward theming plugin by tjdevries) itself, which is exposed as ``require('warped').colorbuddy`` and in combination with the ability to provide a custom callback, I hope you can find a config that really pleases your aesthetics!

> ``Warped.apply(light: boolean)`` and ``Warped.Color`` are just convenient wrappers around colorbuddy's ``colorscheme()`` and ``Color`` respectively.

### Provide a Custom Callback
If you don't want to use colorbuddy for the colorschemes or want to do something different altogether, you can provide a custom callback that is run whenever warped.nvim detects a change to the Warp's themes.

Say you would want to use external matching themes, then the below custom callback would be a way to achieve this:
```lua
require('warped').setup({
    onchange_callback = function(theme_name)
        if theme_name == "dracula" then
            vim.command([[colorscheme dracula]])
        else
            vim.command([[colorscheme jellybeans]])
        end
    end
})
```
