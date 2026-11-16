# Issue tracker: Forgejo

Issues and specs for this repo live as issues on a Forgejo instance. Use the `fj` CLI for all operations. It mirrors `gh`, and infers the repo from the git remote when run inside a clone (pass `-R <owner>/<name>` to override, `--host <host>` when you're logged in to more than one instance).

## Conventions

- **Create an issue**: `fj issue create --title "..." --body-file -` with the body on stdin from a heredoc. Add `--label <name>` (repeatable) to label it at creation.
- **Read an issue**: `fj issue view <number> --comments --json`.
- **List issues**: `fj issue list --state open --json --paginate`, with `--label` / `--assignee` / `--search` filters. Pipe to `jq` to project fields.
- **Make an issue a child of a parent**: Forgejo has no sub-issues. Put `Part of #<parent>` at the top of the child body, and add the child to a task list in the parent body.
- **Blocking**: Forgejo's **native issue dependencies**, the canonical, UI-visible representation. Add an edge with `fj issue dependency add <child> <blocker>` (the child depends on the blocker). If dependencies are disabled on the repo, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Count open blockers**: `fj issue dependency list <n> --json`, keeping the dependencies whose state is open (0 means startable).
- **Comment on an issue**: `fj issue comment <number> --body-file -` with the body on stdin.
- **Apply / remove labels**: `fj issue edit <number> --add-label "..."` / `--remove-label "..."`.
- **Create a missing label**: `fj label create <name> --description "..."`. `fj issue create --label <missing>` does not create it.
- **Close**: post the explanation with `fj issue comment <number> ...`, then `fj issue close <number>`. `fj issue close` takes no comment.

File issues only into the user's own repo. Before the first `fj issue create` of a session, check the target with `fj repo view --json` and confirm it with the user if it is not their repo.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `fj pr` equivalents:

- **Read a PR**: `fj pr view <number> --comments`, and `fj pr diff <number>` for the diff.
- **List external PRs for triage**: `fj pr list --json --paginate`, then keep only PRs whose author is not a repo owner or collaborator.
- **Comment / label / close**: `fj pr comment`, `fj pr edit` (labels), `fj pr close`.

Forgejo shares one number space across issues and PRs, so a bare `#42` may be either: resolve with `fj pr view 42` and fall back to `fj issue view 42`.

## When a skill says "publish to the issue tracker"

Create a Forgejo issue.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `fj issue create --label wayfinder:map`.
- **Child ticket**: an issue with `Part of #<map>` at the top of its body, listed in a task list in the map body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: see **Blocking** under Conventions.
- **Frontier query**: walk the map's task list, keep the open children, drop any with an open blocker (see **Count open blockers**, or an open issue in the `Blocked by` line) or an assignee; first in map order wins.
- **Claim**: `fj issue edit <n> --add-assignee <your-login>`, the session's first write.
- **Resolve**: `fj issue comment <n> ...`, then `fj issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
