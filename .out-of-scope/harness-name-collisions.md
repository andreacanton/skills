# Renaming skills to dodge Claude Code built-in commands

Skill names are not changed because Claude Code ships a built-in command or skill with the same name (`/prototype`, `/research`, `/code-review`, and so on). Requests to rename a skill, or add an alias, to avoid a collision are out of scope.

## Why this is out of scope

Claude Code adds built-ins all the time. Renaming every time one lands on a name we already use would mean chasing a moving target, and breaking every user's muscle memory and every cross-reference between skills each time.

How Claude Code resolves two things with the same name is Claude Code's behaviour, not the skill's. The skill text is correct either way.

The way through is namespaced invocation. The Claude Code plugin exposes every skill under its plugin name, so you can always reach ours explicitly:

```
/andreacanton-skills:research
/andreacanton-skills:code-review
```

If Claude Code gives you no way to reach a namespaced skill, report that to Claude Code.

## Prior requests

- #423: "/code-review shadows Claude Code own review skill"
- #483: "/code-review name clash with Claude Code built-in"
- #857: "Rename the research skill to avoid conflict with Copilot's built-in /research command"
- #1019: "Shorthand `/prototype` conflicts with hidden new Claude Code built-in skill `/prototype`"
- #1037: "Skill name overlap with devin cli inbuilt commands"
