import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { MyTestDirectoryFile } from "MyTestDirectory"

describe("the basics", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // this will match text from ../../../test-environment/other-file.lua
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip")
      cy.contains("Hippopotamus" + "234 (rg)") // wait for blink to show up
      cy.typeIntoTerminal("234")

      // should show documentation with more details about the match
      //
      // should show the text for the matched line
      //
      // the text should also be syntax highlighted
      cy.contains("was my previous password").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )

      // should show the file name
      cy.contains(nvim.dir.contents["other-file.lua"].name)
    })
  })

  it("allows invoking manually as a blink-cmp keymap", () => {
    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: [
        "use_manual_mode.lua",
        // make sure this is tested somewhere. it doesn't really belong to this
        // specific test, but it should be tested 🙂
        "don't_use_debug_mode.lua",
      ],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // type some text that will match, but add a space so that we can make
      // sure the completion is not shown automatically (the previous word is
      // not found after a space)
      cy.typeIntoTerminal("hip {backspace}")

      // get back into position and invoke the completion manually
      cy.typeIntoTerminal("{control+g}")
      cy.contains("Hippopotamus" + "234 (rg)")
    })
  })

  it("does not search in ignore_paths", () => {
    // By default, the paths ignored via git and ripgrep are also automatically
    // ignored by blink-ripgrep.nvim, without any extra features (this is a
    // ripgrep feature). However, the user may want to ignore some paths from
    // blink-ripgrep.nvim specifically. Here we test that feature.
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/subproject/file1.lua",
      startupScriptModifications: ["set_ignore_paths.lua"],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("This is text from file1.lua")
      createFakeGitDirectoriesToLimitRipgrepScope()
      const ignorePath = nvim.dir.rootPathAbsolute + "/limited"
      nvim.runLuaCode({
        luaCode: `_G.set_ignore_paths({ "${ignorePath}" })`,
      })

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // this will match text from ../../../test-environment/other-file.lua
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip")

      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          // ripgrep should only have been invoked once
          expect(result.value).to.be.an("array")
          expect(result.value).to.have.length(1)

          const invocations = (result.value as string[][])[0]
          const invocation = invocations[0]
          expect(invocation).to.eql("ignored")
        })

      cy.contains("Hippopotamus" + "234 (rg)").should("not.exist")
    })
  })
})

describe("the match context", () => {
  // The match context means the lines around the matched line.
  // We want to show context so that the user can see/remember where the match
  // was found. Although we don't explicitly show all the matches in the
  // project, this can still be very useful.
  it("shows 5 lines around the match by default", () => {
    cy.visit("/")
    cy.startNeovim().then(() => {
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      cy.typeIntoTerminal("cc")

      // find a match that has more than 5 lines of context
      cy.typeIntoTerminal("line_7")

      // we should now see lines 2-12 (default 5 lines of context around the match)
      cy.contains(`"This is line 1"`).should("not.exist")
      assertMatchVisible(`"This is line 2"`)
      assertMatchVisible(`"This is line 3"`)
      assertMatchVisible(`"This is line 4"`)
      assertMatchVisible(`"This is line 5"`)
      assertMatchVisible(`"This is line 6"`)
      assertMatchVisible(`"This is line 7"`) // the match
      assertMatchVisible(`"This is line 8"`)
      assertMatchVisible(`"This is line 9"`)
      assertMatchVisible(`"This is line 10"`)
      assertMatchVisible(`"This is line 11"`)
      assertMatchVisible(`"This is line 12"`)
      cy.contains(`"This is line 13"`).should("not.exist")
    })
  })

  function assertMatchVisible(
    match: string,
    color?: typeof flavors.macchiato.colors.green.rgb,
  ) {
    cy.contains(match).should(
      "have.css",
      "color",
      rgbify(color ?? flavors.macchiato.colors.green.rgb),
    )
  }
})

describe("searching inside projects", () => {
  // NOTE: the tests setup fake git repositories in the test environment using
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
      createFakeGitDirectoriesToLimitRipgrepScope()

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      cy.contains("here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )
    })
  })

  it("limits the search to the nearest .git directory", () => {
    cy.visit("/")
    cy.startNeovim({ filename: "limited/subproject/file1.lua" }).then(() => {
      // when opening a file from a subproject, the search should be limited to
      // the nearest .git directory (only the files in the same project should
      // be searched)
      cy.contains("This is text from file1.lua")
      createFakeGitDirectoriesToLimitRipgrepScope()

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      cy.contains("here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )
    })
  })

  it("does not search if the project root is not found", () => {
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/subproject/file1.lua",
      startupScriptModifications: [
        "use_not_found_project_root.lua",
        "disable_project_root_fallback.lua",
      ],
    }).then((nvim) => {
      // when opening a file from a subproject, the search should be limited to
      // the nearest .git directory (only the files in the same project should
      // be searched)
      cy.contains("This is text from file1.lua")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // make sure the preconditions for this case are met
      nvim.runLuaCode({
        luaCode: `assert(require("blink-ripgrep").config.project_root_fallback == false)`,
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
        createFakeGitDirectoriesToLimitRipgrepScope()

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
          luaCode: `vim.cmd("luafile config-modifications/use_case_sensitive_search.lua")`,
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
      createFakeGitDirectoriesToLimitRipgrepScope()

      cy.typeIntoTerminal("o")
      // match text inside ../../../test-environment/limited/subproject/example.clj
      cy.typeIntoTerminal("Subtraction")

      // we should see the match highlighted with the configured color
      // somewhere on the page (in the documentation window)
      cy.get("span")
        .filter((_, el) => el.textContent?.includes("Subtraction") ?? false)
        .then((elements) => {
          const matchingElements = elements.map((_, el) => {
            return window.getComputedStyle(el).backgroundColor
          })

          return matchingElements.toArray()
        })
        .should("contain", rgbify(flavors.macchiato.colors.mauve.rgb))
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
        createFakeGitDirectoriesToLimitRipgrepScope()

        cy.typeIntoTerminal("o")
        // match text inside ../../../test-environment/limited/subproject/example.clj
        cy.typeIntoTerminal("Subtraction")

        // make sure the syntax is highlighted
        // (needs https://github.com/Saghen/blink.cmp/pull/462)
        cy.contains("defn").should(
          "have.css",
          "color",
          rgbify(flavors.macchiato.colors.pink.rgb),
        )
        cy.contains("Clojure Calculator").should(
          "have.css",
          "color",
          rgbify(flavors.macchiato.colors.green.rgb),
        )

        // hide the documentation and reshow it to make sure the syntax is
        // still highlighted
        cy.typeIntoTerminal("{control} ")
        cy.contains("Clojure Calculator").should("not.exist")

        cy.typeIntoTerminal("{control} ")
        cy.contains("Clojure Calculator").should(
          "have.css",
          "color",
          rgbify(flavors.macchiato.colors.green.rgb),
        )
      })
    })
  })
})

