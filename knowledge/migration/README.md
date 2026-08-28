# Writ Migration Knowledge Base

This directory contains reference material for AI-assisted migration from other
dotfile management systems to writ. The `migrate-to-writ.txt` prompt in
`../prompts/` uses this knowledge to generate migration plans.

## Source Systems

| System | Guide | Key Concepts |
|--------|-------|--------------|
| GNU Stow | [from-stow.yaml](transforms/from-stow.yaml) | Packages → projects, symlink farm |
| chezmoi | [from-chezmoi.yaml](transforms/from-chezmoi.yaml) | `dot_` prefix, `.tmpl`, scripts |
| yadm | [from-yadm.yaml](transforms/from-yadm.yaml) | Alt files (`##`), Jinja2, bare git |
| Tuckr | [from-tuckr.yaml](transforms/from-tuckr.yaml) | Groups, Hooks.toml |
| Bare git | [from-bare-git.yaml](transforms/from-bare-git.yaml) | `$HOME` worktree, branches |

## How These Are Used

1. `lore onboard --migrate` or `writ migrate` detects the source system
2. The CLI fetches the appropriate migration guide from this directory
3. The AI prompt (`migrate-to-writ.txt`) + guide + user's file listing
   generate a structured migration plan matching `migration-plan.json` schema
4. The user reviews and approves the plan before execution

## Writ Quick Reference

### File Extensions
| Extension | Processing |
|-----------|-----------|
| (none) | Symlink |
| `.template` | Go text/template rendering |
| `.age` | age decryption (mode 0600) |
| `.sops` | SOPS decryption (mode 0600) |

### Directory Structure
```
<source-root>/
  <project>/                    Base project files
  <project>.<OS>/               OS-specific overrides
  <project>.<OS>.<ARCH>/        OS+arch-specific overrides
```

### Segment Matching Values
| Segment | Values |
|---------|--------|
| OS | `Darwin`, `Linux`, `Windows` |
| ARCH | `arm64`, `amd64` |

### Commands
| Command | Purpose |
|---------|---------|
| `writ add <projects>` | Deploy (create symlinks) |
| `writ remove <projects>` | Remove symlinks |
| `writ status` | Show state and drift |
| `writ add --dry-run` | Preview deployment |
| `writ add --conflict=backup` | Backup existing files |
