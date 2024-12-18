local blink_config = require("blink.cmp.config")

-- prevent showing completions automatically so that we can test invoking them
-- manually
blink_config.sources.default = { "buffer" }
