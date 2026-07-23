import mikaConfig from "@mikavilpas/oxlint-config"
import { defineConfig } from "oxlint"

// oxlint-disable-next-line import/no-default-export
export default defineConfig({
  extends: [mikaConfig],
  jsPlugins: [
    // https://github.com/levibuzolic/eslint-plugin-no-only-tests#oxlint
    "eslint-plugin-no-only-tests",
  ],
  env: {
    builtin: true,
    es2026: true,
  },
  ignorePatterns: [
    "**/vite.config.js",
    "**/cypress.config.ts",
    "**/test-environment/",
    "dist/",
    "cypress/support/tui-sandbox.ts",
  ],
  rules: {
    "no-only-tests/no-only-tests": "error",
  },
  overrides: [
    {
      files: ["cypress/e2e/blink-ripgrep/utils/*.ts", "cypress/e2e/blink-ripgrep/*.cy.ts"],
      rules: {
        "no-unused-expressions": "off",
      },
    },
    {
      files: ["cypress/e2e/blink-ripgrep/*.cy.ts"],
      // cypress knows how to import its own files
      rules: { "import/unambiguous": "allow" },
    },
  ],
})
