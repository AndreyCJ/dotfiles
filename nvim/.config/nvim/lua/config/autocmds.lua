-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Delete leftover empty "[No Name]" buffers once a real file is opened
local function is_empty_buffer(buf)
  if vim.bo[buf].buftype ~= "" or vim.bo[buf].modified then
    return false
  end
  if vim.api.nvim_buf_get_name(buf) ~= "" then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Delete leftover empty [No Name] buffer when opening a file",
  callback = function()
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if is_empty_buffer(b.bufnr) and #vim.fn.win_findbuf(b.bufnr) == 0 then
        vim.api.nvim_buf_delete(b.bufnr, { force = true })
      end
    end
  end,
})
