import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import { createFakeGitDirectoriesToLimitRipgrepScope } from "./createFakeGitDirectoriesToLimitRipgrepScope"

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

  it("shows 5 lines around the match by default", () => {
    // The match context means the lines around the matched line.
    // We want to show context so that the user can see/remember where the match
    // was found. Although we don't explicitly show all the matches in the
    // project, this can still be very useful.
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

  it("can use additional_paths to include additional files in the search", () => {
    // By default, ripgrep allows using gitignore files to exclude files from
    // the search. It works exactly like git does, and allows an intuitive way
    // to exclude files.
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/dir with spaces/file with spaces.txt",
      startupScriptModifications: ["use_additional_paths.lua"],
    }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("this is file with spaces.txt")
      createFakeGitDirectoriesToLimitRipgrepScope()
      cy.typeIntoTerminal("cc")

      // search for something that will be found in the additional words.txt file
      cy.typeIntoTerminal("abas")
      cy.contains("abased")
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
