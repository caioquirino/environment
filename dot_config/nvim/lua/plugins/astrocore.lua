---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        clipboard = "unnamedplus",
        mousemoveevent = true,
        relativenumber = false,
      },
    },
    mappings = {
      n = {
        ["<C-p>"] = { function() require("snacks").picker.files() end, desc = "Find file" },
        ["<C-f>"] = { function() require("snacks").picker.lines() end, desc = "Find in file" },
        ["<C-h>"] = { function() require("snacks").picker.grep() end, desc = "Find in project" },
        ["<C-s>"] = { "<Cmd>w<CR>", desc = "Save" },
      },
      i = {
        ["<C-v>"] = { "<C-r>+", desc = "Paste" },
        ["<C-S-v>"] = { "<C-r>+", desc = "Paste" },
        ["<C-S-c>"] = { "<Esc>\"+ygi", desc = "Copy selection" },
        ["<S-Del>"] = { "<Del>", desc = "Delete selection" },
        ["<C-BS>"] = { "<C-w>", desc = "Delete word backward" },
        ["<C-z>"] = { "<C-o>u", desc = "Undo" },
        ["<C-s>"] = { "<Cmd>w<CR>", desc = "Save" },
        ["<C-a>"] = { "<Esc>ggVG", desc = "Select all" },
        ["<C-f>"] = { function() require("snacks").picker.lines() end, desc = "Find in file" },
        ["<C-p>"] = { function() require("snacks").picker.files() end, desc = "Find file" },
      },
      v = {
        ["<C-S-c>"] = { "\"+y", desc = "Copy" },
        ["<C-c>"] = { "\"+y", desc = "Copy" },
        ["<C-x>"] = { "\"+d", desc = "Cut" },
        ["<BS>"] = { "d", desc = "Delete selection" },
        ["<Del>"] = { "d", desc = "Delete selection" },
      },
    },
  },
}
