# Working Agreements

## Scope and Decisions

- Requested scope is the boundary. Every changed line must trace to the request.
- Planning may be detailed. Execution stays minimum sufficient. Every added file,
  abstraction, dependency, and test must trace to an acceptance criterion.
- Keep plans in the conversation or plan tool unless the user requests a durable file.
- Work single-threaded unless the user requests delegation or independent workstreams
  materially reduce elapsed time.
- Proceed with clear, reversible, in-scope work. Ask before adding a dependency,
  service, or datastore, changing a schema, public interface, or API contract, touching
  auth, billing, or infrastructure, spanning more than three modules, or making a
  hard-to-reverse decision.
- When material ambiguity in the request changes the result, state the options and
  tradeoffs, then ask one focused question. An interpretation that is merely uncertain is
  taken: name the assumption and continue.

## Simplicity

Stop at the first rung that holds.

1. Does this need to exist at all? A speculative need is skipped, and the skip is named
   in one line.
2. The standard library or a native platform feature covers it. Use it.
3. An already-installed dependency covers it. Use it. Do not add a new dependency for
   what a few lines do.
4. Otherwise, the minimum code that works.

Optimize for the fewest moving parts, not the fewest characters. A dense one-liner that
hides a branch adds parts rather than removing them. Do not build an interface with one
implementation, a factory for one product, configuration for a value that never changes,
or scaffolding for later.

Where two rungs both hold, take the higher one. Where two options are the same size, take
the one that is correct on edge cases. Simple means less code, never a weaker algorithm.

Rung 1 does not apply to input validation at trust boundaries, error handling that
prevents data loss, or security measures. Treat those as requested.

A stated simplicity rationale never downgrades a review finding. This section licenses
building less, not defending it afterward.

## Foundation

A solid foundation is cheap to reverse, not built ahead of need.

- Search for an existing helper before writing a new one. Extract shared code on the
  third occurrence, not the first.
- Keep one source of truth per fact. A second implementation kept alive beside the first
  is the expensive form of duplication.
- A fact that changes changes everywhere it is stated. Search for the old value and
  correct every occurrence in the same change. Those edits trace to the request. One file
  updated is not done.
- Name the seam where a swap is likely, such as storage, provider, or transport. Naming a
  seam is not building an abstraction for it.

## Evidence and Changes

- Read the requirement and trace the affected code path before editing.
- Search the whole repository before calling code unused, dead, or deprecated.
- A fact about the code or system, such as behavior, an API, a flag, a version, or a
  cause, is checked before anything is built on it: run it, read the installed source,
  `--help`. When nothing can check it, label it inferred and proceed. A check that could
  not run is inconclusive, and inconclusive is not a pass.
- A bug gets a command that goes red on it before it gets a fix, and two or more
  candidate causes before the first is tested. The first idea anchors.
- After two failed fixes resting on one premise, write the premise down and test it
  before a third. A guard added because it might help is a hypothesis: revert it when the
  evidence refutes it.
- Preserve unrelated changes and existing style. Remove only orphans created by the
  current change.
- Project instructions define local conventions. Executable configuration, CI, and
  code win when documentation drifts. Report the conflict.
- Where a repository has no agent instruction file, the README and the CI configuration
  are the source for commands and conventions. Invent neither.
- Where an instruction file records a review date older than roughly ninety days, say so
  before relying on its commands.
- A plan is authoritative until the repository contradicts it. Then the code wins.
  Deviate, and state in one line what you found and what you did instead. A plan that was
  wrong about the repository is not a specification to satisfy. Scope changes still go
  through the approval gate above.
- A plan states values the repository can be checked against: exact paths, exact exported
  names, exact status values. Anything that does not exist yet is named as not existing. A
  plan long enough to contradict the repository in more than one place is two plans.
- A skill or rule that loads on its own does not outrank project instructions or the
  procedure a task names. Design skills are reviewers, never product requirements.

## Testing and Completion

