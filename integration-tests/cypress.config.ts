import { defineConfig } from "cypress"

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    video: true,
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 5,
      openMode: 0,
    },
  },
})
