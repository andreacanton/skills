---
name: preflight
description: "Check this machine for the skills' prerequisites (Claude Code, git, gh, fj and their logins) and walk through fixing what's missing. Run once per machine, and whenever a tracker command fails."
disable-model-invocation: true
---

# Preflight

The skills assume Claude Code, `git`, the `gh` CLI for GitHub and the `fj` CLI for Forgejo, each logged in. This skill checks all of it, then fixes what's missing with the user, one item at a time.

It owns the **machine**. The **repo** (issue tracker, triage labels, domain docs) belongs to `setup-skills`, which only the user can run.

## 1. Check

Run [scripts/check.sh](./scripts/check.sh) from the current directory. It is read-only. Each line is `STATUS<TAB>CHECK<TAB>DETAIL`, where `FAIL` means a skill will break and `WARN` means something works but is off.

Show the user a table of the results, every `FAIL` and `WARN` first. If there are none, say so in one line and stop.

## 2. Fix

Take the failures in the table's order. For each one, propose the fix below, wait for a yes, apply it, then re-run the script and show the line again. Done when it reads `OK`.

Never run an install or a login on your own: package managers ask for `sudo`, and logins open a browser or prompt for a token. Hand those to the user as a `! <command>` line to type into the prompt, so the command runs in this session and its output lands here.

| Check | Fix |
| --- | --- |
| `claude` | Claude Code itself is missing from `PATH` in this shell. Point the user at https://claude.com/claude-code. |
| `plugin` (not installed) | `! claude plugin marketplace add andreacanton/skills`, then `! claude plugin install andreacanton-skills@andreacanton`. Mention auto-update in `/plugin`. |
| `plugin` (dangling symlink) | The working copy moved. From the skills repo, run `scripts/link-skills.sh`. |
| `git` | Install it with the system package manager (`apt`, `dnf`, `pacman`, `brew`). Detect which one exists before suggesting a command. |
| `git-identity` | `git config --global user.name "..."` and `user.email "..."`. Ask the user for the values; never guess them. |
| `gh` | Install it with the system package manager, or from https://cli.github.com. |
| `gh-auth` | `! gh auth login`. |
| `fj` | Ask the user where they install `fj` from; it is rarely in a distro's packages. |
| `fj-auth` | `! fj auth login --host <host>`, with the Forgejo host from the repo's remote when there is one. |
| `jq` | Install it with the system package manager. |
| `repo-tracker` (no CLI logged in) | The remote's host has no logged-in CLI. If it's a Forgejo instance, log `fj` in to it (as `fj-auth`). If it's something else, the user picks a tracker in `setup-skills`. |
| `repo-tracker` (cannot see the repo) | The account lacks access, or the remote points at the wrong repo. Show `git remote -v` and ask which it is. |
| `repo-remote` | No remote: fine for a local-markdown tracker. Otherwise the user adds one (`git remote add origin <url>`). |
| `repo-setup` | Tell the user to run `/setup-skills` in this repo. |

A failure not in the table: show the line, say what you think it means, and ask before acting.

## 3. Done

Re-run the script one last time and show the final table. If `repo-setup` is still a `WARN`, end by telling the user to run `/setup-skills`.
