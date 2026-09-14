# project-init

Generate or audit a repository's `AGENTS.md` from evidence found in that repository.

Harness-agnostic and model-agnostic. Invoked from Claude Code as `/project-init`, from
Codex as `$project-init`, and directly by any agent that can read files.

Where this file says "ask", use whatever question mechanism the current harness provides;
with none, state the question and stop. Where it says "inspect", use that harness's
read-only file tools and do not assume a shell is available: some setups allow no shell
commands at all, and a failed shell call can abort the run partway through. Confirm what
you can call before relying on it.

Project instructions hold repository-specific guidance. Global behavior stays global.

---

## Phase 0: Safety check

Locate the repository root. No version control → treat the working directory as the root
and say so in the final report. From the root down to the working directory, check for
existing agent instruction files: `AGENTS.override.md`, `AGENTS.md`, `CLAUDE.md`,
`GEMINI.md`, `.cursor/rules/`, `.cursorrules`, `.github/copilot-instructions.md`,
`.windsurfrules`.

- **None exist** → go to Phase 1.
- **Any exists** → read it. Do not overwrite. Run Phase 1, then report what the existing
  file gets wrong or omits, propose a diff, and ask whether to patch in place, replace,
  or stop. Stop means stop.

## Phase 1: Reconnaissance

Gather evidence for every claim you will make:

- Repo root listing; manifests and lockfiles (`package.json`, `pyproject.toml`, `go.mod`,
  `Cargo.toml`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, `Makefile`,
  `requirements*.txt`). Unfamiliar ecosystem → find its manifest and lockfile by reading
  the root listing, not by assuming this list is complete.
- Monorepo and tooling config (`pnpm-workspace.yaml`, `turbo.json`, `nx.json`,
  `lerna.json`, `Cargo.toml` workspaces, `go.work`)
- Scripts: manifest scripts, `Makefile` targets, CI workflows, `justfile`, `Taskfile.yml`
- Docs: `README*`, `docs/**/*.md`, root `*.md`, and any of `architecture.md`, `design.md`,
  `spec.md`, `testing-strategy.md`, `project-context.md`
- Test layout, and any nested agent instruction files
- Environment pinning: virtualenv directories, `.tool-versions`, `.nvmrc`, container and
  devcontainer definitions
- Duplicate trees: `.worktrees/`, `.git/worktrees`, vendored or bundled copies. A
  repo-wide search hits every copy, and a hit inside one is another branch's state, not
  this one's. Find them now; an undetected second tree corrupts every search that follows.

Executable configuration, CI, and code beat prose. Read enough to verify, not everything.

**Checkpoint:** if install, lint, test, or verify commands are missing or ambiguous, ask
one focused question and stop before writing files. Otherwise omit the unsupported line
and continue.

## Phase 2: Write AGENTS.md

`AGENTS.md` goes at the repository root. In a monorepo, the root file carries what is true
everywhere and names the packages; add a nested `AGENTS.md` inside a package only when its
commands, package manager, or test contract genuinely differ from the root. A nested file
states only the difference and never restates the root.

Two independent projects sharing a repo with no root tooling is a third shape, not a
monorepo: one root `AGENTS.md`, and every command states the directory it runs from.

Include only sections that change agent behavior and that evidence supports. Delete any
section you cannot fill. Do not pad with a stack summary derivable from one manifest.

```md
# <Repo> Agents Configuration

Last reviewed: <YYYY-MM-DD>

## Project Context
- Architecture: <one paragraph, only what the file layout does not already say>
- Critical paths: <auth, billing, data pipelines, infra>, require extra review.

## Documentation Map
- Always read: <1-3 highest-signal docs>
- Read when: <scenario> → <doc path>
- Fallback: no docs beyond README → README, CI config, and code are truth.
- Where a doc above answers the question, it outranks commit messages, roadmap history,
  and any skill that fires on its own. Design skills are reviewers, not requirements.

## Commands (Use Exactly)
- Install: <command>
- Lint: <command>
- Build/Typecheck: <command>
- Unit tests: <command>
- Integration/E2E: <command>
- Pre-merge verify: <ordered sequence>
- Single test: <runner> <flags> path/to/test -t "name"

Add one line under a command only where its obvious form fails quietly — a flag that is
not optional, an invocation form that resolves imports differently, a step CI runs that
is easy to skip locally. Name what breaks and how the failure presents. A command that
behaves as it reads gets no note.

## Tooling Lock
- Canonical package manager: <name>
- Never use: <the other package managers>
- Interpreter- and toolchain-pinned invocation only (`.venv/bin/python -m ...`, `uv run`,
  `poetry run`, the version in `.nvmrc`). Never install globally. Confirm cwd and active
  toolchain before any install or test.

## Testing Contract
- What "passing" means here: <...>
- CI: <workflow> on <trigger>. <Gates merge | reports only — branch protection state>
- Intentional skips and known flaky: <...>

## Project Invariants
- <Fragile rules: coordinate systems, ID ordering, required boundary conversions>

## Definition of Done
- <project-specific merge or PR requirements>
```

