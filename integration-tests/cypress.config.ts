import { defineConfig } from "cypress"

export default defineConfig({
  allowCypressEnv: false,
  e2e: {
    baseUrl: "http://localhost:3000",
    experimentalRunAllSpecs: true,
    env: {
      // make the CI environment variable available to cypress
      // https://docs.cypress.io/app/references/environment-variables#Option-1-configuration-file
      CI: process.env.CI,
    },
    retries: {
      runMode: 5,
      openMode: 0,
    },
  },
})
