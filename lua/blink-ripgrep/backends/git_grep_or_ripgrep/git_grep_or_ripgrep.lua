---@module "blink.cmp"

---@class blink-ripgrep.GitGrepOrRipgrepBackend : blink-ripgrep.Backend
local GitGrepOrRipgrepBackend = {}

function GitGrepOrRipgrepBackend.new(config)
  local self = setmetatable({}, { __index = GitGrepOrRipgrepBackend })
  self.config = config
  return self --[[@as blink-ripgrep.GitGrepOrRipgrepBackend]]
end

function GitGrepOrRipgrepBackend:get_matches(prefix, context, resolve)
  local cwd = assert(vim.uv.cwd())

  if self.config.debug then
    require("blink-ripgrep.debug").add_debug_message(
      string.format(
        "GitGrepOrRipgrepBackend: Finding the backend in %s",
        vim.inspect(cwd)
      )
    )
  end

  local git_task = self:is_git_available(cwd)

  ---@param result vim.SystemCompleted
  git_task:map(function(result)
    -- use git to check if the current directory is a git repository
    local backend
    if result.code == 0 then
      backend =
        require("blink-ripgrep.backends.git_grep.git_grep").new(self.config)

      if self.config.debug then
        vim.schedule(function()
          require("blink-ripgrep.debug").add_debug_message(
            string.format(
              "GitGrepOrRipgrepBackend: Detected a git repository in '%s'. Using the git-grep backend",
              vim.inspect(cwd)
            )
          )
        end)
      end
    else
      backend =
        require("blink-ripgrep.backends.ripgrep.ripgrep").new(self.config)

      if self.config.debug then
        vim.schedule(function()
          require("blink-ripgrep.debug").add_debug_message(
            string.format(
              "GitGrepOrRipgrepBackend: No git repository in '%s'. Using the ripgrep backend",
              vim.inspect(cwd)
            )
          )
        end)
      end
    end

    assert(
      backend,
      "GitGrepOrRipgrepBackend: Was unable to find the backend in " .. cwd
    )

    GitGrepOrRipgrepBackend.schedule_if_needed(function()
      local cancellation_function =
        backend:get_matches(prefix, context, resolve)
      if cancellation_function then
        git_task:on_cancel(cancellation_function)
      end
    end)

    return nil
  end)

  return function()
    git_task:cancel()
  end
end

---@param cwd string
---@return blink.cmp.Task
function GitGrepOrRipgrepBackend:is_git_available(cwd)
  local task = require("blink.cmp.lib.async").task

  ---@type vim.SystemObj
  local job
  local gitjob = task.new(function(resolve)
    job = vim.system({
      -- git allows checking if the current directory is a git repository this way
      "git",
      "rev-parse",
      "--is-inside-work-tree",
    }, {
      cwd = cwd,
    }, resolve)
  end)
  gitjob:on_cancel(function()
    job:kill(9)
    if self.config.debug then
      require("blink-ripgrep.debug").add_debug_message(
        string.format(
          "GitGrepOrRipgrepBackend: Git job %s was cancelled",
          job.pid
        )
      )
    end
  end)

  return gitjob
end

-- from blink, lua/blink/cmp/lib/utils.lua
function GitGrepOrRipgrepBackend.schedule_if_needed(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

return GitGrepOrRipgrepBackend
