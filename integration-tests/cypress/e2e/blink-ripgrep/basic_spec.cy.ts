import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { MyTestDirectoryFile } from "MyTestDirectory"

describe("the basics", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // this will match text from ../../../test-environment/other-file.lua
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip234")

      cy.contains("Hippopotamus" + "234 (rg)")

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
      cy.contains(dir.contents["other-file.lua"].name)
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

  describe("custom ripgrep options", () => {
    it("allows using a custom search_casing when searching", () => {
      cy.visit("/")
      cy.startNeovim({
        filename: "limited/subproject/file1.lua",
      }).then(() => {
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
        cy.runLuaCode({
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

function createFakeGitDirectoriesToLimitRipgrepScope() {
  cy.runExCommand({ command: `!mkdir %:h/.git` })
  cy.runExCommand({
    command: `!mkdir %:h/${"limited" satisfies MyTestDirectoryFile}/.git`,
  })
}
