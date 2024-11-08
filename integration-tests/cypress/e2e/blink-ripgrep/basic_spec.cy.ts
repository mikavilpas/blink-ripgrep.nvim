import { flavors } from "@catppuccin/palette"

export function rgbify(
  color: (typeof flavors.macchiato.colors)["surface0"]["rgb"],
): string {
  return `rgb(${color.r.toString()}, ${color.g.toString()}, ${color.b.toString()})`
}

describe("the basics", () => {
  it("shows words in other files as suggestions", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal(
        // clear the current line and enter insert mode
        "cc",
      )

      // this will match text from ../../../test-environment/other-file.txt
      //
      // If the plugin works, this text should show up as a suggestion.
      cy.typeIntoTerminal(
        // NOTE: need to break it into parts so that this test file itself does
        // not match the search :)
        "hip" + "234",
      )

      cy.contains("Hippopotamus" + "234 (rg)")

      // should show documentation with more details about the match
      //
      // should show the text for the matched line
      //
      // the text should also be syntax highlighted
      cy.contains("Hippopotamus" + "234 was my previous password").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )

      // should show the file name
      cy.contains(dir.contents["other-file.lua"].name)
    })
  })
})

describe("searching inside projects", () => {
  // NOTE: the tests setup fake git repositories in the test environment using
  // ../../../server/server.ts
  //
  // This limits the search to the nearest .git directory above the current
  // file.
  it("descends into subprojects", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({ filename: "limited/main-project-file.lua" }).then(() => {
      // when completing from a file in a superproject, the search may descend
      // to subprojects
      cy.contains("this text is from main-project-file")

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      cy.contains("someTextFromFile2 here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )
    })
  })

  it("limits the search to the nearest .git directory", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({ filename: "limited/subproject/file1.lua" }).then(() => {
      // when opening a file from a subproject, the search should be limited to
      // the nearest .git directory (only the files in the same project should
      // be searched)
      cy.contains("This is text from file1.lua")

      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("some")

      cy.contains("someTextFromFile2 here").should(
        "have.css",
        "color",
        rgbify(flavors.macchiato.colors.green.rgb),
      )
    })
  })
})
