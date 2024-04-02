# Marlinspike

## You Have Problems 
1. You have too many projects scattered across the file system.
2. You want a shortlist of projects that you are currently working on.

## We Have Solutions
1. A simple UI that lists all your projects.
2. A way to order the projects by activity and recency.
3. Autoload projects from other plugins like harpoon.

## Installation
* install using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "wildfunctions/marlinspike",
    dependencies = { "nvim-lua/plenary.nvim" }
}
```

## Default Setup

These are the default keymaps:
```
<leader>ma : adds project to marlinspike list
<leader>mn : opens next marlinspike project in the list
<leader>me : toggles UI to select marlinspike project
```
