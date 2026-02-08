import { flavors } from "@catppuccin/palette"
import {
  rgbify,
  textIsVisibleWithBackgroundColor,
  textIsVisibleWithColor,
} from "@tui-sandbox/library"
import { z } from "zod"
import { assertMatchVisible } from "./utils/assertMatchVisible"
import { textIsVisibleWithColors } from "./utils/color-utils"
import { createGitReposToLimitSearchScope } from "./utils/createGitReposToLimitSearchScope"

describe("the RipgrepBackend", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
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

  it("does not search in ignore_paths", () => {
    // By default, the paths ignored via git and ripgrep are also automatically
    // ignored by blink-ripgrep.nvim, without any extra features (this is a
    // ripgrep feature). However, the user may want to ignore some paths from
    // blink-ripgrep.nvim specifically. Here we test that feature.
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/subproject/file1.lua",
      startupScriptModifications: ["ripgrep/set_ignore_paths.lua"],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("This is text from file1.lua")
      createGitReposToLimitSearchScope()
      const ignorePath = nvim.dir.rootPathAbsolute + "/limited"
      nvim.runLuaCode({
        luaCode: `_G.set_ignore_paths({ "${ignorePath}" })`,
      })

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")
      cy.contains("This is text from file1.lua").should("not.exist")

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

          const invocations = z
            .array(z.array(z.string()))
            .parse(result.value)[0]
          const invocation = invocations[0]
          expect(invocation).to.eql("ignored")
        })

      cy.contains(`Hippopotamus234 (rg)`).should("not.exist")
    })
  })

  it("shows 5 lines around the match by default", () => {
    // The match context means the lines around the matched line.
    // We want to show context so that the user can see/remember where the match
    // was found. Although we don't explicitly show all the matches in the
    // project, this can still be very useful.
    cy.visit("/")
    cy.startNeovim().then(() => {
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

  it("can use additional_paths to include additional files in the search", () => {
    // By default, ripgrep allows using gitignore files to exclude files from
    // the search. It works exactly like git does, and allows an intuitive way
    // to exclude files.
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/dir with spaces/file with spaces.txt",
      startupScriptModifications: ["ripgrep/use_additional_paths.lua"],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("this is file with spaces.txt")
      createGitReposToLimitSearchScope()
      cy.typeIntoTerminal("cc")

      // search for something that will be found in the additional words.txt file
      cy.typeIntoTerminal("abas")
      cy.contains("abased")
    })
  })

  it("can customize the icon in the completion results", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
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
      const icon = ""
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

  it("highlights multiple matches on the same line correctly", () => {
    // https://github.com/mikavilpas/blink-ripgrep.nvim/issues/228
    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: ["disable_buffer_words_source.lua"],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // go to the end and start inserting on a new line
      cy.typeIntoTerminal("Go")

      // check the match "banana_with_text"
      cy.typeIntoTerminal("ban")
      cy.contains("banana_with_text") // wait for blink to show up results
      cy.typeIntoTerminal("w") // narrow down the results to banana_with_text only

      textIsVisibleWithColors(
        "banana_with_text",
        rgbify(flavors.macchiato.colors.base.rgb),
        rgbify(flavors.macchiato.colors.mauve.rgb),
      )

      // check the other match, "banana"
      cy.typeIntoTerminal("{backspace}ana")
      textIsVisibleWithColors(
        "banana",
        rgbify(flavors.macchiato.colors.base.rgb),
        rgbify(flavors.macchiato.colors.mauve.rgb),
      )
      textIsVisibleWithColors(
        "banana_with_text",
        rgbify(flavors.macchiato.colors.text.rgb),
        rgbify(flavors.macchiato.colors.mantle.rgb),
      )
    })
  })
})

describe("in debug mode", () => {
  it("can execute the rg debug command in a shell", () => {
    cy.visit("/")
    cy.startNeovim({
      // also test that the plugin can handle spaces in the file path
      filename: "limited/dir with spaces/file with spaces.txt",
      startupScriptModifications: ["ripgrep/use_additional_paths.lua"],
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

        // The results will be 5-10 lines of jsonl.
        // Somewhere in the results, we should see the match, if the search was
        // successful.
        cy.contains(`spaceroni-macaroni`)

        // additional_paths should be used
        cy.contains("words.txt")
      })
    })
  })

  it("highlights the search word when a new search is started", () => {
    if (Cypress.expose("CI")) {
      cy.log("Skipping test in CI")
      return
    } else {
      cy.visit("/")
      cy.startNeovim({}).then((nvim) => {
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
})
