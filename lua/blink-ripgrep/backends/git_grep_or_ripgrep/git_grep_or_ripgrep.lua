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

  -- use git to check if the current directory is a git repository
  local backend
  local job = vim.system({
    -- git allows checking if the current directory is a git repository this way
    "git",
    "rev-parse",
    "--is-inside-work-tree",
  }, {
    cwd = cwd,
  }, function(result)
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
  end)
  job:wait(1000)

  assert(
    backend,
    "GitGrepOrRipgrepBackend: Was unable to find the backend in " .. cwd
  )

  local cancellation_function = backend:get_matches(prefix, context, resolve)
  return cancellation_function
end

return GitGrepOrRipgrepBackend
