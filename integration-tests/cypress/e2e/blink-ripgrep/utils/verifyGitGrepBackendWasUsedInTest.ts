import { z } from "zod"

export function verifyCorrectBackendWasUsedInTest(
  backend: "gitgrep" | "ripgrep" | "gitgrep-or-ripgrep",
): void {
  cy.nvim_runLuaCode({
    luaCode: `return require("blink-ripgrep").config`,
  }).then((result) => {
    assert(result.value)
    const config = z
      .object({ backend: z.object({ use: z.string() }) })
      .safeParse(result.value)
    expect(config.error).to.be.undefined
    expect(config.data?.backend.use).to.equal(backend)
  })
}
