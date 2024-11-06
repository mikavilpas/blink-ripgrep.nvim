import { startTestServer } from "@tui-sandbox/library/src/server/server"
import type { TestServerConfig } from "@tui-sandbox/library/src/server/updateTestdirectorySchemaFile"
import { updateTestdirectorySchemaFile } from "@tui-sandbox/library/src/server/updateTestdirectorySchemaFile"
import { mkdir } from "node:fs/promises"
import path from "node:path"
import { fileURLToPath } from "node:url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// create a fake git repository to test searching inside one
await mkdir(path.join(__dirname, "..", "test-environment", "limited", ".git"), {
  recursive: true,
})

const config: TestServerConfig = {
  testEnvironmentPath: path.join(__dirname, "..", "test-environment/"),
  outputFilePath: path.join(__dirname, "..", "MyTestDirectory.ts"),
}

console.log(
  `Starting test server with config ${JSON.stringify(config, null, 2)}`,
)

await updateTestdirectorySchemaFile(config)
await startTestServer(config)
