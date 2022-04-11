### warped.nvim

> ⚠️ THIS IS STILL VERY MUCH A WORK IN PROGRESS.
> While I work on automatic theme generation, for now only the Dracula theme is available.


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

```lua
-- simply call
require('warped').setup()
```

This will initiate the colorscheme for Warp's current theme and setup a file-watcher in the background to listen for changes to the preferences file, in which Warp stores it's current themes
> ⚠️ The Warp API is not yet stable, so this might break at any point.
