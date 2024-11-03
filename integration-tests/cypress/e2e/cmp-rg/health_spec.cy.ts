describe("the healthcheck", () => {
  it("does not show any errors when ripgrep is installed", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(":checkhealth blink-cmp-rg{enter}")
      cy.contains("OK blink-cmp-rg")
    })
  })
})
