// Ollama Tool Converter Plugin for OpenCode
// Converts OpenAI-style tool calls to/from Ollama's native format
// Location: ~/.config/opencode/plugins/ollama-tool-converter.ts
// 
// This plugin is installed globally and will be loaded for all OpenCode sessions.
// To install: symlink or copy this file to ~/.config/opencode/plugins/

import type { Plugin } from "@opencode-ai/plugin"

/**
 * Ollama Tool Converter Plugin
 * 
 * This plugin intercepts chat parameters and tool execution to provide
 * compatibility between OpenCode's OpenAI-style tool format and Ollama's
 * native tool calling API.
 * 
 * Features:
 * - Converts OpenAI tool format to Ollama format
 * - Injects tool-aware system prompts
 * - Parses Ollama tool call responses
 * - Normalizes tool results back to OpenCode format
 */
export const OllamaToolConverter: Plugin = async (ctx) => {
  console.log("[OllamaToolConverter] Plugin loaded")

  return {
    /**
     * Hook: chat.params
     * Converts tool definitions and injects tool-aware prompts before sending to Ollama
     */
    "chat.params": async (input, output) => {
      // Only process Ollama provider
      if (input.provider !== "ollama") {
        return
      }

      console.log("[OllamaToolConverter] Processing chat.params for Ollama")

      // Convert tools if present
      if (output.tools && Array.isArray(output.tools)) {
        try {
          output.tools = convertToOllamaFormat(output.tools)
          console.log(`[OllamaToolConverter] Converted ${output.tools.length} tools to Ollama format`)
        } catch (error) {
          console.error("[OllamaToolConverter] Error converting tools:", error)
        }
      }

      // Inject tool-aware system prompt
      if (output.messages && Array.isArray(output.messages)) {
        output.messages = injectToolAwarePrompt(output.messages, output.tools)
      }
    },

    /**
     * Hook: tool.execute.before
     * Intercepts tool execution to handle Ollama-style tool calls
     */
    "tool.execute.before": async (input, output) => {
      // Check if this is an Ollama-style tool call in the arguments
      if (output.args && typeof output.args === "object") {
        // Handle Ollama's nested tool call format
        if (output.args.tool_calls || output.args.function) {
          try {
            const normalized = normalizeOllamaToolCall(output.args)
            output.args = normalized
            console.log("[OllamaToolConverter] Normalized Ollama tool call")
          } catch (error) {
            console.error("[OllamaToolConverter] Error normalizing tool call:", error)
          }
        }
      }
    },

    /**
     * Hook: tool.execute.after
     * Optional: Log tool execution for debugging
     */
    "tool.execute.after": async (input, output) => {
      if (input.tool === "read" || input.tool === "write" || input.tool === "edit") {
        console.log(`[OllamaToolConverter] Tool executed: ${input.tool}`)
      }
    }
  }
}

/**
 * Convert OpenAI-style tool format to Ollama's native format
 */
function convertToOllamaFormat(tools: any[]): any[] {
  return tools.map(tool => {
    // Handle different input formats
    const name = tool.function?.name || tool.name
    const description = tool.function?.description || tool.description
    const parameters = tool.function?.parameters || tool.parameters

    if (!name) {
      console.warn("[OllamaToolConverter] Tool missing name:", tool)
      return tool
    }

    return {
      type: "function",
      function: {
        name,
        description: description || `Execute ${name}`,
        parameters: {
          type: "object",
          properties: parameters?.properties || {},
          required: parameters?.required || []
        }
      }
    }
  })
}

/**
 * Inject tool-aware prompts into the message array
 */
function injectToolAwarePrompt(messages: any[], tools?: any[]): any[] {
  const hasTools = tools && tools.length > 0

  if (!hasTools) {
    return messages
  }

  const toolPrompt = buildToolPrompt(tools)

  // Find existing system message
  const systemIndex = messages.findIndex(m => m.role === "system")

  if (systemIndex >= 0) {
    // Append to existing system message
    const existingContent = messages[systemIndex].content || ""
    messages[systemIndex].content = existingContent + "\n\n" + toolPrompt
  } else {
    // Add new system message at the beginning
    messages.unshift({
      role: "system",
      content: toolPrompt
    })
  }

  return messages
}

/**
 * Build a tool-aware prompt that encourages the model to use tools
 */
function buildToolPrompt(tools: any[]): string {
  const toolList = tools.map((t, i) => {
    const name = t.function?.name || t.name || `tool_${i}`
    const desc = t.function?.description || t.description || "No description"
    return `${i + 1}. ${name}: ${desc}`
  }).join("\n")

  return `You have access to the following tools:
${toolList}

When you need to use a tool, you MUST respond with a tool call in this exact JSON format:

{
  "tool_calls": [{
    "function": {
      "name": "tool_name_here",
      "arguments": {
        "param1": "value1",
        "param2": "value2"
      }
    }
  }]
}

Important:
- Use the exact tool name as listed above
- Provide all required parameters
- Respond ONLY with the JSON when calling a tool
- Do not add markdown code blocks around the JSON
- After receiving tool results, provide a helpful response based on the results`
}

/**
 * Normalize Ollama's tool call format to OpenCode's expected format
 */
function normalizeOllamaToolCall(args: any): any {
  // Handle Ollama's nested format
  if (args.tool_calls && Array.isArray(args.tool_calls)) {
    const toolCall = args.tool_calls[0]
    if (toolCall?.function) {
      return {
        ...toolCall.function.arguments,
        _toolName: toolCall.function.name,
        _rawToolCall: args
      }
    }
  }

  // Handle direct function call format
  if (args.function) {
    return {
      ...args.function.arguments,
      _toolName: args.function.name,
      _rawFunction: args.function
    }
  }

  // Handle direct arguments format (already normalized)
  return args
}

/**
 * Parse raw assistant response to extract tool calls
 * This can be used to handle text-based tool calls from models that don't support native tools
 */
export function parseToolCallFromText(text: string): any | null {
  // Try to find JSON tool call in text
  const jsonMatch = text.match(/\{[\s\S]*"tool_calls"[\s\S]*\}/)
  
  if (jsonMatch) {
    try {
      const parsed = JSON.parse(jsonMatch[0])
      if (parsed.tool_calls) {
        return parsed
      }
    } catch (e) {
      // Not valid JSON, ignore
    }
  }

  return null
}

export default OllamaToolConverter
