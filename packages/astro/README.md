# Astro - lore Package

The web framework for content-driven websites.

## Tribal Knowledge

### Node.js Version Requirements

Astro has specific Node.js version requirements:

| Version | Supported | Notes |
|---------|-----------|-------|
| v18.20.8+ | Yes | Minimum for v18.x |
| v19.x | **No** | Odd-numbered, not LTS |
| v20.3.0+ | Yes | Minimum for v20.x |
| v21.x | **No** | Odd-numbered, not LTS |
| v22+ | Yes | All v22.x |

### Cross-Platform

npm/pnpm/yarn work identically on darwin, linux, and windows. One script handles all platforms.

### npm Permission Issues

On macOS/Linux, global installs may fail with `EACCES`. Fix:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile
```

Or use nvm/fnm which avoid permission issues entirely.

## Usage

```bash
# Default (global CLI + completions)
lore deploy astro

# With Tailwind
lore deploy astro --with tailwind

# Use pnpm
lore deploy astro --set package_manager=pnpm
```

## Features

| Feature | Default | Description |
|---------|---------|-------------|
| `global-cli` | true | Install `astro` command globally |
| `completions` | true | Shell completions (bash/zsh/fish) |
| `tailwind` | false | @astrojs/tailwind integration |
| `react` | false | @astrojs/react integration |
| `svelte` | false | @astrojs/svelte integration |
| `vue` | false | @astrojs/vue integration |

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `package_manager` | npm | npm, pnpm, or yarn |
| `typescript` | strict | TS mode for new projects |
