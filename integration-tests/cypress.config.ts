import { defineConfig } from "cypress"

const nvimAppName = process.env.NVIM_APPNAME ?? "nvim"

export default defineConfig({
  allowCypressEnv: false,
  expose: {
    NVIM_APPNAME: nvimAppName,
  },
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
