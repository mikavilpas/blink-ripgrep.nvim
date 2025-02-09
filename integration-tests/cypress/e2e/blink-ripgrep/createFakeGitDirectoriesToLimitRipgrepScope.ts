import type { MyTestDirectoryFile } from "MyTestDirectory"

export function createFakeGitDirectoriesToLimitRipgrepScope(): void {
  cy.nvim_runExCommand({ command: `!mkdir $HOME/.git` }).then((result) => {
    expect(result.value).not.to.include("shell returned 1")
    expect(result.value).not.to.include("returned 1")
  })
  cy.nvim_runExCommand({
    command: `!mkdir $HOME/${"limited" satisfies MyTestDirectoryFile}/.git`,
  }).then((result) => {
    expect(result.value).not.to.include("shell returned 1")
    expect(result.value).not.to.include("returned 1")
  })
}
