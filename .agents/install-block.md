# The canonical install block

One install story, one wording. `README.md` and `.changeset/*` must say **this** and nothing else. Change it here first, then propagate.

These skills assume Claude Code (see [ADR 0003](./adr/0003-claude-code-only.md)). There is one install route: this repo's own marketplace, `.claude-plugin/marketplace.json`, which points at `plugins/andreacanton-skills/.claude-plugin/plugin.json`. The plugin ships the promoted skills and the beta ones in `in-progress/`.

The plugin reinstalls only when the `version` in `plugin.json` changes. The Release workflow runs `npm run version`, which copies that field from `package.json`, so users get a release when the "chore: version skills" PR merges. Never promise "instant".

## Claude Code

<canonical-block name="claude-code">

```bash
claude plugin marketplace add andreacanton/skills
claude plugin install andreacanton-skills@andreacanton
```

To update, run `claude plugin marketplace update andreacanton`, or turn on auto-update for the marketplace in `/plugin`.

</canonical-block>

`docs/` pages don't use this block: they carry no install commands. See [writing-docs.md](./writing-docs.md).

## Working on the skills themselves

Don't install anything to test a change. Load the working copy for one session:

```bash
claude --plugin-dir plugins/andreacanton-skills
```

It reads the folders directly, so edits show up in the next session with no version bump. If the plugin is also installed, disable it in `/plugin` while you do this, so no skill shows up twice.
