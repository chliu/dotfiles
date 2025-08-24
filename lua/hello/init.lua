local M = {}

function M.say_hello()
  vim.notify("Hello from your plugin!", vim.log.levels.INFO)
end

-- Create a command :Hello
vim.api.nvim_create_user_command("Hello", function()
  M.say_hello()
end, {})

return M