### Baseline rules block: conditional, off by default

Do not inline general behavioral rules. The agent reading this file already has them from
its own global configuration, and a copy in the repo goes stale the moment that global
configuration changes.

Add a short `## Baseline Rules` block only when one of these holds:

- The repo shows evidence of more than one agent tool in use (a `.cursor/` directory,
  Copilot instructions, a committed `CLAUDE.md` alongside `AGENTS.md`), so no single
  global config reaches every agent that touches it.
- The repo is worked by agents whose global configuration the user does not control —
  open source, a client handoff, a team on mixed tooling.
- The user asks for it.

When included, keep it to roughly ten bullets, written as a distillation and never as a
verbatim copy of anyone's global file. Head the block with one line: where the reading
agent's own global rules are stricter, the stricter rule wins.

- **Think before coding.** State assumptions. Search the whole repo before calling
  anything dead. Read the code you are changing rather than inferring it.
- **Simplicity.** Does it need to exist → does stdlib or the platform cover it → does an
  installed dependency cover it → minimum code that works. Fewest moving parts, not
  fewest characters. No abstraction with one implementation.
- **Simplicity stops at correctness.** Input validation at trust boundaries, error
  handling that prevents data loss, and security measures count as requested. A stated
  simplicity rationale never downgrades a review finding.
- **Reuse before writing.** Search for an existing helper before adding one. Extract on
  the third occurrence, not the first. Keep one source of truth per fact: a fact that
  changes changes everywhere it is stated, in the same change.
- **UI is exempt from cutting.** Loading, empty, error, and disabled states; a way out of
  every view; confirmation or undo before a destructive action; keyboard navigation, focus
  order, and accessible names. Reuse the platform control rather than reinventing a solved
  one.
- **Surgical changes.** Every changed line traces to the request. Match existing style.
  Remove only the orphans your own change created.
- **Approval gates.** New dependency, service, or datastore; schema or API contract
  change; auth, billing, or infra; more than three modules; hard to reverse.
- **The code wins.** A plan or doc the codebase contradicts is not a spec to satisfy.
  Deviate, and name what you found. Flag the drift.
- **Verify before done.** Never claim complete without running the check and showing its
  output. Run existing tests before writing new ones.
- **Security.** Never read `.env` or secret files. Never echo credentials. Never
  authenticate on the user's behalf; stop at the login wall and hand it back.
- **Commits.** No co-author or generated-by trailers. Several harnesses add these
  automatically, so this one has to be stated to hold.

## Phase 3: Companion pointer files

Only when the user asks for compatibility with a specific agent tool, or the repo already
contains that tool's instruction file. Otherwise skip this phase entirely.

When it applies, the companion file holds a pointer and nothing else, so it cannot go
stale. The repo is shared, so it must not reference any path that exists only on one
machine.

| Tool | File |
|------|------|
| Claude Code | `CLAUDE.md` |
| Gemini | `GEMINI.md` |
| Cursor | `.cursor/rules/project.mdc` |
| Copilot | `.github/copilot-instructions.md` |

Each holds the pointer and nothing else:

```md
# <filename>

> Project commands, context, and invariants: `./AGENTS.md`
```

Write only the files that apply. Never duplicate project facts into them.

---

## Generation rules

1. **Never invent.** No command, version, policy, or owner without evidence. Missing
   evidence means omit the line and name the gap in your final report.
2. **Validate, do not annotate.** Check every command against the file it came from before
   writing it. Keep the verification out of the output: inline evidence tags bloat a file
   that loads every session to serve an audit that happens rarely.
3. **Canonical package manager**, decided by lockfile:
   `pnpm-lock.yaml`→pnpm · `yarn.lock`→yarn · `package-lock.json`→npm · `bun.lockb`→bun ·
   `uv.lock`→`uv run` · `poetry.lock`→`poetry run` · `Pipfile.lock`→`pipenv run`.
   Two lockfiles for one ecosystem → say so and ask; do not guess.
4. **Doc map:** 1-3 always-read entries, everything else gated on a stated scenario.
5. **No duplication.** `AGENTS.md` holds the project facts. Companion pointer files hold
   none. A nested `AGENTS.md` holds only its difference from the root.
6. **Every line earns its load.** This file is read on every session. Cut a line that
   restates what the agent would do anyway, or that a single lookup in the repo answers.
   Cache what the agent cannot find by looking: the unwritten convention, the reason
   behind a choice, the gotcha no config confesses.
7. **State what is true now, not how it became true.** Git holds the history. A dated
   entry recording that a module was built, a probe ran, or a decision was amended belongs
   in a changelog or the commit that made it. These accumulate faster than any other kind
   of line and go stale on the next change — a file that opens with current state and ends
   in a build log is the common failure of this rule, not an exception to it.
8. **Report at the end:** files changed, unresolved gaps, and checks performed. Unknowns
   belong in that report, never as invented project guidance.

## Completion criteria

- Every line in the generated file is project-specific and supported by evidence.
- Every command was validated against its source.
- No existing instruction file was changed without approval.
- The final report names every gap you chose to omit rather than guess.
