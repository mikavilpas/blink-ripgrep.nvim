import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { NeovimContext } from "cypress/support/tui-sandbox"
import { createGitReposToLimitSearchScope } from "./createGitReposToLimitSearchScope"
import { verifyGitGrepBackendWasUsedInTest } from "./verifyGitGrepBackendWasUsedInTest"

type NeovimArguments = Parameters<typeof cy.startNeovim>[0]

function startNeovimWithGitBackend(
  options: Partial<NeovimArguments>,
): Cypress.Chainable<NeovimContext> {
  if (!options) options = {}
  options.startupScriptModifications = options.startupScriptModifications ?? []
  if (!options.startupScriptModifications.includes("use_gitgrep_backend.lua")) {
    options.startupScriptModifications.push("use_gitgrep_backend.lua")
  }
  assert(options.startupScriptModifications.includes("use_gitgrep_backend.lua"))
  return cy.startNeovim(options)
}

describe("the GitGrepBackend", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    startNeovimWithGitBackend({}).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

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
      cy.contains("Hippopotamus" + "234 (rg)")
    })
  })

  it("can use an underscore (_) ca be used to trigger blink completions", () => {
    cy.visit("/")
    startNeovimWithGitBackend({}).then(() => {
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
    startNeovimWithGitBackend({}).then(() => {
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

  afterEach(() => {
    verifyGitGrepBackendWasUsedInTest()
  })
})

describe("in debug mode", () => {
  it("can execute the git debug command in a shell", () => {
    cy.visit("/")
    startNeovimWithGitBackend({}).then((nvim) => {
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

        // The results will be 5-10 lines of jsonl.
        // Somewhere in the results, we should see the match, if the search was
        // successful.
        cy.contains(`spaceroni-macaroni`)
      })
    })
  })

  it("highlights the search word when a new search is started", () => {
    cy.visit("/")
    startNeovimWithGitBackend({}).then((nvim) => {
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

  afterEach(() => {
    verifyGitGrepBackendWasUsedInTest()
  })
})
