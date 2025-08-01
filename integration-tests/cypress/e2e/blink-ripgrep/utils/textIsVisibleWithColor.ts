import { rgbify } from "@tui-sandbox/library/dist/src/client/color-utilities"
import type { CatppuccinRgb } from "../backend_gitgrep_spec.cy"

/** Problem: cypress provides the `contains` method, but it only checks the
 * first match on the page.
 *
 * Solution: we need to check all elements on the page and filter them
 * by the text we are looking for. Then we can check if the background
 * color of the element is the same as the one we are looking for.
 */

export function textIsVisibleWithColor(
  text: string,
  color: CatppuccinRgb,
): Cypress.Chainable<JQuery> {
  return cy.get("div.xterm-rows span").and(($spans) => {
    const matching = $spans.filter((_, el) => !!el.textContent.includes(text))

    const colors = matching.map((_, el) => {
      return window.getComputedStyle(el).color
    })

    expect(JSON.stringify(colors.toArray())).to.contain(rgbify(color))
  })
}
