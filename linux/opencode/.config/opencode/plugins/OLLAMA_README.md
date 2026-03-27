# Ollama Tool Converter Plugin

**Location:** `~/.config/opencode/plugins/ollama-tool-converter.ts`

Converts OpenAI-style tool calls to/from Ollama's native format for reliable tool use with local Ollama models.

## Quick Start

1. **Ensure plugin is in the correct location:**
   ```bash
   ls ~/.config/opencode/plugins/ollama-tool-converter.ts
   ```

2. **Configure Ollama provider** in your project's `opencode.json`:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "provider": {
       "ollama": {
         "npm": "@ai-sdk/openai-compatible",
         "name": "Ollama (local)",
         "options": {
           "baseURL": "http://localhost:11434/v1"
         },
         "models": {
           "llama3.1": {
             "name": "Llama 3.1"
           }
         }
       }
     }
   }
   ```

3. **Start using Ollama with tools!**
   
   The plugin loads automatically with OpenCode - no additional configuration needed.

## How It Works

This plugin hooks into OpenCode's event system:

- **`chat.params`**: Converts OpenAI tool format → Ollama format
- **`tool.execute.before`**: Normalizes Ollama responses → OpenCode format
- **`tool.execute.after`**: Logs execution for debugging

## Testing

```bash
# Start Ollama
ollama serve

# In another terminal, start OpenCode with verbose mode
opencode --verbose

# Select Ollama model
/models

# Test tool usage
read README.md
```

You should see logs:
```
[OllamaToolConverter] Plugin loaded
[OllamaToolConverter] Converted X tools to Ollama format
```

## Troubleshooting

**Model not using tools?**
- Use llama3.1 or qwen2.5
- Update Ollama: `ollama pull llama3.1`
- Check Ollama version: `ollama --version` (need 0.3.0+)

**Plugin not loading?**
- Verify file location: `~/.config/opencode/plugins/`
- Check OpenCode verbose logs: `opencode --verbose`
- Ensure no syntax errors in plugin file

## See Also

- [OpenCode Plugin Docs](https://opencode.ai/docs/plugins)
- [Ollama Documentation](https://github.com/ollama/ollama)