describe("debug mode", () => {
  it("can execute the debug command in a shell", () => {
    cy.visit("/")
    cy.startNeovim({
      // also test that the plugin can handle spaces in the file path
      filename: "limited/dir with spaces/file with spaces.txt",
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("this is file with spaces.txt")
      nvim.runExCommand({ command: `!mkdir "%:h/.git"` })

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      cy.typeIntoTerminal("spa")
      cy.contains("spaceroni-macaroni")

      nvim.runExCommand({ command: "messages" }).then((result) => {
        // make sure the logged command can be run in a shell
        expect(result.value)
        cy.log(result.value ?? "")

        cy.typeIntoTerminal("{esc}:term{enter}", { delay: 3 })

        // get the current buffer name
        nvim.runExCommand({ command: "echo expand('%')" }).then((bufname) => {
          cy.log(bufname.value ?? "")
          expect(bufname.value).to.contain("term://")
        })

        // start insert mode
        cy.typeIntoTerminal("a")

        // Quickly send the text over instead of typing it out. Cypress is a
        // bit slow when writing a lot of text.
        nvim.runLuaCode({
          luaCode: `vim.api.nvim_feedkeys([[${result.value}]], "n", true)`,
        })
        cy.typeIntoTerminal("{enter}")

        // The results will lbe 5-10 lines of jsonl.
        // Somewhere in the results, we should see the match, if the search was
        // successful.
        cy.contains(`spaceroni-macaroni`)
      })
    })
  })

  it("highlights the search word when a new ripgrep search is started", () => {
    cy.visit("/")
    cy.startNeovim({}).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // debug mode should be on by default for all tests. Otherwise it doesn't
      // make sense to test this, as nothing will be displayed.
      nvim.runLuaCode({
        luaCode: `assert(require("blink-ripgrep").config.debug)`,
      })

      // this will match text from ../../../test-environment/other-file.lua
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip")
      // the search should have been started for the prefix "hip"
      cy.contains("hip").should(
        "have.css",
        "backgroundColor",
        rgbify(flavors.macchiato.colors.flamingo.rgb),
      )
      //
      // blink is now in the Fuzzy(3) stage, and additional keypresses must not
      // start a new ripgrep search. They must be used for filtering the
      // results instead.
      // https://cmp.saghen.dev/development/architecture.html#architecture
      cy.contains("Hippopotamus" + "234 (rg)") // wait for blink to show up
      cy.typeIntoTerminal("234")

      // wait for the highlight to disappear to test that too
      cy.contains("hip").should(
        "have.css",
        "backgroundColor",
        rgbify(flavors.macchiato.colors.base.rgb),
      )

      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          // ripgrep should only have been invoked once
          expect(result.value).to.be.an("array")
          expect(result.value).to.have.length(1)
        })
    })
  })

  it("can clean up (kill) a previous rg search", () => {
    // to save resources, the plugin should clean up a previous search when a
    // new search is started. Blink should handle this internally, see
    // https://github.com/mikavilpas/blink-ripgrep.nvim/issues/102

    cy.visit("/")
    cy.startNeovim({}).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // debug mode should be on by default for all tests. Otherwise it doesn't
      // make sense to test this, as nothing will be displayed.
      nvim.runLuaCode({
        luaCode: `assert(require("blink-ripgrep").config.debug)`,
      })

      // search for something that does not exist. This should start a couple
      // of searches
      cy.typeIntoTerminal("yyyyyy", { delay: 80 })
      nvim.runExCommand({ command: "messages" }).then((result) => {
        expect(result.value).to.contain("killed previous invocation")
      })
      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          expect(result.value).to.be.an("array")
          expect(result.value).to.have.length.above(3)
        })
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
      createFakeGitDirectoriesToLimitRipgrepScope()
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

function createFakeGitDirectoriesToLimitRipgrepScope() {
  cy.nvim_runExCommand({ command: `!mkdir $HOME/.git` }).then((result) => {
    expect(result.value).not.to.include("shell returned 1")
    expect(result.value).not.to.include("returned 1")
  })
  cy.nvim_runExCommand({
    command: `!mkdir $HOME/${"limited" satisfies MyTestDirectoryFile}/.git`,
  }).then((result) => {
    expect(result.value).not.to.include("shell returned 1")
    expect(result.value).not.to.include("returned 1")
  })
}
