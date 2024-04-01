# Marlinspike

## The Problems
1. You have too many projects scattered across the file system.
2. You want a shortlist of projects that you are currently working on.

## The Solution
1. A simple UI that lists all your projects.
2. A way to order the projects by activity and recency.
3. Auto load projects from other plugins like harpoon.

## Installation
* install using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "wildfunctions/marlinspike",
    dependencies = { "nvim-lua/plenary.nvim" }
}
```

## Default Setup
```lua
<leader>ma : adds project to marlinspike list
<leader>mn : opens next project in the list
```
