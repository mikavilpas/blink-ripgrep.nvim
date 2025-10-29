// this works for both GitGrepBackend and RipgrepBackend
export function createGitReposToLimitSearchScope(): void {
  cy.nvim_runBlockingShellCommand({
    command: "git init && git add . && git commit -m 'initial commit'",
    cwdRelative: ".",
  })
  cy.nvim_runBlockingShellCommand({
    command: "git init && git add . && git commit -m 'initial commit'",
    cwdRelative: "limited",
  })
}
