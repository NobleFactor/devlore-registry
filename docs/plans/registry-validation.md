# Registry Validation: Fix CI Workflows

## Status: In Progress

## Problem

Both CI workflows in devlore-registry are broken:

- **validate.yaml**: Broken since Feb 3 (PR #15 merged without updating it). Runs
  `./star registry validate` — a command that was renamed in noblefactor-ops PR #17
  (Feb 2) and then deleted entirely in the extension restructuring (Feb 10-12).
- **update-indexes.yaml**: Broken since creation. All 4 runs failed. Runs
  `./noblefactor-ops/star devlore-registry index packages` — also deleted.

### Root Cause

Star discovers extensions at runtime from `${GIT_WORKSPACE_ROOT}/star/extensions/`.
In CI, the git workspace root is devlore-registry, which has no extensions directory.
The validate and index commands were moved to devlore-cli's extensions
(`com.noblefactor.devlore.Package` and `com.noblefactor.devlore.Knowledge`), but
devlore-cli is never checked out in CI.

### Timeline

| Date | Event | Effect |
|------|-------|--------|
| Jan 31 | noblefactor-ops PR #8: `ops/validate.star` (`registry.validate`) | `star registry validate` works |
| Jan 31 | devlore-registry PR #12: validate.yaml created | CI passes |
| Feb 2 | noblefactor-ops PR #17: rename to `devlore-registry.validate` | `star registry validate` breaks |
| Feb 3 | devlore-registry PR #15: updates update-indexes.yaml, skips validate.yaml | validate.yaml broken on develop |
| Feb 10-12 | noblefactor-ops #46,#47,#51: extension restructuring | `ops/devlore-registry/` deleted |
| Feb 13 | devlore-cli PR #113: `com.noblefactor.devlore.Package` created | Validate lives in devlore-cli |

### Current Command Locations

| Old Command | Current Location | Binary |
|-------------|-----------------|--------|
| `star registry validate` | `star devlore package validate` | devlore-cli extensions |
| `star devlore-registry index packages` | `star devlore package index` | devlore-cli extensions |
| `star devlore-registry index knowledge` | `star devlore knowledge index` | devlore-cli extensions |

### Existing Commands in devlore-cli

These commands already exist and work today. They live in devlore-cli's
`star/extensions/` and are discovered when star runs from the devlore-cli workspace:

| Extension | Command | What it does |
|-----------|---------|-------------|
| `com.noblefactor.devlore.Package` | `star devlore package validate` | Validate package YAML against JSON schemas |
| `com.noblefactor.devlore.Package` | `star devlore package index` | Generate index.yaml and cross-reference.yaml |
| `com.noblefactor.devlore.Knowledge` | `star devlore knowledge validate` | Validate knowledge YAML against JSON schemas |
| `com.noblefactor.devlore.Knowledge` | `star devlore knowledge index` | Generate knowledge index files |

All four accept `--target` to point at a registry directory (default: `../devlore-registry`).

Local verification (run from devlore-cli workspace):
```bash
star devlore package validate --target=../devlore-registry
star devlore knowledge validate --target=../devlore-registry
star devlore package index --target=../devlore-registry
star devlore knowledge index --target=../devlore-registry
```

## Design

The commands exist in devlore-cli but CI can't discover them because star looks
for extensions at `${GIT_WORKSPACE_ROOT}/star/extensions/` and devlore-registry
has no extensions directory.

### Option A: Check out devlore-cli in CI (Rejected)

Check out devlore-cli in CI and point star at its extensions. Problems:
- CI now depends on three repos (registry, noblefactor-ops, devlore-cli)
- Extension discovery assumes `${GIT_WORKSPACE_ROOT}/star/extensions/` — can't
  point at a subdirectory checkout without patching the search path

### Option B: devlore-registry owns its extensions (Preferred)

Create `star/extensions/` in devlore-registry with the validate and index commands.
These are small Starlark scripts (50-120 lines each). Adapt from the working
implementations in devlore-cli.

Advantages:
- Self-contained: CI only needs noblefactor-ops (for the star binary)
- Extensions live next to the data they validate
- No cross-repo runtime dependency
- Can be tested locally before CI runs

## Additional Issues Found

### Generated indexes are gitignored instead of committed

`packages/index.yaml`, `packages/cross-reference.yaml`, and `knowledge/*/index.yaml`
are listed in `.gitignore` (added in devlore-registry PR #15). They were supposed to
be committed by CI via the `update-indexes.yaml` workflow, but that workflow has never
worked. These files should be committed to the repo, not gitignored. Remove them from
`.gitignore` and commit them.

### Path-filtered CI allows bypass

The `validate.yaml` workflow only triggers on changes to `packages/**`,
`knowledge/**`, `schemas/**`, and `signatures.yaml`. If a PR's latest commit
touches only other paths (e.g., `docs/`), the workflow doesn't run and GitHub
shows all checks passing. This means bad changes can be merged by pushing a
cosmetic commit outside the trigger paths.

Fix: Remove the `paths` filter from the `pull_request` trigger. Validate on
every PR. Keep the `paths` filter on `push` (only regenerate indexes on actual
content changes).

### No smoke testing of Starlark scripts

The validate workflow only checks lifecycle YAML against JSON schemas. It does NOT
validate the `.star` scripts that define package lifecycle phases. There are 100+
Starlark scripts in the registry and none are tested by CI. A syntax error or bad
API call in any script goes undetected until runtime.

CI must smoke test all `.star` code:
- All packages must be loadable by the DevLore Registry provider
- All scripts must be parsed and verified by the Starlark runtime
- Every phase script (`prepare.star`, `install.star`, `provision.star`, `verify.star`,
  etc.) must be loaded without errors
- Test via the DevLore Registry provider, not by parsing `.star` files in isolation

## Implementation

### Phase 1: Create registry extensions and fix CI

#### Step 1: Create validate extension

Create `star/extensions/com.noblefactor.devlore-registry.Validate/`:
- `extension.yaml` — declares `devlore-registry.validate` command with `--type` flag
- `commands/validate.star` — adapted from devlore-cli's Package validate.star

The validate script:
- Walks `packages/*/lifecycle.yaml` and validates against `schemas/package.lifecycle.json`
- Walks `knowledge/*/index.yaml` and validates against `schemas/knowledge.index.json`
- Validates `packages/index.yaml` against `schemas/package.index.json`
- Validates `packages/cross-reference.yaml` against `schemas/package.signatures.json`
- Supports `--type` flag to filter (package, knowledge, or all)

#### Step 2: Create index extensions

Create `star/extensions/com.noblefactor.devlore-registry.IndexPackages/`:
- `extension.yaml` — declares `devlore-registry.index.packages` command
- `commands/index-packages.star` — builds packages/index.yaml and cross-reference.yaml

Create `star/extensions/com.noblefactor.devlore-registry.IndexKnowledge/`:
- `extension.yaml` — declares `devlore-registry.index.knowledge` command
- `commands/index-knowledge.star` — builds knowledge/*/index.yaml

Source: Adapt from the original `ops/devlore-registry/` scripts (deleted from
noblefactor-ops but recoverable from git history of PR #17 and earlier).

#### Step 3: Fix validate.yaml

```yaml
on:
  pull_request:
    branches: [develop, main]
    # No paths filter — validate on every PR
  push:
    branches: [develop]
    paths:
      - 'packages/**'
      - 'knowledge/**'
      - 'schemas/**'
```

```yaml
- name: Build star
  working-directory: noblefactor-ops
  run: go build -o ../star ./cmd/star

- name: Validate all schemas
  run: ./star devlore-registry validate

- name: Smoke test Starlark scripts
  run: ./star devlore-registry smoke-test
```

Changes:
- Remove `paths` filter from `pull_request` trigger (prevent bypass)
- Keep `paths` filter on `push` (only run on actual content changes)
- Update Go version to 1.24
- Add `cache-dependency-path: noblefactor-ops/go.sum`
- Fix command: `./star devlore-registry validate`
- Add smoke test step

#### Step 4: Fix update-indexes.yaml

```yaml
- name: Build star
  working-directory: noblefactor-ops
  run: go build -o ../star ./cmd/star

- name: Update package index
  run: ./star devlore-registry index packages

- name: Update knowledge indexes
  run: ./star devlore-registry index knowledge
```

Changes:
- Fix commands to match new extension names
- Build star in noblefactor-ops working directory (consistent with validate.yaml)

#### Step 5: Commit generated indexes

Remove from `.gitignore`:
- `packages/index.yaml`
- `packages/cross-reference.yaml`
- `knowledge/*/index.yaml`

Generate and commit these files. The `update-indexes.yaml` workflow continues to
regenerate and commit them on push, but they must also be present in the repo for
local development and validation.

#### Step 6: Add Starlark smoke test extension

Create `star/extensions/com.noblefactor.devlore-registry.SmokeTest/`:
- `extension.yaml` — declares `devlore-registry.smoke-test` command
- `commands/smoke-test.star` — loads every package via the DevLore Registry provider

The smoke test:
- Discovers all packages under `packages/`
- For each package, loads the lifecycle definition
- For each platform/lifecycle/phase, loads the `.star` script through the Starlark
  runtime — verifying syntax, imports, and function signatures
- Reports pass/fail per script with summary counts
- Fails CI if any script cannot be loaded

Add to `validate.yaml`:
```yaml
- name: Smoke test Starlark scripts
  run: ./star devlore-registry smoke-test
```

### Verification

1. `./star devlore-registry validate` passes locally against the registry
2. `./star devlore-registry index packages` produces correct index.yaml
3. `./star devlore-registry index knowledge` produces correct index files
4. `./star devlore-registry smoke-test` loads all `.star` scripts without errors
5. `packages/index.yaml`, `packages/cross-reference.yaml` committed to repo
6. Push to a branch and verify both CI workflows pass
7. Verify validate.yaml triggers on `packages/**` and `schemas/**` changes
8. Verify update-indexes.yaml triggers on `packages/**/lifecycle.yaml` changes

### Files

| File | Action |
|------|--------|
| `star/extensions/com.noblefactor.devlore-registry.Validate/extension.yaml` | Create |
| `star/extensions/com.noblefactor.devlore-registry.Validate/commands/validate.star` | Create |
| `star/extensions/com.noblefactor.devlore-registry.IndexPackages/extension.yaml` | Create |
| `star/extensions/com.noblefactor.devlore-registry.IndexPackages/commands/index-packages.star` | Create |
| `star/extensions/com.noblefactor.devlore-registry.IndexKnowledge/extension.yaml` | Create |
| `star/extensions/com.noblefactor.devlore-registry.IndexKnowledge/commands/index-knowledge.star` | Create |
| `star/extensions/com.noblefactor.devlore-registry.SmokeTest/extension.yaml` | Create |
| `star/extensions/com.noblefactor.devlore-registry.SmokeTest/commands/smoke-test.star` | Create |
| `.github/workflows/validate.yaml` | Modify |
| `.github/workflows/update-indexes.yaml` | Modify |
| `.gitignore` | Modify (remove generated index entries) |
| `packages/index.yaml` | Commit (generated) |
| `packages/cross-reference.yaml` | Commit (generated) |
| `knowledge/*/index.yaml` | Commit (generated) |

### Phase 2: Add registry validation to devlore-cli CI

The `knowledge-extract.yaml` workflow in devlore-cli already checks out all three
repos (devlore-cli, noblefactor-ops, devlore-registry). It extracts knowledge but
does not validate the registry. Add validation and smoke testing after the extract
step so registry correctness is checked on every devlore-cli PR too.

#### Step 1: Add validation to knowledge-extract.yaml

After the "Build knowledge base" step, add:

```yaml
- name: Validate registry schemas
  working-directory: devlore-cli
  run: |
    ${{ github.workspace }}/noblefactor-ops/bin/star devlore package validate \
      --target ${{ github.workspace }}/devlore-registry
    ${{ github.workspace }}/noblefactor-ops/bin/star devlore knowledge validate \
      --target ${{ github.workspace }}/devlore-registry

- name: Smoke test Starlark scripts
  working-directory: devlore-cli
  run: |
    ${{ github.workspace }}/noblefactor-ops/bin/star devlore package smoke-test \
      --target ${{ github.workspace }}/devlore-registry
```

This runs from the devlore-cli workspace, so star discovers devlore-cli's extensions.
The `--target` flag points at the devlore-registry checkout.

#### Step 2: Add smoke test command to devlore-cli Package extension

Create `star/extensions/com.noblefactor.devlore.Package/commands/smoke-test.star`:
- Discovers all packages under `--target`
- For each package, loads lifecycle.yaml
- For each platform/lifecycle/phase, loads the `.star` script through the Starlark
  runtime — verifying syntax, imports, and function signatures
- Reports pass/fail per script
- Fails if any script cannot be loaded

Add to `com.noblefactor.devlore.Package/extension.yaml`:
```yaml
- name: devlore.package.smoke-test
  help: Smoke test all Starlark lifecycle scripts in the registry
  implementation: commands/smoke-test.star
  flags:
    - name: target
      type: string
      default: ""
      help: "Registry root to test (default: ../devlore-registry)"
```

### Why both repos

| Check | devlore-registry CI | devlore-cli CI |
|-------|--------------------|--------------------|
| Schema validation | Catches invalid YAML in registry PRs | Catches knowledge extract producing invalid output |
| Starlark smoke test | Catches broken scripts in registry PRs | Catches API changes in devlore-cli that break scripts |
| Index generation | Keeps indexes current on registry push | N/A |

Registry CI catches registry-side breakage. devlore-cli CI catches CLI-side changes
that break the registry (e.g., renaming plan bindings, changing function signatures).
Both must run the same validation and smoke tests.

### Files (Phase 2)

| Repo | File | Action |
|------|------|--------|
| devlore-cli | `.github/workflows/knowledge-extract.yaml` | Modify |
| devlore-cli | `star/extensions/com.noblefactor.devlore.Package/commands/smoke-test.star` | Create |
| devlore-cli | `star/extensions/com.noblefactor.devlore.Package/extension.yaml` | Modify |

### Verification (Phase 2)

1. `star devlore package validate --target=../devlore-registry` passes locally
2. `star devlore knowledge validate --target=../devlore-registry` passes locally
3. `star devlore package smoke-test --target=../devlore-registry` loads all scripts
4. Push devlore-cli PR and verify knowledge-extract workflow runs validation
5. Break a `.star` script intentionally, confirm CI catches it

## Dependencies

- noblefactor-ops `star` binary (built in CI from checkout)
- Starlark builtins: `file.*`, `yaml.*`, `schema.*` (provided by noblefactor-ops runtime)

## Risks

- The original index scripts may need updates if the Starlark API changed during
  the extension restructuring. Recover from git history and test locally.
- The `schema.validate()` builtin must be available in the noblefactor-ops runtime.
  Verify before implementing.
- The smoke test command needs to load `.star` scripts through the same runtime
  that `lore deploy` uses. If the test uses a different loader, it may miss errors
  or produce false positives.
