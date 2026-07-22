import packageConfig from "@mikavilpas/oxfmt-config"
import { defineConfig } from "oxfmt"

// oxlint-disable-next-line import/no-default-export
export default defineConfig({
  ...packageConfig,
  ignorePatterns: ["integration-tests/dist/", "pnpm-lock.yaml", ".repro", "CHANGELOG.md"],
})
