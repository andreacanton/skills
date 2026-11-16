# Claude Code only, GitHub and Forgejo first

The skills assume Claude Code as the harness. They no longer carry metadata or prose for other harnesses: no `agents/openai.yaml`, no `AGENTS.md` fallback, no install routes for Codex, Copilot, Gemini or skills.sh.

On the tracker side, the skills are written against the `gh` CLI for GitHub and the `fj` CLI for Forgejo. GitLab and local markdown stay supported by `setup-skills`, but they are not what the skills are tested against day to day.

## Why

This is the set of skills I use every day, and I use them in Claude Code against GitHub and Forgejo. Every harness-neutral sentence and every parallel metadata file was surface I paid for and never ran. Dropping it lets the skills name Claude Code's own tools (the Skill tool, the Agent tool) and its own files (`CLAUDE.md`) directly.

## Consequences

- One install route, the `@andreacanton` marketplace. See [install-block.md](../install-block.md).
- A skill is user-invoked through `disable-model-invocation: true` alone. See [invocation.md](../invocation.md).
- `setup-skills` writes its `## Agent skills` block to `CLAUDE.md`, always.
- Decisions recorded in `.out-of-scope/` whose only reason was harness neutrality are open to revisit.
