-- Open the file tree when Neovim is started on a directory.
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.schedule(function()
        if vim.bo.filetype ~= "neo-tree" then vim.cmd.Neotree "show" end
      end)
    end
  end,
})

-- Stay on the real Gradle root. Nested agent worktrees have their own
-- settings file and fail import, which leaves the language server with no classpath.
vim.lsp.config("kotlin_language_server", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "settings.gradle.kts", "settings.gradle" })
    if root and not root:find("/.claude/worktrees/", 1, true) then on_dir(root) end
  end,
})
