import z from "zod"

export function verifyGitGrepBackendWasUsedInTest(): void {
  cy.nvim_runLuaCode({
    luaCode: `return require("blink-ripgrep").config`,
  }).then((result) => {
    assert(result.value)
    const config = z
      .object({ future_features: z.object({ backend: z.string() }) })
      .safeParse(result.value)
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    expect(config.error).to.be.undefined
    expect(config.data?.future_features.backend).to.equal("gitgrep")
  })
}
