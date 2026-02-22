import { flavors } from "@catppuccin/palette"
import {
  rgbify,
  textIsVisibleWithBackgroundColor,
  textIsVisibleWithColor,
} from "@tui-sandbox/library"
import type { MyTestDirectoryFile } from "../../../MyTestDirectory"
import { createGitReposToLimitSearchScope } from "./utils/createGitReposToLimitSearchScope"

describe("searching inside projects with the RipgrepBackend", () => {
  // NOTE: the tests setup git repositories in the test environment using
  // ../../../server/server.ts
  //
  // This limits the search to the nearest .git directory above the current
  // file.
  it("descends into subprojects", () => {
    cy.visit("/")
    cy.startNeovim({ filename: "limited/main-project-file.lua" }).then(() => {
      // when completing from a file in a superproject, the search may descend
      // to subprojects
      cy.contains("this text is from main-project-file")
      createGitReposToLimitSearchScope()

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      textIsVisibleWithColor("here", rgbify(flavors.macchiato.colors.green.rgb))
    })
  })

  it("limits the search to the nearest .git directory", () => {
    cy.visit("/")
    cy.startNeovim({ filename: "limited/subproject/file1.lua" }).then(() => {
      // when opening a file from a subproject, the search should be limited to
      // the nearest .git directory (only the files in the same project should
      // be searched)
      cy.contains("This is text from file1.lua")
      createGitReposToLimitSearchScope()

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      textIsVisibleWithColor("here", rgbify(flavors.macchiato.colors.green.rgb))
    })
  })

  it("does not search if the project root is not found", () => {
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/subproject/file1.lua",
      startupScriptModifications: [
        "use_not_found_project_root.lua",
        "ripgrep/disable_project_root_fallback.lua",
      ],
    }).then((nvim) => {
      // when opening a file from a subproject, the search should be limited to
      // the nearest .git directory (only the files in the same project should
      // be searched)
      cy.contains("This is text from file1.lua")
      createGitReposToLimitSearchScope()

      // make sure the preconditions for this case are met
      nvim.waitForLuaCode({
        luaAssertion: `assert(require("blink-ripgrep").config.backend.ripgrep.project_root_fallback == false)`,
      })

      // search for something that was found in the previous test (so we know
      // it should be found)
      cy.typeIntoTerminal("cc")
      cy.typeIntoTerminal("some")

      // because the project root is not found, the search should not have
      // found anything
      cy.contains("here").should("not.exist")

      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          expect(result.value).to.eql([
            ["ignored-because-no-command"],
            ["ignored-because-no-command"],
          ])
        })

      nvim.runExCommand({ command: "messages" }).then((result) => {
        // make sure the search was logged to be skipped due to not finding the
        // root directory, etc. basically we want to double check it was
        // skipped for this exact reason and not due to some other possible
        // bug
        expect(result.value).to.contain(
          "no command returned, skipping the search",
        )
      })
    })
  })

  describe("custom ripgrep options", () => {
    it("allows using a custom search_casing when searching", () => {
      cy.visit("/")
      cy.startNeovim({
        filename: "limited/subproject/file1.lua",
      }).then((nvim) => {
        cy.contains("This is text from file1.lua")
        createGitReposToLimitSearchScope()

        // the default is to use --ignore-case. Let's make sure that works first
        cy.typeIntoTerminal("o")
        cy.typeIntoTerminal("{esc}cc")
        cy.typeIntoTerminal("sometext")
        // the search should match in both casings
        cy.contains("someTextFromFile2")
        cy.contains("SomeTextFromFile3")

        // now switch to using --smart-case, which should be case sensitive
        // when uppercase letters are used
        nvim.runLuaCode({
          luaCode: `vim.cmd("luafile ${"config-modifications/ripgrep/use_case_sensitive_search.lua" satisfies MyTestDirectoryFile}")`,
        })
        cy.typeIntoTerminal("{esc}cc")
        // type something that does not match
        cy.typeIntoTerminal("SomeText")

        // the search should only match the case sensitive version
        cy.contains("SomeTextFromFile3")
        cy.contains("someTextFromFile2").should("not.exist")
      })
    })
  })

  it("can highlight the match in the documentation window", () => {
    cy.visit("/")
    cy.startNeovim({ filename: "limited/subproject/file1.lua" }).then(() => {
      // When a match has been found in a file in the project, the
      // documentation window should show a preview of the match context (lines
      // around the match), and highlight the part where the match was found.
      // This way the user can quickly get an idea of where the match was
      // found.
      cy.contains("This is text from file1.lua")
      createGitReposToLimitSearchScope()

      cy.typeIntoTerminal("o")
      // match text inside ../../../test-environment/limited/subproject/example.clj
      cy.typeIntoTerminal("Subtraction")

      // we should see the match highlighted with the configured color
      // somewhere on the page (in the documentation window)
      textIsVisibleWithBackgroundColor(
        "Subtraction",
        rgbify(flavors.macchiato.colors.mauve.rgb),
      )
    })
  })

  describe("regex based syntax highlighting", () => {
    it("can highlight file types that don't have a treesitter parser installed", () => {
      cy.visit("/")
      cy.startNeovim({ filename: "limited/subproject/file1.lua" }).then(() => {
        // when opening a file from a subproject, the search should be limited to
        // the nearest .git directory (only the files in the same project should
        // be searched)
        cy.contains("This is text from file1.lua")
        createGitReposToLimitSearchScope()

        cy.typeIntoTerminal("o")
        // match text inside ../../../test-environment/limited/subproject/example.clj
        cy.typeIntoTerminal("Subtraction")

        // make sure the syntax is highlighted
        // (needs https://github.com/Saghen/blink.cmp/pull/462)
        textIsVisibleWithColor(
          "defn",
          rgbify(flavors.macchiato.colors.pink.rgb),
        )
        textIsVisibleWithColor(
          "Clojure Calculator",
          rgbify(flavors.macchiato.colors.green.rgb),
        )

        // hide the documentation and reshow it to make sure the syntax is
        // still highlighted
        cy.typeIntoTerminal("{control} ")
        cy.contains("Clojure Calculator").should("not.exist")

        cy.typeIntoTerminal("{control} ")
        textIsVisibleWithColor(
          "Clojure Calculator",
          rgbify(flavors.macchiato.colors.green.rgb),
        )
      })
    })

    it("can disable regex based highlighting altogether", () => {
      // This is a regression test for https://github.com/mikavilpas/blink-ripgrep.nvim/issues/598
      cy.visit("/")
      cy.startNeovim({
        filename: "limited/subproject/file1.lua",
        startupScriptModifications: [
          "disable_highlighting_fallback_to_regex.lua",
        ],
      }).then(() => {
        // when opening a file from a subproject, the search should be limited to
        // the nearest .git directory (only the files in the same project should
        // be searched)
        cy.contains("This is text from file1.lua")
        createGitReposToLimitSearchScope()

        cy.typeIntoTerminal("o")
        cy.typeIntoTerminal("samp") // match "samplelogmessage"

        // make sure the match is shown
        cy.contains("samplelogmessage")

        // make sure the documentation window shows up by detecting the
        // filename of the matched file
        cy.contains("testlog.log")
      })
    })
  })

  describe("using .gitignore files to exclude files from searching", () => {
    it("shows words in other files as suggestions", () => {
      // By default, ripgrep allows using gitignore files to exclude files from
      // the search. It works exactly like git does, and allows an intuitive way
      // to exclude files.
      cy.visit("/")
      cy.startNeovim({
        filename: "limited/dir with spaces/file with spaces.txt",
      }).then((nvim) => {
        // wait until text on the start screen is visible
        cy.contains("this is file with spaces.txt")
        createGitReposToLimitSearchScope()
        cy.typeIntoTerminal("cc")

        // first, make sure that a file is included (so we can make sure it can
        // be hidden, next)
        cy.typeIntoTerminal("spaceroni")
        cy.contains("spaceroni-macaroni")

        // add a .gitignore file that ignores the file we just searched for. This
        // should cause the file to not show up in the search results.
        nvim
          .runExCommand({
            command: `!echo "dir with spaces/other file with spaces.txt" > $HOME/limited/.gitignore`,
          })
          .then((result) => {
            expect(result.value).not.to.include("shell returned 1")
            expect(result.value).not.to.include("returned 1")
          })

        // clear the buffer and repeat the search
        cy.typeIntoTerminal("{esc}ggVGc")
        cy.typeIntoTerminal("spaceroni")
        cy.contains("spaceroni-macaroni").should("not.exist")
      })
    })
  })
})
