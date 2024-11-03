import { defineConfig } from "cypress"
import { mkdir, readdir, rm } from "fs/promises"
import path from "path"
import { fileURLToPath } from "url"

const __dirname = fileURLToPath(new URL(".", import.meta.resolve(".")))

const testEnvironmentDir = path.join(__dirname, "test-environment")
const testdirs = path.join(testEnvironmentDir, "testdirs")

export default defineConfig({
  e2e: {
    setupNodeEvents(on, _config) {
      on("after:browser:launch", async (): Promise<void> => {
        // delete everything under the ./test-environment/testdirs/ directory
        await mkdir(testdirs, { recursive: true })
        const files = await readdir(testdirs)

        console.log("Cleaning up testdirs directory...")

        for (const file of files) {
          const testdir = path.join(testdirs, file)
          console.log(`Removing ${testdir}`)
          await rm(testdir, { recursive: true })
        }
      })
    },
    experimentalRunAllSpecs: true,
    retries: {
      runMode: 2,
      openMode: 0,
    },
  },
})
