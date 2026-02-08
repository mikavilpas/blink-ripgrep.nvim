import { flavors } from "@catppuccin/palette"
import type { NeovimContext } from "../../support/tui-sandbox.js"
import { assertMatchVisible } from "./utils/assertMatchVisible"
import { createGitReposToLimitSearchScope } from "./utils/createGitReposToLimitSearchScope"

import {
  rgbify,
  textIsVisibleWithBackgroundColor,
  textIsVisibleWithColor,
} from "@tui-sandbox/library"
import { textIsVisibleWithColors } from "./utils/color-utils"
import { verifyCorrectBackendWasUsedInTest } from "./utils/verifyGitGrepBackendWasUsedInTest"

export type CatppuccinRgb = (typeof flavors.macchiato.colors)["surface0"]["rgb"]

type NeovimArguments = Parameters<typeof cy.startNeovim>[0]

function startNeovimWithGitBackend(
  options: Partial<NeovimArguments> = {},
): Cypress.Chainable<NeovimContext> {
  options.startupScriptModifications = options.startupScriptModifications ?? []

  const backend = "use_gitgrep_backend.lua"
  if (!options.startupScriptModifications.includes(backend)) {
    options.startupScriptModifications.push(backend)
  }

  assert(options.startupScriptModifications.includes(backend))
  return cy.startNeovim(options)
}

describe("the GitGrepBackend", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    startNeovimWithGitBackend().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // this will match text from ../../../test-environment/other-file.lua
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip")
      cy.contains(`Hippopotamus234 (rg)`) // wait for blink to show up
      cy.typeIntoTerminal("234")

      // should show documentation with more details about the match
      //
      // should show the text for the matched line
      //
      // the text should also be syntax highlighted
      textIsVisibleWithColor(
        "was my previous password",
        rgbify(flavors.macchiato.colors.green.rgb),
      )

      // should show the file name
      cy.contains(nvim.dir.contents["other-file.lua"].name)
    })
  })

  it("allows invoking manually as a blink-cmp keymap", () => {
    cy.visit("/")
    startNeovimWithGitBackend({
      startupScriptModifications: [
        "use_manual_mode.lua",
        // make sure this is tested somewhere. it doesn't really belong to this
        // specific test, but it should be tested 🙂
        "don't_use_debug_mode.lua",
      ],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // type some text that will match, but add a space so that we can make
      // sure the completion is not shown automatically (the previous word is
      // not found after a space)
      cy.typeIntoTerminal("hip {backspace}")

      // get back into position and invoke the completion manually
      cy.typeIntoTerminal("{control+g}")
      cy.contains(`Hippopotamus234 (rg)`)
    })
  })

  it("can use an underscore (_) to trigger blink completions", () => {
    cy.visit("/")
    startNeovimWithGitBackend().then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")
      cy.typeIntoTerminal("foo")
      // verify that a suggestion shows up, then cancel it with escape
      cy.contains("foo_bar")
      cy.typeIntoTerminal("{esc}")
      cy.contains("foo_bar").should("not.exist")

      // verify that the suggestion can be shown again by adding an underscore
      cy.typeIntoTerminal("a_")
      cy.contains("foo_bar")
    })
  })

  it("shows 5 lines around the match by default", () => {
    // The match context means the lines around the matched line.
    // We want to show context so that the user can see/remember where the match
    // was found. Although we don't explicitly show all the matches in the
    // project, this can still be very useful.
    cy.visit("/")
    startNeovimWithGitBackend().then(() => {
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

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

  it("can use git pathspecs to customize the search", () => {
    // git supports either tracked or untracked .gitattributes files to give
    // custom attributes to files. blink-ripgrep can use these attributes to
    // customize the search.
    //
    // - https://git-scm.com/docs/git-grep#Documentation/git-grep.txt-pathspec
    // - https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-pathspec

    cy.visit("/")
    startNeovimWithGitBackend({
      startupScriptModifications: [
        "gitgrep/ignore_files_with_gitattributes.lua",
      ],
    }).then(() => {
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      cy.typeIntoTerminal("cc")

      // find a match that has more than 5 lines of context
      cy.typeIntoTerminal("someText")

      // git-grep should have ignored files with the "blink-ripgrep-ignore"
      // attribute. The files with that attribute should not show up in the
      // search results.
      cy.contains("SomeTextFromFile3")
      cy.contains("someTextFromFile2").should("not.exist")
      cy.contains("myTextFromIgnoredDir").should("not.exist")
    })
  })

  it("can customize the icon in the completion results", () => {
    cy.visit("/")
    startNeovimWithGitBackend().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()
      cy.typeIntoTerminal("cc")

      // search for something to bring up the completions
      cy.typeIntoTerminal("hip")
      cy.contains("Hippopotamus123")

      {
        // initially the customization has not been applied in this test, so
        // the default icon should be visible
        const defaultIcon = "󰉿"
        textIsVisibleWithColor(
          defaultIcon,
          rgbify(flavors.macchiato.colors.green.rgb),
        )
      }

      // now enable customize_highlight_colors. This will change the icon on
      // the next invocation.
      nvim.doFile({
        luaFile: "config-modifications/enable_customize_icon_highlight.lua",
      })
      cy.typeIntoTerminal("{esc}cc")
      cy.contains("Hippopotamus123").should("not.exist")
      cy.typeIntoTerminal("hip")
      cy.contains("Hippopotamus123")

      // verify that the icon is BlinkCmpKindText (currently green) by default
      const icon = ""
      textIsVisibleWithColor(icon, rgbify(flavors.macchiato.colors.green.rgb))
      // customize_highlight_colors. Neovim is able to change this without
      // closing the blink completion menu, which is great.
      nvim.doFile({
        luaFile: "config-modifications/customize_highlight_colors.lua",
      })
      textIsVisibleWithColor(
        icon,
        rgbify(flavors.macchiato.colors.flamingo.rgb),
      )
    })
  })

  it("highlights multiple matches on the same line", () => {
    // https://github.com/mikavilpas/blink-ripgrep.nvim/issues/228
    cy.visit("/")
    startNeovimWithGitBackend({
      startupScriptModifications: ["disable_buffer_words_source.lua"],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // go to the end and start inserting on a new line
      cy.typeIntoTerminal("Go")

      cy.typeIntoTerminal("ban")
      cy.contains("banana_with_text") // wait for blink to show up results
      cy.typeIntoTerminal("w") // narrow down the results to banana_with_text only

      textIsVisibleWithColors(
        "banana_with_text",
        rgbify(flavors.macchiato.colors.base.rgb),
        rgbify(flavors.macchiato.colors.mauve.rgb),
      )
    })
  })

  afterEach(() => {
    verifyCorrectBackendWasUsedInTest("gitgrep")
  })
})

