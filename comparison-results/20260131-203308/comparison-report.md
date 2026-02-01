# Migration Provider Comparison

**Source:** /Users/david-noble/Workspace/Personal
**Date:** 2026-02-01 04:33:47 UTC
**Providers:** gemini

## Summary

| Provider | Duration | Output Size | Valid JSON |
|----------|----------|-------------|------------|
| gemini | 37s | 1738 bytes | ❌ No |

## Outputs

### gemini

```json
```json
{
  "source_system": "tuckr",
  "repo_layer": "personal",
  "source_location": "/Users/david-noble/Workspace/Personal",
  "target_location": "~/dotfiles",
  "projects": [
    {
      "name": "all",
      "description": "Core dotfiles and configurations deployed on all machines.",
      "source_groups": ["all", "all-Darwin", "all-Debian", "all-Linux", "all-Unix", "all-Windows"],
      "always_deploy": true
    },
    {
      "name": "microsoft",
      "description": "Configurations specific to Microsoft development environments.",
      "source_groups": ["microsoft", "microsoft-Unix", "microsoft-Windows"],
      "always_deploy": false
    },
    {
      "name": "noblefactor",
      "description": "Configurations for Noble Factor projects.",
      "source_groups": ["noblefactor", "noblefactor-Unix"],
      "always_deploy": false
    },
    {
      "name": "thenobles",
      "description": "Configurations for The Nobles family projects.",
      "source_groups": ["thenobles", "thenobles-Darwin"],
      "always_deploy": false
    },
    {
      "name": "homebridge",
      "description": "Deployment configurations and secrets for Homebridge.",
      "source_groups": ["Deployments/homebridge"],
      "always_deploy": false
    },
    {
      "name": "webhook",
      "description": "Deployment configurations and secrets for webhook services.",
      "source_groups": ["Deployments/webhook"],
      "always_deploy": false
    }
  ],
  "segments": [
    {
      "directory": "all.Darwin",
      "condition": "macOS",
      "source_equivalent": "Home/Configs/all-Darwin"
    },
    {
      "directory": "all.Debian",
      "condition": "Debian-based Linux",
      "source_equivalent": "Home/Configs/all-Debian"
    },

```

## Baseline Reference

See: knowledge/migration/examples/baseline-personal.json
