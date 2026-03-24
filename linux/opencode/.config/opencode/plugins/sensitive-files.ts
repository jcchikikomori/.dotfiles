import type { Plugin } from "@opencode-ai/plugin"

const sensitivePatterns = ['.env', 'secret', 'credentials', 'private-key']

export const SensitiveFilesPlugin: Plugin = async ({ client }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read") {
        const filePath = output?.args?.filePath
        if (typeof filePath !== "string") return

        const normalizedPath = filePath.toLowerCase()
        if (sensitivePatterns.some(pattern => normalizedPath.includes(pattern))) {
          throw new Error(`🚫 Blocked: Cannot read sensitive file ${filePath}`)
        }

        await client.app.log({
          body: {
            service: "sensitive-files-plugin",
            level: "info",
            message: "✅ No sensitive files being read.",
          }
        })
      }
    }
  }
}
