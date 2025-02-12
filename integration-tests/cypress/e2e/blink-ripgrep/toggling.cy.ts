import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import { createFakeGitDirectoriesToLimitRipgrepScope } from "./createFakeGitDirectoriesToLimitRipgrepScope"

describe("toggling features on/off", () => {
  // Some features can be toggled on/off without restarting Neovim. This can be
  // useful to combat performance issues, for example.
  it("can toggle the plugin on/off in blink completions", () => {
    cy.visit("/")
    cy.startNeovim({
      filename: "limited/main-project-file.lua",
      startupScriptModifications: ["enable_toggling.lua"],
    }).then((nvim) => {
      // when completing from a file in a superproject, the search may descend
      // to subprojects
      cy.contains("this text is from main-project-file")
      createFakeGitDirectoriesToLimitRipgrepScope()

      // first verify that the plugin is enabled
      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      cy.contains("here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )

      cy.typeIntoTerminal("{esc}")

      // toggle the plugin off and wait for confirmation
      cy.typeIntoTerminal("{esc}")
      cy.typeIntoTerminal(" tg")
      cy.contains("Disabled **blink-ripgrep**")

      // try to complete again
      cy.typeIntoTerminal("ciw")
      cy.typeIntoTerminal("some")

      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          // ripgrep should only have been invoked once
          expect(result.value).to.be.an("array")
          const invocations = JSON.stringify(result.value)
          expect(invocations).to.contain("ignored-because-mode-is-off")
        })

      // toggle it back on
      cy.typeIntoTerminal("{esc}")
      cy.typeIntoTerminal(" tg")
      cy.contains("Enabled **blink-ripgrep**")

      // try to complete again and verify that the completion is there
      cy.typeIntoTerminal("ciw")
      cy.typeIntoTerminal("some")

      cy.contains("here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )
    })
  })
})
