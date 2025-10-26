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

export function createGitAttributesFile(): void {
  cy.nvim_runBlockingShellCommand({
    command: 'echo "*.log binary" > .gitattributes',
    cwdRelative: ".",
  })
  cy.nvim_runBlockingShellCommand({
    command: 'echo "*.log binary" > .gitattributes',
    cwdRelative: "limited",
  })
}
