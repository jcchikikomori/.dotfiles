import type { Plugin } from "@opencode-ai/plugin"

export const TestPlugin: Plugin = async ({ client }) => {
  await client.app.log({
    body: {
      service: "test-plugin",
      level: "info",
      message: "Test plugin loaded",
    },
  })

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await client.app.log({
          body: {
            service: "test-plugin",
            level: "info",
            message: "Session is idle",
          },
        })
      }
    },
    "tool.execute.before": async (input) => {
      if (input.tool === "read") {
        // Hook point for pre-read checks
      }
    },
  }
}
