import type { Plugin } from "@opencode-ai/plugin"

export const QualityPlugin: Plugin = async ({ $ }) => {
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool === "edit") {
        const file = input.args.filePath

        // Format the file
        await $`prettier --write ${file}`
        console.log("✨ Formatted:", file)

        // Run tests
        const result = await $`npm test ${file}`.quiet()
        if (result.exitCode !== 0) {
          console.warn("⚠️ Tests failed for:", file)
        }
      }
    }
  }
}
