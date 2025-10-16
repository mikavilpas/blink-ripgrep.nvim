describe("the healthcheck", () => {
  it("does not show any errors when ripgrep is installed", () => {
    cy.visit("/")
    cy.startNeovim().then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(":checkhealth blink-ripgrep{enter}")
      cy.contains("rg found:")
      cy.contains("OK blink-ripgrep")
      cy.contains("WARN").should("not.exist")
    })
  })
})
