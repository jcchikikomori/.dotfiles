import type { Plugin } from "@opencode-ai/plugin"

export const QualityPlugin: Plugin = async ({ $, client }) => {
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool !== "edit") return

      const filePath =
        (output as any)?.args?.filePath ?? (input)?.args?.filePath
      if (!filePath) return

      try {
        const formatResult = await $`prettier --write ${filePath}`.nothrow().quiet()
        if (formatResult.exitCode === 0) {
          await client.app.log({
            body: {
              service: "quality-plugin",
              level: "info",
              message: `Formatted ${filePath}`,
            },
          })
        }
      } catch {
        await client.app.log({
          body: {
            service: "quality-plugin",
            level: "warn",
            message: `Prettier failed for ${filePath}`,
          },
        })
      }

      try {
        const testResult = await $`npm test -- ${filePath}`.nothrow().quiet()
        if (testResult.exitCode !== 0) {
          await client.app.log({
            body: {
              service: "quality-plugin",
              level: "warn",
              message: `Tests failed for ${filePath}`,
            },
          })
        }
      } catch {
        await client.app.log({
          body: {
            service: "quality-plugin",
            level: "warn",
            message: `Test command errored for ${filePath}`,
          },
        })
      }
    },
  }
}
