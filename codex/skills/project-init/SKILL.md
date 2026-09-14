---
name: project-init
description: Use when explicitly initializing or auditing project-level agent instructions for a repository.
---

# Project Init

Read `~/.agent-shared/project-init.md` and follow it exactly. It is the
canonical procedure, shared with the Claude Code install so both produce the same file.

Harness notes for this run:

- Inspect repository evidence with `rg --files` and file reads.
- Ask at most one focused question, and only when the missing information changes the
  resulting file.
