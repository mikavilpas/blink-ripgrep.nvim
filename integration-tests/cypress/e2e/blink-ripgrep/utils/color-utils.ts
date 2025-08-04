import {
  textIsVisibleWithBackgroundColor,
  textIsVisibleWithColor,
} from "@tui-sandbox/library/dist/src/client/cypress-assertions"

export function textIsVisibleWithColors(
  text: string,
  foregroundColor: string,
  backgroundColor: string,
): void {
  textIsVisibleWithColor(text, foregroundColor)
  textIsVisibleWithBackgroundColor(text, backgroundColor)
}
