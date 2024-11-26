import { defineConfig } from "cypress"

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 5,
      openMode: 0,
    },
  },
})
