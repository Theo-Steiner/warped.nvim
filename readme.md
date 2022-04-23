# warped.nvim

**warped.nvim** - keep your neovim's theme in sync with Warp (the awesome terminal).
Using colorbuddy.nvim (A straightforward theming plugin by tjdevries) and fwatch.nvim.


Colors for Warp's default themes are already bundled and your custom themes are parsed (and subsequently read from cache) just-in-time.


> ⚠️ Beware: Warp's API is not yet stable, so this plugin might break at any point.

## Installation && basic setup

```lua
-- using packer.nvim
use {
    'Theo-Steiner/warped.nvim', 
    require = {'tjdevries/colorbuddy.nvim', 'rktjmp/fwatch.nvim'},
    config = function()
        require('warped').setup()
    end
}
```

For an out-of-the-box experience, simply call the setup function with no additional configuration at some point after loading the plugin (e.g. in Packer's "config" hook as above)

```lua
-- simply call
require('warped').setup()
```


The ``Setup()`` will initiate a file-watcher in the background to listen for changes to your preferences file, in which Warp exposes the currently active theme. 


Whenever the file-watcher detects a change to this file, it will attempt to load the theme's colors and update the colorscheme to use those colors.

## Commands

Call ``:Warped`` to get information about the current theme loaded by warped.nvim.

``:WarpedApply`` is a way to manually trigger theme detection, if for any reason the file watcher did not register a change.

Warped.nvim generates themes just in time from the theme_name.yaml files in your "~/.warp/themes" directory and caches them in your file system.
You might want to hook into this process directly: 
``:WarpedClean`` - Clears the cache
For example you might want to clean the cache to get rid of themes you no longer have on your system...
``:WarpedGenerate`` - Generates and caches modules for all your themes
... or perhaps you notice that a theme went stale and you would like to regenerate it based on its .yaml file


<details>
<summary>Known issues</summary>
<ul>
<li>
Lualine caches the colors it uses, so a restart of vim is necessary before the new theme applies
</li>
<li>
File watching is not perfect, and sometimes this plugin misses out on a theme change. Simply restarting vim should help with that!
</li>
</ul>
</details>


## Advanced

The below code represents the default configuration that is applied if you call setup without any params:
```lua
Warped = require('warped')
Warped.setup({
    -- The onchange_callback is called whenever warped.nvim detects a theme change.
    -- @param theme_name: the theme's identifier as persisted by Warp
    -- @param theme_colors: a table of corresponding theme colors warp attempts to load (Can be nil)
    -- @param mapping: a table that provides a mapping from theme_colors to colorbuddy's theme
    -- @see mapping
    onchange_callback = function(theme_name, theme_colors, mapping)
        theme_colors = theme_colors or {}
        local active_mapping = mapping[theme_name] or mapping.default
        for vim_color, assigned_color in pairs(active_mapping) do
            local derived_color = theme_colors[assigned_color]
            if derived_color then
                Warped.Color.new(vim_color, derived_color or assigned_color)
            end
        end
    end,
    -- Mapping can be passed a table of colorbuddy's colors as keys and Warp theme's 16 ansi colors as values.
    -- The mapping is applied by the default onchange_callback or passed to your custom callback.
    mapping = {
        default = {
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
        }
    },
    -- If you want to customize colorbuddy's highlight groups etc you can do this here
    -- @params Color, colors, Group, groups, styles are described in more detail in colorbuddy.nvim's readme
    theme_config = function(Color, colors, Group, groups, styles)
        -- the defaults are to remove background colors so that warps background can shine through.
        Group.new("Normal", colors.none, colors.none)
        Group.new("VertSplit", colors.none, colors.none)
        Group.new("LineNr", colors.none, colors.none)
        Group.new("SignColumn", colors.none, colors.none)
    end,
})
```

### Provide a custom color mapping

To be completely honest with you, I arrived at the current default mapping by simple trial and error for what matched my aesthetics the most, with the themes I enjoy the most (Dracula and Solarized Dark).
Since this is obviously very subjective, I included a ``mapping`` option in the setup as an escape hatch.

There you can provide a table that maps the 16 ansi colors + ``bg: 'light' | 'dark'`` + Warps ``accent`` color to [colorbuddy's](https://github.com/tjdevries/colorbuddy.nvim) colors, on a *theme by theme basis* with the "default" mapping as the fallback.

I for example have a custom mapping for "gruvboxdark" in my setup because I think the highlighting color is really difficult to read otherwise:
```lua
local my_mapping = require("warped.default_mapping")
my_mapping["gruvboxdark"] = require("warped.utils").shallow_copy(my_mapping.default)
my_mapping.gruvboxdark.blue = "bright_magenta"

require("warped").setup({
	mapping = my_mapping,
})
```

### Customize the base-colorbuddy theme

Under the hood of warped.nvim, it is just colorbuddy.nvim running, so you really have fine grained control over what nvim looks like. 
I for example, like my cursor line to be highlighted by bold text, with no background color whatsoever:
```lua
require("warped").setup({
    theme_config = function(Color, colors, Group, groups, styles)
        -- Since I still want the background to be transparent, I call the default_theme_config first
        require("warped.default_theme_config")(Color, colors, Group, groups, styles)
        -- Then I make the modifications I want
        Group.new("CursorLine", colors.none, colors.none, styles.bold)
        Group.new("Folded", colors.none, colors.white)
    end
})
```


You also have complete control over colorbuddy itself, which is exposed as ``require('warped').colorbuddy`` and in combination with the ability to provide a custom callback, I hope you can find a config that really pleases your aesthetics!

> ``Warped.Color`` is just a wrapper around colorbuddy's ``Color``.

### Provide a custom callback

If you don't want to use colorbuddy for the colorschemes or want to do something different altogether, you can provide a custom ``onchange_callback`` during setup that is run whenever warped.nvim detects a change to the Warp's themes.

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

Apart from the ``theme_name``, you also have access to the theme's extracted ``theme_colors`` and perhaps less useful: the ``mapping``.

You should even be able to drop colorbuddy as a dependency completely if you don't use it in your callback, although beware as I did not test this yet.

## Contributing

This project is open to contributions!
