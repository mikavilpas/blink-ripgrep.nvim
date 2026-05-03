import { z } from "zod"
import type { MyNeovimAppName } from "../../../../MyTestDirectory.js"
import type {
  MyStartNeovimServerArguments,
  NeovimContext,
} from "../../../support/tui-sandbox.js"

const nvimAppNameSchema = z.enum([
  "nvim",
  "nvim_blink_nightly",
] satisfies MyNeovimAppName[])

export function startNeovim(
  opts: MyStartNeovimServerArguments = {},
): Cypress.Chainable<NeovimContext> {
  const appname = nvimAppNameSchema.parse(Cypress.expose("NVIM_APPNAME"))
  return cy.startNeovim({ NVIM_APPNAME: appname, ...opts })
}
