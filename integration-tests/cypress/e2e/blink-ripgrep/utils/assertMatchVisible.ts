import { flavors } from "@catppuccin/palette"
import { rgbify, textIsVisibleWithColor } from "@tui-sandbox/library"

export function assertMatchVisible(
  match: string,
  color?: typeof flavors.macchiato.colors.green.rgb,
): void {
  textIsVisibleWithColor(
    match,
    rgbify(color ?? flavors.macchiato.colors.green.rgb),
  )
}
