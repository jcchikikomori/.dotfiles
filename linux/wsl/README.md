# Windows/WSL2 LLM Setup Guide

Local LLM setup for Windows PCs with NVIDIA GPU support using Docker Desktop and WSL2.

## Overview

This setup provides a containerized Ollama installation optimized for:
- **Windows 10/11** with WSL2
- **Docker Desktop** with WSL2 backend
- **NVIDIA RTX GPUs** (RTX Ada 500 or better recommended)
- **CPU-only mode** as fallback for systems without discrete GPU

## Prerequisites

### Required
- Windows 10 (version 2004+) or Windows 11
- WSL2 installed and configured
- Docker Desktop with WSL2 backend enabled

### Optional (for GPU acceleration)
- NVIDIA GPU with CUDA support
- NVIDIA drivers installed on Windows host

## Quick Start

### 1. Install Prerequisites

#### Install WSL2 (if not already installed)
```powershell
# Run in PowerShell as Administrator
wsl --install
```

#### Install Docker Desktop
1. Download from [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
2. During installation, ensure **"Use WSL 2 instead of Hyper-V"** is selected
3. After installation, go to Settings → Resources → WSL Integration
4. Enable integration for your WSL2 distro

#### Verify NVIDIA Drivers (for GPU)
```powershell
# Run in PowerShell
nvidia-smi
```

If you see GPU information, drivers are installed correctly.

### 2. Setup LLM

```bash
# In your WSL2 terminal
dotfiles-windows llm-setup
```

This will:
- Check Docker Desktop availability
- Detect NVIDIA GPU and configure GPU acceleration if available
- Create and start Ollama container
- Pull a default model (GPU: llama3.2:3b, CPU: phi3)

### 3. Configure opencode

```bash
# Configure opencode to use local Ollama
devtools-windows-llm opencode-config llama3.2:3b

# Check status
devtools-windows-llm opencode-config --status
```

### 4. Test

```bash
# Test with opencode
opencode ask "Hello, what model are you?"

# Or use Ollama directly
docker exec -it ollama-windows ollama run llama3.2:3b
```

## Commands Reference

### Main Commands

| Command | Description |
|---------|-------------|
| `devtools-windows-llm install` | Install Ollama with Docker Desktop |
| `devtools-windows-llm uninstall` | Remove Ollama container and configuration |
| `devtools-windows-llm start` | Start Ollama container |
| `devtools-windows-llm stop` | Stop Ollama container |
| `devtools-windows-llm status` | Show detailed status |

### Model Management

| Command | Description |
|---------|-------------|
| `devtools-windows-llm models` | List installed models |
| `devtools-windows-llm pull <model>` | Download a model |
| `devtools-windows-llm recommend` | Show recommended models |

### GPU and Diagnostics

| Command | Description |
|---------|-------------|
| `devtools-windows-llm gpu-info` | Show GPU and driver information |
| `devtools-windows-llm verify-gpu` | Test GPU acceleration |
| `devtools-windows-llm logs` | View container logs |

### Utility Commands

| Command | Description |
|---------|-------------|
| `dotfiles-windows llm-setup` | Shortcut to install LLM |
| `dotfiles-windows llm-status` | Shortcut to check status |
| `dotfiles-windows gpu-info` | Show GPU information |
| `dotfiles-windows docker-check` | Verify Docker setup |

## GPU-Optimized Models

### For RTX Ada 500 and better (with GPU acceleration)

| Model | Params | Use Case |
|-------|--------|----------|
| llama3.2:3b | 3B | Best balance of speed and quality |
| qwen2.5:7b | 7B | Strong coding capabilities |
| mistral:7b | 7B | High quality general use |
| codellama:7b | 7B | Specialized for code generation |
| qwen2.5:14b | 14B | Advanced reasoning (requires 8GB+ VRAM) |

### CPU-Only Mode

| Model | Params | Use Case |
|-------|--------|----------|
| phi3 | 3.8B | Fast and efficient |
| qwen2.5-coder:3b | 3B | Lightweight coding |
| deepseek-coder:1.3b | 1.3B | Minimal resource usage |

## Configuration

### Environment Variables

Set in `~/.config/ollama/env`:

```bash
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_MODELS="$HOME/.ollama/models"
export OLLAMA_NUM_PARALLEL="2"      # Parallel generations
export OLLAMA_MAX_LOADED_MODELS="2" # Simultaneous models
```

### opencode Integration

The configuration file is at `~/.config/opencode/opencode.jsonc`.

To switch to local Ollama:

```bash
# Use llama3.2:3b
devtools-windows-llm opencode-config llama3.2:3b

# Or use phi3 for CPU
devtools-windows-llm opencode-config phi3
```

This updates:
- `model`: Main model for responses
- `small_model`: Lightweight model for quick tasks

## Troubleshooting

### Docker Desktop Not Available

**Symptom:** "Docker Desktop is not available or not running"

**Solution:**
1. Start Docker Desktop from Windows
2. Wait for it to fully initialize (tray icon stops animating)
3. In Docker Desktop → Settings → Resources → WSL Integration
4. Enable integration for your distro
5. Restart WSL: `wsl --shutdown` then reopen terminal

### GPU Not Detected

**Symptom:** "No NVIDIA GPU detected" or "NVIDIA Container Toolkit not configured"

**Solution:**
1. Verify drivers on Windows:
   ```powershell
   nvidia-smi
   ```
2. Restart WSL2:
   ```powershell
   wsl --shutdown
   ```
3. Reopen WSL2 terminal and check again:
   ```bash
   nvidia-smi
   ```

### Container Fails to Start

**Symptom:** Installation completes but container won't start

**Solution:**
1. Check logs:
   ```bash
   docker logs ollama-windows
   ```
2. Ensure port 11434 is not in use:
   ```bash
   netstat -tlnp | grep 11434
   ```
3. Remove and reinstall:
   ```bash
   devtools-windows-llm uninstall
   devtools-windows-llm install
   ```

### Slow Performance in CPU Mode

**Expected:** CPU mode is significantly slower than GPU

**Optimization:**
- Use smaller models (1B-4B parameters)
- Close other applications
- First query loads the model (slow), subsequent queries are faster
- Consider upgrading to GPU if doing regular LLM work

## Architecture

### Container Mode (Default)

```
┌─────────────────────────────────────────────────────────────┐
│                      Windows Host                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Desktop (WSL2)                  │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │        Ollama Container (CUDA)              │   │   │
│  │  │  ┌─────────────────────────────────────┐   │   │   │
│  │  │  │      LLM Models (~/.ollama)         │   │   │   │
│  │  │  └─────────────────────────────────────┘   │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                      ↕ WSL2                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   WSL2 Ubuntu/Debian                │   │
│  │         (devtools-windows-llm, opencode)            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **opencode** sends requests to `http://localhost:11434`
2. **Docker Desktop** routes traffic to Ollama container
3. **Ollama** loads model from `~/.ollama/models`
4. **GPU** (if available) accelerates inference via CUDA
5. **Response** returns through the same path

## File Locations

| Purpose | Path |
|---------|------|
| Models | `~/.ollama/models` |
| Environment config | `~/.config/ollama/env` |
| opencode config | `~/.config/opencode/opencode.jsonc` |
| devtools-windows-llm | `~/.local/bin/devtools-windows-llm` |
| dotfiles-windows | `~/.local/bin/dotfiles-windows` |

## Performance Expectations

### With RTX Ada 500 (GPU)

| Model Size | Tokens/sec | Memory Usage |
|------------|------------|--------------|
| 3B | 40-60 | ~2-3 GB VRAM |
| 7B | 20-35 | ~4-5 GB VRAM |
| 13B | 10-20 | ~8-10 GB VRAM |

### CPU-Only

| Model Size | Tokens/sec | Notes |
|------------|------------|-------|
| 1.3B | 15-25 | Very responsive |
| 3B | 8-15 | Good for coding |
| 7B | 2-5 | Slow but usable |

## Comparison with Steam Deck

| Feature | Steam Deck | Windows/WSL2 |
|---------|------------|--------------|
| **GPU** | AMD (ROCm) | NVIDIA (CUDA) |
| **Container** | Podman | Docker Desktop |
| **Architecture** | gfx1033 | NVIDIA Compute |
| **Max Model Size** | ~7B | ~13B+ |
| **Thermal Limit** | Yes (85°C) | No (desktop cooling) |
| **Power** | Battery/Portable | AC Power |
| **Recommended** | phi3, qwen2.5-coder:3b | llama3.2:3b, qwen2.5:7b |

## References

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Docker Desktop WSL2](https://docs.docker.com/desktop/wsl/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- [RTX AI Garage](https://blogs.nvidia.com/blog/rtx-ai-garage-how-to-get-started-with-llms/)
