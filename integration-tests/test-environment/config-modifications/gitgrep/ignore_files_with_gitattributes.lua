-- git-grep can be configured to respect .gitattributes files for ignoring
-- files. For more information, see:
--
-- https://git-scm.com/docs/git-grep#Documentation/git-grep.txt-pathspec
-- https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-pathspec
require("blink-ripgrep").setup({
  backend = {
    gitgrep = {
      additional_gitgrep_options = {
        -- exclude files marked with the 'blink-ripgrep-ignore' attribute in
        -- .gitattributes
        ":(exclude,attr:blink-ripgrep-ignore)",
      },
    },
  },
})
