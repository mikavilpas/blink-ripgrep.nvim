import type { NeovimContext } from "cypress/support/tui-sandbox"
import { createGitReposToLimitSearchScope } from "./utils/createGitReposToLimitSearchScope"
import { verifyCorrectBackendWasUsedInTest } from "./utils/verifyGitGrepBackendWasUsedInTest"

type NeovimArguments = Parameters<typeof cy.startNeovim>[0]

function startNeovimWithThisBackend(
  options?: Partial<NeovimArguments>,
): Cypress.Chainable<NeovimContext> {
  const backend = "use_gitgrep_or_ripgrep_backend.lua"

  if (!options) options = {}
  options.startupScriptModifications = options.startupScriptModifications ?? []

  if (!options.startupScriptModifications.includes(backend)) {
    options.startupScriptModifications.push(backend)
  }

  assert(options.startupScriptModifications.includes(backend))
  return cy.startNeovim(options)
}

describe("the GitGrepOrRipgrepBackend", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("/")
    startNeovimWithThisBackend().then((_) => {
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
    })
  })
})

afterEach(() => {
  verifyCorrectBackendWasUsedInTest("gitgrep-or-ripgrep")
})
