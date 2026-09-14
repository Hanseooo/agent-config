---
name: feature-workflow
description: The standard build loop for one feature or change that needs a plan.
disable-model-invocation: true
---

# Feature Workflow

Superpowers walks the route. `~/.claude/CLAUDE.md` keeps it from bloating.

Four of its sections gate every step below. Read them first. Cite them by name, never
by number — they renumber, and a stale `§5` points at the wrong rule silently:

- **Simplicity** — the ladder, and the correctness carve-out that bounds it.
- **UI Is Exempt From Cutting** — what the ladder may not touch.
- **Verification and Tests** — fixtures, mocking boundary, mutation check.
- **Security** — the login wall.

| Situation | Start at |
|---|---|
| Bug or small fix | step 3, `superpowers:systematic-debugging` first |
| Spec or plan already decided | step 1 |
| Cannot yet name the questions | stop. `superpowers:brainstorming` first, then return |

---

## 1. `superpowers:writing-plans`

One plan per slice. Turns "what" into "in what order, touching which files".

Skip `superpowers:brainstorming` when a spec already decided it. Keep it for
implementation choices nothing has reached yet.

The plan states values the repo can be checked against: exact paths, exact exported
names, exact status values. Anything that does not exist yet is named as not existing.
A plan long enough to contradict the repo in more than one place is two plans.

## 2. The cut gate

**Before any code.** Read the plan against the Simplicity ladder.

The plan is where speculative implementation first appears, and cutting a plan step
costs nothing where cutting shipped code costs a rewrite. Kill speculative abstractions,
new files, new dependencies, config for values that never change.

Bounded on both sides. The ladder does not cut input validation, error handling that
prevents data loss, or security measures — that is Simplicity's own carve-out. It does
not cut user-facing surface at all — that is the UI section.

## 3. `superpowers:executing-plans` + `superpowers:test-driven-development`

TDD's "simplest code to pass" and the ladder agree. Where they don't, see Resolved
conflicts.

A plan the repo contradicts is not a spec to satisfy. Deviate, and name in one line what
you found and what you did instead.

A bug instead of a plan → `superpowers:systematic-debugging` first.

## 4. Real-world E2E

Unit, lint, and API tests prove the pieces. This proves the use case.

**Cases come from the spec's numbered user stories.** One story, one scenario. The
matrix is already written; don't re-invent it at test time. No spec → enumerate the
user-visible outcomes first.

**Shape, nothing stubbed between entry and assertion:**

```
captured fixture → the real endpoint/handler → real processing → hand-derived expected output
```

Fixtures, mocking boundary, and the mutation check live in CLAUDE.md's Verification
section. The mutation check applies here too: break what the test covers on purpose and
confirm red. E2E is where green-by-construction hides best.

**Edge cases, enumerated rather than imagined:** empty / zero / one / many · malformed
and wrong-type input · unauthorized and expired auth · slow, failed, and partial
network · duplicate and concurrent submission · unicode, very long strings,
injection-ish payloads · offline or interrupted mid-flow.

**Driver by target:**

| Target | Driver |
|---|---|
| Web app in a real browser session | `claude-in-chrome` |
| Desktop or Electron app | Playwright over CDP |
| HTTP service, CLI, worker | the project's own runner against a real process |

Check the project's instruction file first. Some projects forbid one of these, and
that overrides this table.

`claude-in-chrome` against a live system is a probe, not a suite: one-shot,
non-deterministic, real auth and real third-party state. Anything it catches becomes
a committed, re-runnable spec. A finding that lives only in a transcript protects
nothing tomorrow. Credentials stop at the login wall — CLAUDE.md's Security section.

## 5. `superpowers:verification-before-completion`

Run every command, read the output, then claim done.

## 6. Review: complexity, then correctness, then security

`/simplify` → `/code-review` → `/security-review`. Deleting code first means less to
review, and security audits the shape that actually ships.

The scopes are disjoint by design, so skipping one leaves a real gap:

| Pass | Covers | Excludes |
|---|---|---|
| `/simplify` | over-engineering, dead flexibility, reuse, altitude | bugs, security |
| `/code-review` | correctness bugs, efficiency | security |
| `/security-review` | injection, authn/authz, secrets, crypto, input validation, TOCTOU, deserialization, XSS, supply chain | DoS, rate limiting, resource exhaustion |

**`/simplify` applies its fixes; the other two only report.** Run it on a clean tree so
its diff *is* the report, and read that diff before committing. Over uncommitted work it
buries your changes in its own. `/code-review` runs without `--fix` for the same reason.

**Gate the security pass.** Three review passes on a CSS tweak is what the Simplicity
ladder exists to prevent. Run it when the diff touches:

- auth, sessions, tokens, or permission checks
- input parsing, deserialization, or file/path handling
- shell or SQL construction, or anything building a command string
- crypto, secrets, or credential storage
- a network-facing handler, or a new dependency
- whatever the project's `AGENTS.md` names as a trust boundary

In doubt, run it. Security measures are the ladder's stated carve-out, never a cut.

Acting on findings → `superpowers:receiving-code-review`. It holds the YAGNI-defense
procedure: grep for real usage before implementing a reviewer's suggestion.

## 7. `superpowers:finishing-a-development-branch`

Merge, rebase, or abandon. Decided once.

---

## Resolved conflicts

Fixed rulings. Do not re-decide these per task.

| Conflict | Ruling |
|---|---|
| Simplicity ladder vs UI surface | **UI wins.** Rung 1 does not apply there. |
| Simplicity vs TDD on a trivial change | **Simplicity wins**, and only there. CLAUDE.md's Verification section names the exemption: one-liners, config, pure renames. TDD everywhere else. |
| An implementer's "left it per YAGNI" vs a reviewer's finding | **The reviewer wins.** A stated rationale never downgrades a finding's severity. The ladder licenses building less, not defending it afterward. |
| A skill that auto-invokes vs the skill a step names | **The named skill wins.** `codebase-design`, `domain-modeling`, `research`, `prototype`, `grilling`, `tdd`, `diagnosing-bugs`, `code-review`, and `resolving-merge-conflicts` all auto-invoke and overlap steps here. Use what the step names, not what fires. |

## Failure modes

- **Skipping the cut gate.** The plan's speculative steps reach code, where removing
  them costs a rewrite instead of a deleted line.
- **The ladder reading a loading state as speculative.** The UI section exists because
  rung 1 cannot tell a speculative abstraction from a required state.
- **An E2E test nobody watched fail.** Green-by-construction hides best at this level.
- **Running `/simplify` over uncommitted work.** It applies what it finds, and you lose
  the clean diff that would have been the report.