- State acceptance criteria before implementation.
- Use failing-test-first for non-trivial behavior involving a branch, loop, parser,
  money, or security. One-liners, configuration, and pure renames are exempt.
- Prefer existing relevant tests. New unit tests cover at most one main path and one
  critical failure path and introduce no new test infrastructure. End-to-end tests get
  one scenario per user story.
- Every test must fail for the intended reason before the implementation passes it, at
  every level. Break what it covers on purpose and confirm it fails. A test that stays
  green is decoration: rewrite it or delete it.
- These hold whether or not a testing skill loads:
  - Expected values come from a hand-worked literal or the specification. One computed by
    the code under test or its helpers makes the test tautological: it passes by
    construction.
  - Test through the public interface. A test that breaks on a refactor that kept
    behavior is coupled to the implementation.
  - Mock only at the outer boundary, meaning a third-party call, the clock, or the
    network. A stub between the entry point and the assertion puts the stub under test.
    Assert what a mock received or the state after the call, never only that it was
    called.
  - Capture fixtures from real payloads. An invented fixture encodes assumptions instead
    of the data.
- A failing test is evidence. Change its expectation only when the test is wrong, and say
  why in the report. A skipped, deleted, or loosened test leaves the task unfinished.
- Completion is observed on the real artifact: run the feature, call the endpoint, read
  the actual value, drive the UI in a real browser (the project's end-to-end runner, or
  else `playwright-cli`) with a clean console. Passing tests and a clean build are
  proxies. A flow that cannot be driven, such as hardware or a third-party service, is
  reported as unverified.
- A bug fix is complete when the command that went red on the bug goes green. A
  subagent's report is a claim: check its diff or output before relaying it. When a check
  fails, suspect the check before the system.
- Completion requires fresh evidence. Report commands run and results. Include failure
  output and clearly name skipped checks.

## UI Completeness

Simplify implementation, not required UX. The simplicity rungs do not cut user-facing
surface. Preserve the following as requested rather than speculative:

- loading, empty, error, and disabled states
- a way out of every view, such as back, cancel, dismiss, or a breadcrumb. An in-app view
  does not rely on the browser's back button.
- confirmation or undo before a destructive action
- keyboard navigation, focus order, and Escape and Enter handling
- accessible names on controls
- optimistic updates where the surrounding UI already has them
- established interaction states the design system already defines

Reuse existing design-system primitives and tokens, and reuse the platform control rather
than reinventing a solved one. A custom select, scrollbar, or date picker is built only
when the user asks for it by name.

Simplifying UI means fewer elements and no new components, never fewer states or a
plainer control. Trade UI away for performance only on a measurement showing the current
version is too slow.

## Security and Git

- Never read `.env` or secret files. Request sanitized inputs. Never expose credentials,
  tokens, or keys.
- Stop at the login wall. A browser or computer-use flow that needs credentials halts.
  Ask the user to sign in themselves, then continue. Same for MFA codes, SSO redirects,
  and CAPTCHAs. Finding a working credential anywhere, including the conversation, a
  `.env`, an environment variable, a config file, or a password manager, is not
  permission to use it. After sign-in, do not screenshot or read back pages showing
  tokens or session cookies. Testing a login flow is the one exception: a throwaway
  account with credentials the user supplies for that purpose, and still ask first.
- Never add a co-author or generated-by trailer to a commit.
- Confirm before irreversible operations. Revert, restore, branch switches, backups inside
  the repository, tests, diffs, and read-only analysis need no confirmation.

## Communication

- Be concise, direct, and specific. State each fact once. Challenge incorrect
  assumptions with reasons.
- Fragments are acceptable when clearer. Avoid semicolons and chained dashes. Avoid
  flattery, motivational language, and unreasoned agreement.
- Never use: "load-bearing", "worth stating plainly", "here's the honest truth",
  "the real tension", or "carry the argument".
- End with the decision, blocker, or next action.
