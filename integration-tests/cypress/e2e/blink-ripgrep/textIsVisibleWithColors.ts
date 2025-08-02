import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import {
  textIsVisibleWithBackgroundColor,
  textIsVisibleWithColor,
} from "@tui-sandbox/library/dist/src/client/cypress-assertions"
import type { CatppuccinRgb } from "./backend_gitgrep_spec.cy"

function textIsVisibleWithColors(
  text: string,
  foregroundColor: CatppuccinRgb,
  backgroundColor: CatppuccinRgb,
) {
  textIsVisibleWithColor(text, rgbify(foregroundColor))

  return textIsVisibleWithBackgroundColor(text, rgbify(backgroundColor))
}
