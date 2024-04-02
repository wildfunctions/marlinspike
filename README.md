# Marlinspike

![alt text](https://github.com/wildfunctions/images/blob/main/marlinspike.png)

## You Have Problems 
1. You have too many projects scattered across the file system.
2. You want a shortlist of projects that you are currently working on.

## We Have Solutions
1. A simple UI that lists all your projects.
2. Projects are listed in order by activity and recency.
3. Autoload projects from other plugins like harpoon. Only harpoon currently.

## Installation

* install using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "wildfunctions/marlinspike",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
}
```


## Custom Installation

```lua
{
    "wildfunctions/marlinspike",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      autoInit = false,
      useDefaultKeymaps = false,
      useGitRoot = false
    }
}
```


## Default Setup

These are the default keymaps:
```
<leader>ma : adds project to marlinspike list
<leader>mn : opens next marlinspike project in the list
<leader>me : toggles UI to select marlinspike project
```

Custom Keymaps can be set like the following code:
```lua
  vim.keymap.set("n", "<leader>ma", function() require("marlinspike").addProject() end, {noremap = true, silent = true})
  vim.keymap.set("n", "<leader>mn", function() require("marlinspike").loadNext() end, {noremap = true, silent = true})
  vim.keymap.set("n", "<leader>me", function() require("marlinspike").openMenu() end, {noremap = true, silent = true})
```


## Issues
Make an issue if you see anything that can be improved.
