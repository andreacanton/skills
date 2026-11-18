#!/usr/bin/env bash
# Read-only prerequisite check for the andreacanton-skills plugin.
# Prints one line per check: STATUS<TAB>CHECK<TAB>DETAIL
# STATUS is OK, WARN (works, but something is off) or FAIL (a skill will break).
# Never installs, logs in or writes anything.
set -uo pipefail

report() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- Machine ---------------------------------------------------------------

if have claude; then
  report OK claude "$(claude --version 2>/dev/null | head -n1)"
  if claude plugin list 2>/dev/null | grep -q 'andreacanton-skills@andreacanton'; then
    report OK plugin "andreacanton-skills installed from the @andreacanton marketplace"
  elif [ -e "$HOME/.claude/skills/setup-skills" ]; then
    report OK plugin "skills linked into ~/.claude/skills (working copy)"
  elif [ -L "$HOME/.claude/skills/setup-skills" ]; then
    report FAIL plugin "~/.claude/skills/setup-skills is a dangling symlink (the working copy moved)"
  else
    report FAIL plugin "andreacanton-skills is not installed"
  fi
else
  report FAIL claude "claude not on PATH"
fi

if have git; then
  report OK git "$(git --version)"
  name="$(git config --global user.name 2>/dev/null || true)"
  email="$(git config --global user.email 2>/dev/null || true)"
  if [ -n "$name" ] && [ -n "$email" ]; then
    report OK git-identity "user.name and user.email set"
  else
    report WARN git-identity "global user.name or user.email missing"
  fi
else
  report FAIL git "git not on PATH"
fi

if have gh; then
  report OK gh "$(gh --version 2>/dev/null | head -n1)"
  if gh auth status >/dev/null 2>&1; then
    report OK gh-auth "logged in"
  else
    report FAIL gh-auth "not logged in to any GitHub host"
  fi
else
  report FAIL gh "gh not on PATH"
fi

if have fj; then
  report OK fj "$(fj --version 2>/dev/null | head -n1)"
  # `fj auth list` prints a HOST header, then one row per host, `*` marking the current one.
  fj_hosts="$(fj auth list 2>/dev/null | awk 'NR > 1 { sub(/^\*/, ""); if ($1 != "") print $1 }' || true)"
  if [ -n "$fj_hosts" ]; then
    report OK fj-auth "hosts: $(printf '%s' "$fj_hosts" | paste -sd, -)"
  else
    report FAIL fj-auth "not logged in to any Forgejo host"
  fi
else
  report FAIL fj "fj not on PATH"
fi

if have jq; then
  report OK jq "$(jq --version 2>/dev/null)"
else
  report WARN jq "jq not on PATH (tracker templates pipe JSON through it)"
fi

# --- Current repo ----------------------------------------------------------

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  report WARN repo "not inside a git repo; repo checks skipped"
  exit 0
fi

remote="$(git remote get-url origin 2>/dev/null || git remote get-url "$(git remote | head -n1)" 2>/dev/null || true)"
if [ -z "$remote" ]; then
  report WARN repo-remote "no git remote; only a local-markdown tracker will work"
else
  # git@host:owner/name.git, ssh://git@host:port/owner/name, https://host[:port]/owner/name
  host="$(printf '%s' "$remote" | sed -E 's#^[a-z+]+://##; s#^[^@/]*@##; s#[:/].*$##')"
  report OK repo-remote "$remote (host: $host)"
  case "$host" in
    github.com)
      if have gh && gh repo view >/dev/null 2>&1; then
        report OK repo-tracker "gh repo view works"
      else
        report FAIL repo-tracker "gh cannot see this repo"
      fi
      ;;
    gitlab.com|gitlab.*)
      report WARN repo-tracker "GitLab remote: preflight does not check glab"
      ;;
    *)
      if have fj && printf '%s\n' "${fj_hosts:-}" | sed 's/:[0-9]*$//' | grep -qxF "$host"; then
        if fj repo view >/dev/null 2>&1; then
          report OK repo-tracker "fj repo view works"
        else
          report FAIL repo-tracker "fj is logged in to $host but cannot see this repo"
        fi
      else
        report FAIL repo-tracker "no CLI is logged in to $host (expected fj for Forgejo)"
      fi
      ;;
  esac
fi

root="$(git rev-parse --show-toplevel)"
if [ -f "$root/docs/agents/issue-tracker.md" ] && grep -q '^## Agent skills' "$root/CLAUDE.md" 2>/dev/null; then
  report OK repo-setup "docs/agents/ and the Agent skills block in CLAUDE.md exist"
else
  report WARN repo-setup "repo not configured for the engineering skills"
fi
