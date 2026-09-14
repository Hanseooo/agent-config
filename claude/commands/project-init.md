---
description: "Generate project AGENTS.md from repo evidence. Usage: /project-init [project context]"
---

Project context: $ARGUMENTS

Read `~/.agent-shared/project-init.md` and follow it exactly. It is the
canonical procedure, shared with the Codex install so both produce the same file.

Harness notes for this run:

- Ask via `AskUserQuestion`.
- Inspect with Glob and Read, never shell. Bash is not in this machine's permission
  allowlist, so `ls`/`cat`/pipes prompt or abort mid-run, and `2>/dev/null` creates a file
  literally named `null` on Windows.
