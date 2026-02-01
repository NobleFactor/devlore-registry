# Plan: `devlore self-install --with ollama`

## Goal

Provide a zero-API-key setup experience by bundling Ollama installation with devlore.

## Ollama Setup Experience Today

| Platform | Install Method | Notes |
|----------|---------------|-------|
| **Linux** | `curl -fsSL https://ollama.com/install.sh \| sh` | Works, detects distro |
| **macOS** | Download `.dmg` or `brew install ollama` | GUI installer |
| **Windows** | Download `.exe` | Silent install broken (Issue #7969) |

Then: `ollama pull <model>` (downloads 1-5 GB depending on model size)

## Command Design

```
devlore self-install --with ollama[:<model>]

# Examples:
devlore self-install --with ollama              # Default model (qwen3:4b)
devlore self-install --with ollama:llama3.2:3b  # Specific model
devlore self-install --with ollama:qwen3:0.5b   # Tiny model for testing
```

## Phase 1: Detection & Validation

**Pre-flight checks:**
1. Detect OS (darwin/linux/windows)
2. Check available RAM (warn if <8GB)
3. Check available disk space (need ~5GB minimum)
4. Check if Ollama already installed (`which ollama`)

## Phase 2: Install Ollama

| OS | Method |
|----|--------|
| Linux | Run Ollama's install script |
| macOS | Download + open DMG, or `brew install` if Homebrew present |
| Windows | Download `.exe`, run installer (await fix for silent mode) |

## Phase 3: Pull Model & Configure

```bash
ollama pull qwen3:4b           # ~2.5 GB, good balance
ollama serve &                 # Start server (or use launchd/systemd)
```

Write config to `~/.config/devlore/config.yaml`:
```yaml
provider: ollama
model: qwen3:4b
endpoint: http://localhost:11434
# No api_key needed!
```

## Phase 4: Verify

```bash
devlore doctor                 # Health check
# ✔ Ollama running at localhost:11434
# ✔ Model qwen3:4b loaded
# ✔ Ready for writ migrate
```

## Recommended Default Models

| Model | Size | RAM | Use Case |
|-------|------|-----|----------|
| `qwen3:0.5b` | ~400 MB | 2 GB | Minimal/testing |
| `qwen3:4b` | ~2.5 GB | 8 GB | **Recommended default** |
| `llama3.2:3b` | ~2 GB | 8 GB | Alternative default |
| `qwen3:8b` | ~5 GB | 16 GB | Better quality |
| `deepseek-r1:8b` | ~5 GB | 16 GB | Reasoning tasks |

**Recommendation:** Default to `qwen3:4b` - good balance of size, speed, and capability. MIT licensed.

## Pros vs Cons: Local Ollama vs Online Providers

| Aspect | Local Ollama | Online Provider |
|--------|--------------|-----------------|
| **API Key** | ✅ None needed | ❌ Required |
| **Account signup** | ✅ None | ❌ Required |
| **Privacy** | ✅ Data stays local | ⚠️ Sent to provider |
| **Offline use** | ✅ Yes | ❌ No |
| **Rate limits** | ✅ None | ⚠️ Free tiers limited |
| **Cost** | ✅ Free (your hardware) | ⚠️ Free tier or paid |
| **Setup complexity** | ⚠️ Download ~2-5 GB | ✅ Just paste key |
| **Hardware required** | ⚠️ 8+ GB RAM | ✅ None |
| **Inference speed** | ⚠️ Depends on hardware | ✅ Fast (cloud GPUs) |
| **Model quality** | ⚠️ Smaller models | ✅ GPT-4, Claude, etc. |
| **Maintenance** | ⚠️ User updates Ollama | ✅ Provider handles |

## Solving the API_KEY Problem

**The problem:** Users must:
1. Find a provider
2. Create an account
3. Navigate to API keys page
4. Copy/paste key
5. Store securely
6. Manage expiration/rotation

**Local Ollama solves this entirely:**
```
devlore self-install --with ollama
# Done. No accounts. No keys. Works.
```

**Hybrid approach for power users:**
```yaml
# ~/.config/devlore/config.yaml
provider: ollama                    # Default: local, no key
fallback_provider: openrouter       # Optional: for larger models
fallback_api_key: ${OPENROUTER_KEY} # Only if they want it
```

## Implementation Sketch

```go
// cmd/devlore/selfinstall.go

func installOllama(model string) error {
    // 1. Pre-flight
    if err := checkSystemRequirements(); err != nil {
        return err
    }

    // 2. Install Ollama (if not present)
    if !ollamaInstalled() {
        switch runtime.GOOS {
        case "linux":
            return runOllamaLinuxInstall()
        case "darwin":
            return runOllamaMacInstall()
        case "windows":
            return runOllamaWindowsInstall()
        }
    }

    // 3. Pull model
    if err := pullModel(model); err != nil {
        return err
    }

    // 4. Write config
    return writeDevloreConfig(model)
}
```

## Open Questions

1. **Should we bundle Ollama?** Or just download at install time?
   - Download is simpler, always gets latest
   - Bundling adds to devlore binary size but works offline

2. **Auto-start Ollama service?** Or require user to run `ollama serve`?
   - Linux: systemd service
   - macOS: launchd plist
   - Windows: startup task

3. **Model recommendation UI?** Interactive selection based on available RAM?

## Sources

- [Ollama Linux Install](https://docs.ollama.com/linux)
- [Ollama Install Script](https://github.com/ollama/ollama/blob/main/scripts/install.sh)
- [Ollama Model Library](https://ollama.com/library)
- [Qwen3 Models](https://ollama.com/library/qwen3)
- [Windows Silent Install Issue](https://github.com/ollama/ollama/issues/7969)
