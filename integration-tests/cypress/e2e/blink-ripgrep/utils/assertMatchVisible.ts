import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"

export function assertMatchVisible(
  match: string,
  color?: typeof flavors.macchiato.colors.green.rgb,
): void {
  cy.contains(match).should(
    "have.css",
    "color",
    rgbify(color ?? flavors.macchiato.colors.green.rgb),
  )
}
