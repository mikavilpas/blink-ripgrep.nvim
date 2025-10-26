import { createGitReposToLimitSearchScope } from "./utils/createGitReposToLimitSearchScope"
import { verifyCorrectBackendWasUsedInTest } from "./utils/verifyGitGrepBackendWasUsedInTest"

describe("debug mode", () => {
  it("can clean up (kill) a previous rg search", () => {
    // to save resources, the plugin should clean up a previous search when a
    // new search is started. Blink should handle this internally, see
    // https://github.com/mikavilpas/blink-ripgrep.nvim/issues/102

    cy.visit("/")
    cy.startNeovim({}).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // search for something that does not exist. This should start a couple
      // of searches
      cy.typeIntoTerminal("yyyyyy", { delay: 80 })
      nvim.runExCommand({ command: "messages" }).then((result) => {
        expect(result.value).to.contain(
          "killed previous RipgrepBackend invocation",
        )
      })
      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          expect(result.value).to.be.an("array")
          expect(result.value).to.have.length.above(2)
        })
    })
  })

  it("can clean up (kill) a previous git grep search", () => {
    // to save resources, the plugin should clean up a previous search when a
    // new search is started. Blink should handle this internally, see
    // https://github.com/mikavilpas/blink-ripgrep.nvim/issues/102

    cy.visit("/")
    cy.startNeovim({
      startupScriptModifications: ["use_gitgrep_backend.lua"],
    }).then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      createGitReposToLimitSearchScope()

      // clear the current line and enter insert mode
      cy.typeIntoTerminal("cc")

      // search for something that does not exist. This should start a couple
      // of searches
      cy.typeIntoTerminal("yyyyyy", { delay: 80 })
      nvim.runExCommand({ command: "messages" }).then((result) => {
        expect(result.value).to.contain(
          "killed previous GitGrepBackend invocation",
        )
      })
      nvim
        .runLuaCode({
          luaCode: `return _G.blink_ripgrep_invocations`,
        })
        .should((result) => {
          expect(result.value).to.be.an("array")
          expect(result.value).to.have.length.above(2)
        })

      verifyCorrectBackendWasUsedInTest("gitgrep")
    })
  })
})
