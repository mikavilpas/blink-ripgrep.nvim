import { flavors } from "@catppuccin/palette"
import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import { textIsVisibleWithColor } from "@tui-sandbox/library/dist/src/client/cypress-assertions"

export function assertMatchVisible(
  match: string,
  color?: typeof flavors.macchiato.colors.green.rgb,
): void {
  textIsVisibleWithColor(
    match,
    rgbify(color ?? flavors.macchiato.colors.green.rgb),
  )
}
