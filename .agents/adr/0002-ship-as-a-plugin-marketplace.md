# Ship as a plugin marketplace, one folder per plugin

The repo is a plugin marketplace, not a single plugin. `.claude-plugin/marketplace.json` at the root lists every plugin, and each plugin lives in its own folder under `plugins/<plugin-name>/`, with its own `.claude-plugin/plugin.json` and its own `skills/` tree. Today there is one plugin, `andreacanton-skills`, at `plugins/andreacanton-skills/`.

Claude Code installs from this marketplace (`<plugin>@andreacanton`). See [install-block.md](../install-block.md) and [ADR 0003](./0003-claude-code-only.md).

## Why a folder per plugin

A plugin whose `source` is the repo root (`./`) owns the whole repo: a second plugin would have to share its tree or force a restructure later. Giving each plugin its own folder from the start means adding one is a new folder under `plugins/` plus one entry in `marketplace.json`, with no moves.

## Invariants this creates

- Every promoted skill (`engineering/`, `productivity/`) has an entry in `plugins/andreacanton-skills/.claude-plugin/plugin.json`'s `skills` array. That array is the only thing deciding what the plugin ships, so `misc/`, `in-progress/` and `deprecated/` stay out without being moved.
- `plugin.json`'s `version` tracks `package.json`'s. `npm run version` keeps them in sync through `scripts/sync-plugin-version.mjs`; managed installs only update when that `version` changes. `marketplace.json` has no `version` field, so it cannot drift.
- `claude plugin validate . --strict` (the marketplace) and `claude plugin validate plugins/<plugin-name> --strict` (each plugin) pass after any manifest change.
