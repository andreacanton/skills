## What it does

`preflight` checks that this machine has what the skills assume: Claude Code with the plugin installed, `git` with an identity, `gh` logged in to GitHub, `fj` logged in to Forgejo, and `jq`. Inside a repo it also checks that the CLI matching the remote can see the repo, and whether the repo has been set up. Then it walks you through each failure, one at a time, re-checking after every fix.

It checks the machine and never configures the repo. The check itself is a read-only script, so the verdict is the same every run. Anything that installs software or logs you in is handed to you as a `!` command to type, never run on your behalf.

## When to reach for it

You invoke this by typing `/preflight`; the agent won't reach for it on its own.

| Situation | Reach for |
| --- | --- |
| New machine, or first install of the plugin | `/preflight` |
| A `gh` or `fj` command fails with an auth or "repo not found" error | `/preflight` |
| The repo has no issue tracker, labels or domain docs configured | [setup-skills](https://github.com/andreacanton/skills/blob/main/docs/engineering/setup-skills.md) |

## Machine, then repo

The two setup skills split along one line: what lives on your machine, and what lives in the repo.

| | `preflight` | `setup-skills` |
| --- | --- | --- |
| Scope | the machine | one repo |
| Writes | nothing (you run the fixes) | `docs/agents/*.md`, the `## Agent skills` block in `CLAUDE.md`, missing labels |
| Run | once per machine, and when a tracker command fails | once per repo |

`preflight` reports a repo that hasn't been set up and tells you to run `/setup-skills`. It doesn't check the contents of `docs/agents/` against the templates: re-running `/setup-skills` and asking it to verify is how you do that.

## Common questions

**Why not `/doctor`?**

Claude Code ships a built-in `/doctor`, and the built-in wins. A skill with that name would only be reachable as `/andreacanton-skills:doctor`.

**It says the plugin isn't installed, but my skills work.**

You're probably loading the working copy with `claude --plugin-dir`. The check can't see a plugin loaded that way, so it reports a warning rather than a failure.

## It's working if

- The final table has no `FAIL` lines.
- `/to-tickets` and `/triage` reach the tracker without an auth error.
- Every install and login appeared as a `!` command you typed, not one the agent ran.

## Where it fits

`preflight` is the **run-once setup** for the machine, before [setup-skills](https://github.com/andreacanton/skills/blob/main/docs/engineering/setup-skills.md) does the same for each repo. [ask-skills](https://github.com/andreacanton/skills/blob/main/docs/engineering/ask-skills.md) routes the whole set.
