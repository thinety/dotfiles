local session_dir = vim.fn.stdpath("state") .. "/sessions/"
if vim.fn.isdirectory(session_dir) == 0 then
  vim.fn.mkdir(session_dir, "p")
end

local function get_session_file()
  local cwd = vim.fn.getcwd()
  local session_name = cwd:gsub("/", "%%")
  return session_dir .. session_name .. ".vim"
end

local function save_session()
  local session_file = get_session_file()
  vim.cmd.mksession({ bang = true, vim.fn.fnameescape(session_file) })
  vim.notify("Session was saved", vim.log.levels.INFO)
end

local function load_session()
  local session_file = get_session_file()
  if vim.fn.filereadable(session_file) == 0 then
    vim.notify("No session was found", vim.log.levels.WARN)
    return
  end
  vim.cmd.source({ vim.fn.fnameescape(session_file) })
  vim.notify("Session was loaded", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("SessionSave", save_session, {})
vim.api.nvim_create_user_command("SessionLoad", load_session, {})
