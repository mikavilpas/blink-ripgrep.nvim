describe("the basics", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then(() => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal(
        // clear the current line and enter insert mode
        "cc",
      )

      // this will match "Hippopotamus123" from ../../../test-environment/other-file.txt
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal("hip")

      cy.contains("Hippopotamus123")
    })
  })
})