describe("in debug mode", () => {
  it("can execute the git debug command in a shell", () => {
    cy.visit("/")
    startNeovimWithGitBackend().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      cy.typeIntoTerminal("spa")
      cy.contains("spaceroni-macaroni")

      nvim.runExCommand({ command: "messages" }).then((result) => {
        // make sure the logged command can be run in a shell
        expect(result.value)
        cy.log(result.value ?? "")

        cy.nvim_runExCommand({ command: "term" })

        // get the current buffer name
        nvim.runExCommand({ command: "echo expand('%')" }).then((bufname) => {
          cy.log(bufname.value ?? "")
          expect(bufname.value).to.contain("term://")
        })

        // Quickly send the text over instead of typing it out. Cypress is a
        // bit slow when writing a lot of text.
        nvim.runLuaCode({
          luaCode: `vim.api.nvim_feedkeys([[${result.value}]], "n", true)`,
        })
        cy.typeIntoTerminal("{enter}")

        // The results will be 5-10 lines of jsonl.
        // Somewhere in the results, we should see the match, if the search was
        // successful.
        cy.contains(`spaceroni-macaroni`)
      })
    })
  })

  it("highlights the search word when a new search is started", () => {
    if (Cypress.expose("CI")) {
      cy.log("Skipping test in CI")
      return
    } else {
      cy.visit("/")
      startNeovimWithGitBackend().then((nvim) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")
        createGitReposToLimitSearchScope()

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
        textIsVisibleWithBackgroundColor(
          "hip",
          rgbify(flavors.macchiato.colors.flamingo.rgb),
        )
        //
        // blink is now in the Fuzzy(3) stage, and additional keypresses must not
        // start a new ripgrep search. They must be used for filtering the
        // results instead.
        // https://cmp.saghen.dev/development/architecture.html#architecture
        cy.contains(`Hippopotamus234 (rg)`) // wait for blink to show up
        cy.typeIntoTerminal("234")

        // wait for the highlight to disappear to test that too
        textIsVisibleWithBackgroundColor(
          "hip",
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
    }
  })

  afterEach(() => {
    cy.nvim_isRunning().then((isRunning) => {
      if (isRunning) {
        verifyCorrectBackendWasUsedInTest("gitgrep")
      } else {
        cy.log("Neovim is not running, skipping afterEach hook.")
      }
    })
  })
})
