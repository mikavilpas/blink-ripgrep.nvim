# Tutorial: ignoring Files from `git grep`

> As a developer, when using `git grep` to search through my codebase, I want to
> ignore certain files or directories.
>
> Maybe they contain non-useful information that still needs to be tracked with
> git, or maybe the files are too large and slow down the search.

git-grep can be configured to respect `.gitattributes` files for ignoring files.
To do it, follow these steps:

1. Create or edit a `.gitattributes` file in the root of your git repository.
   Add patterns for the files/directories you want to ignore. Example:

   ```gitattributes
   # ignore the following from blink-ripgrep by giving them a specific attribute
   # that we then ignore in the git grep command.
   #
   # The name of the attribute does not matter and can be chosen by the user.
   subproject/file2.lua blink-ripgrep-ignore
   ```

2. Configure `blink-ripgrep` to pass the appropriate options to `git grep` to
   ignore files with the specified attribute:

   ```lua
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
   ```

## Resources

- <https://git-scm.com/docs/git-grep#Documentation/git-grep.txt-pathspec>
- <https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-pathspec>
- tests
  - [test gitattributes configuration](../integration-tests/test-environment/config-modifications/gitgrep/ignore_files_with_gitattributes.lua)
  - [test gitattributes](../integration-tests/test-environment/limited/.gitattributes)
