import { defineConfig } from "cypress"

const nvimAppName = process.env.NVIM_APPNAME ?? "nvim"

export default defineConfig({
  allowCypressEnv: false,
  expose: {
    NVIM_APPNAME: nvimAppName,
    CI: process.env.CI,
  },
  e2e: {
    baseUrl: "http://localhost:3000",
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 5,
      openMode: 0,
    },
  },
})
