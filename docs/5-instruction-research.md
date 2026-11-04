# 5. Instruction file research

Read this before adding, cutting or restructuring global rules or skills. It records how
this setup compares with Matt Pocock's AI Hero guidance, measured studies, vendor docs and
other engineers' setups, as of 2026-11-04. Old advice expires as models change, so re-check
anything you lean on.

## Findings for this setup

**The global rules are good enough. Skills were the larger always-on load.**

Measured on 2026-11-04:

| Item | Size |
|---|---|
| `claude/CLAUDE.md` | 213 lines, about 1,900 words, 11,174 bytes |
| `codex/AGENTS.md` | 186 lines, about 1,730 words, 10,558 bytes (Codex's default limit is 32 KiB) |
| Skills in `~/.claude/skills` | 75, of which 50 can fire on their own |
| Descriptions of those 50 | about 17,900 characters (from the files, not from what loads) |

### Where Pocock holds up and where he doesn't

- **Holds up:** repo facts go stale or add nothing (ETH supports this for overviews). Module
  design and feedback loops matter, as opinion, and verification loops are the most widely
  shared advice found.
- **Doesn't apply here:** his argument targets repo facts. These global files hold behaviour
  rules a repo can't show, which is the content his own test keeps.
- **Overreaches:** "300 to 400 instructions" has no source and conflicts with the 150-200 he
  quoted a month earlier, which itself traces to a keyword-inclusion benchmark. "Makes tasks
  harder" overstates ETH, which found no significant change plus extra cost. His one-line
  setup was never tested, and the page promotes his skills.

### Changed as a result

| Change | Why | Verified |
|---|---|---|
| `.env` deny rules in `claude/settings.shared.json` | "Never read `.env`" was only an instruction, and `CLAUDE.md` is context, not enforcement | Dummy files, real `claude -p` runs: all six paths read before, `.env`, `.env.local`, `sub/.env` and a `.env` in another project blocked after, `.env.example` still read |
| `mattpocock-skills` plugin disabled on this machine | Eleven skills were listed twice. It was never in `plugins.json`, so this is not a repo change | `claude plugin list` shows it disabled |
| `project-init` README adds that neither kind of file significantly beat no file | Its study line was accurate but selective | Change is in hanseo-skills |

### Gaps in the `.env` rules

- A `.env.*` file outside the working directory stays readable, such as another project's
  `.env.local`. The carve-out for `.env.example` only works on rules relative to the working
  directory, so blocking these would also block `.env.example` everywhere.
- Claude's docs say deny rules cover built-in file tools and recognised Bash file commands,
  not `grep -r` run from that folder or a script that opens files itself. Only the sandbox
  blocks those.
- Codex has no equivalent here. Its permission profiles are beta and the sources conflict on
  syntax and enforcement, so `codex/AGENTS.md` remains the only guard.

### Left alone on purpose

- **Rule count and length.** Controlled tests found no length effect in the ranges tested, so
  cutting for its own sake isn't justified.
- **Pocock's plan rules, instruction budgets and any new anti-sycophancy line.** The existing
  rules are already procedures ("my stated cause is a hypothesis"), which adjacent studies
  favour over a stated attitude.
- **The UI section as a skill.** It counterweights the simplicity ladder, and Vercel saw a
  skill go uninvoked in 56% of cases.

### Still open

- **Skills that fire on their own.** Removing the ones not used is the remaining cut, starting
  with the grilling variants and about a dozen design skills. Uninstall rather than edit,
  since a reinstall overwrites edits.
- **The Superpowers hook.** It injects a long "you MUST invoke skills" block every session,
  and Anthropic warns piled-on emphasis makes a rule over-apply. Try a few sessions without it
  before deciding, since workflows depend on it.

### Limits

No controlled study here tested a global user-level file or an anti-sycophancy line on a
coding agent, and ETH measured only task success on Python repos. So this evidence does not
show these rules help, and it does not show they hurt. A background research agent gathered
the evidence below. The key ETH and McMillan figures, Pocock's two numbers and the Claude
permission rules were re-checked at source. The rest was not, and section 7 records how each
source was read.

# Evidence

How each source was read:

- **[R]** raw page text read directly, in full unless marked partial.
- **[F]** read through the WebFetch tool, whose model paraphrases. Numbers were not all checked against raw text.
- **[S]** search snippet or abstract only. Not a reading of the body.
- **Not read** means no claim is made about the content. See the ledger in section 7.

"Inferred" and "my arithmetic" mark my own reasoning, as opposed to what a source says.

---

## 1. Bottom line

1. **No controlled study shows that a context file raises task success overall.** The strongest study (ETH, arXiv 2602.11988) found no significant gain and about 20% more cost. It does not show harm from a short, specific human file.
2. **Agents do follow instructions.** ETH and McMillan both measure this. The cost is partly the price of compliance, so a line should change behaviour you want.
3. **The size claim is weaker than people say.** "Longer files reduce adherence" is asserted by Anthropic, Pocock and HumanLayer without data. The two controlled tests of length on coding agents found no effect within 25 to 500 lines (McMillan) and up to 2003 words (ETH). The instruction-count numbers (150-200, 300-400) come from a keyword benchmark or from no source.
4. **The recommendations that recur independently:** keep only what the agent cannot discover, keep exact commands, prune or skip generated files, move no-exception rules into hooks or linters, and give the agent a way to check its own work.
5. **Real disagreement remains on two points.** Add a rule per observed mistake (Hashimoto, Anthropic) or treat that as how files rot (Pocock). Move knowledge to skills (Pocock) or keep a pointer index always loaded (Vercel).
6. **Sycophancy:** no study tests an anti-sycophancy line in CLAUDE.md or AGENTS.md on a coding agent. Adjacent work suggests a plain "do not be sycophantic" helps moderately and can backfire, and that changing how the input is framed works better.

---

## 2. Matt Pocock

### 2.1 What he claims

| Claim | Source | Evidence offered | Type |
|---|---|---|---|
| "Never run" `/init`, and delete the output | [Never run claude /init](https://www.aihero.dev/never-run-claude-init), updated Feb 24 2026 [R] | Links arXiv 2602.11988: "Research confirms this: unnecessary context files make tasks harder" | Partly backed, see 2.2 |
| "LLMs can realistically handle around 300 to 400 instructions at a time. Bigger models push this to maybe 500." | same | None given | Unsourced |
| "Each sentence in your CLAUDE.md is an instruction" | same | None | Opinion, a useful simplification |
| Only include what is both undiscoverable and globally relevant | same | Reasoning | Opinion. ETH's conclusion is close on the first half |
| File and service references are the worst content, because they go stale | same; also [Complete guide](https://www.aihero.dev/a-complete-guide-to-agents-md), updated Jan 18 2026 [R] | Reasoning, "poison" | Opinion. ETH's finding on overviews is adjacent |
| "Trust the explore step", "strictly better than a static CLAUDE.md" | Never run init | None | Opinion |
| "My entire CLAUDE.md is: you are on WSL on Windows" | same | First-hand report | Personal setup |
| Root file minimum: one sentence, package manager if not npm, non-standard build commands. "That's honestly it." | Complete guide | Quotes HumanLayer's "~150-200 instructions" | Opinion with a secondhand number |
| Avoid "always" and all-caps forcing | Complete guide | None | Opinion. Anthropic's docs agree, also without data |
| "Your codebase, way more than your prompt or your AGENTS.md file, is the biggest influence on AI's output" | [Codebases AI agents love](https://www.aihero.dev/how-to-make-codebases-ai-agents-love), updated Feb 26 2026 [R] | Ousterhout's deep modules | Opinion |
| Plan rules: "Make the plan extremely concise. Sacrifice grammar for the sake of concision." and end each plan with unresolved questions | [My AGENTS.md file for plans](https://www.aihero.dev/my-agents-md-file-for-building-plans-you-actually-read), updated Jan 13 2026 [R] | Own use | Taste |

### 2.2 How the claims hold up

- **"Makes tasks harder."** ETH uses this as a hypothesis, drawn from extra reasoning tokens. Its success differences against no file were not significant (p = 0.87, 0.37, 0.21). "Never run init" is supported by no benefit plus extra cost. It is not supported by a significant drop in success.
- **ETH did not test his recommended setup.** It tested no file, a generated file, and developer files (mean 641 words). A one-line file plus skills was not an arm. His post also predates v2 and v3 of the paper.
- **300 to 400 conflicts with his own earlier post.** In January he quoted 150-200, from HumanLayer. In February he says 300-400 with no source. His 500 matches IFScale's benchmark maximum, where the best model scored 68%. Any link between the two is inferred, since he does not cite it.
- **Stale statement.** "Claude Code doesn't use AGENTS.md" was overtaken: [Anthropic's memory doc](https://code.claude.com/docs/en/memory) says it reads AGENTS.md directly from v2.1.277 when no CLAUDE.md or CLAUDE.local.md is present.
- **System prompt framing.** The same doc says CLAUDE.md is delivered "as a user message after the system prompt, not as part of the system prompt itself". His framing treats it as part of the system prompt's instruction load.
- **His own files.** In January he published global plan rules from "my CLAUDE.md". In February the "entire" file is one line. That may be a change of mind. Inferred, since he does not say. His skills repo has a [33-line, 559-word CLAUDE.md](https://raw.githubusercontent.com/mattpocock/skills/main/CLAUDE.md) [R] with bucket rules, a README requirement and a validate command, and an [AGENTS.md](https://raw.githubusercontent.com/mattpocock/skills/main/AGENTS.md) [R] that only points to it. So his project file is not near-empty, though those conventions plausibly pass his "undiscoverable" bar (inferred).
- **Commercial interest.** The init page promotes his skills ("One command installs all 22 skills") and a cohort, "Software Factories for Real Engineers". Weigh this, since the post argues for moving instructions to skills.

### 2.3 Skills repo

[github.com/mattpocock/skills](https://github.com/mattpocock/skills) [F for README] splits user-invoked from model-invoked skills and needs a per-repo `/setup-matt-pocock-skills`. The README makes no explicit claim about CLAUDE.md size.

His fullest writing on the subject is [writing-for-agents/SKILL.md](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md) [R, first ~11,000 chars]. It cites no data in what I read, and it is more careful than the blog posts:

- "Cache what the agent cannot find by looking: the unwritten convention, the reason behind a choice, the gotcha no config confesses."
- A doc that restates the environment is a "cache" that can go stale.
- Progressive disclosure is "Not primarily a token optimisation".
- "A prohibition earns its place only as a hard guardrail you cannot phrase positively."
- No-op test: does a line change behaviour versus the default? "settle it by running the document, not by debate".
- On pointers: "sharpen the wording first, and inline the material only if sharpening fails".

---

## 3. Measured evidence

### 3.1 Primary paper: arXiv 2602.11988

Gloaguen, Mündler-Sasahara, Müller, Raychev, Vechev. ETH Zurich and LogicStar.ai. [Abstract](https://arxiv.org/abs/2602.11988), [HTML](https://arxiv.org/html/2602.11988) [R]. v1 12 Feb 2026, v2 23 Jun 2026, v3 29 Sep 2026.

**Method**

- SWE-bench Lite: 300 tasks, 11 Python repos, no developer context files. Compared no file against LLM-generated.
- CTXbench (new): 138 instances, 12 Python repos, from 5,694 PRs, repos with at least 400 PRs and a committed context file. Compared no file, LLM-generated and developer files. Developer files: mean 641 words (min 24, max 2003), 9.7 sections. Tests are LLM-generated and manually reviewed, with 25 of 138 test cases edited.
- Agents: Claude Code with Sonnet-4.5, Codex with GPT-5.2 and GPT-5.1 mini (temp 0), Qwen Code with Qwen3-30b-coder (0.7). One sample per agent per instance.

**Success rate (%), standard error about 3 to 4**

| Dataset | File | Sonnet-4.5 | GPT-5.2 | GPT-5.1 mini | Qwen3-30B |
|---|---|---|---|---|---|
| SWE-bench Lite | None | 59.9 | 56.6 | 47.7 | 31.1 |
| SWE-bench Lite | LLM | 58.7 | 54.4 | 47.6 | 32.4 |
| CTXbench | None | 73.2 | 65.2 | 54.3 | 45.7 |
| CTXbench | LLM | 65.2 | 68.1 | 50.7 | 47.1 |
| CTXbench | Developer | 70.3 | 68.1 | 55.8 | 53.6 |

CMH p-values: SWE None vs LLM 0.87. CTX None vs LLM 0.37, None vs Dev 0.21, LLM vs Dev 0.038.

My arithmetic from the table: developer files average +2.35 points over no file, and +4.2 points over LLM files (about 7.3% relative, which fits the paper's "7% on average"). Sonnet-4.5 did best with no file, at 73.2 against 70.3, within noise.

**Steps and cost per instance**

| Dataset | File | Sonnet-4.5 | GPT-5.2 | GPT-5.1 mini | Qwen3-30B |
|---|---|---|---|---|---|
| SWE | None | 54.4 / $1.30 | 12.5 / $0.32 | 40.9 / $0.18 | 29.7 / $0.12 |
| SWE | LLM | 57.2 / $1.51 | 12.7 / $0.43 | 45.2 / $0.22 | 32.2 / $0.13 |
| CTX | None | 40.7 / $1.15 | 12.1 / $0.38 | 40.6 / $0.18 | 31.5 / $0.13 |
| CTX | LLM | 46.5 / $1.33 | 13.1 / $0.57 | 46.9 / $0.20 | 34.2 / $0.15 |
| CTX | Developer | 45.3 / $1.30 | 13.6 / $0.54 | 46.6 / $0.19 | 32.8 / $0.15 |

Permutation p for CTX: steps None-LLM 0.00004, None-Human 0.00002. Cost None-LLM 0.00064, None-Human 0.0126.

**Other findings**

- Abstract: "providing context files does not generally improve task success rates, while increasing inference cost by over 20% on average".
- Abstract: "instructions in the context files are well followed". Tool mentions change behaviour strongly: `uv` used 1.6 times per instance when mentioned against under 0.01 when not. Repo-specific tools 2.5 against under 0.05.
- Abstract: "repository overviews, although popular and recommended by model providers, are not helpful".
- Abstract: "context files are useful for specifying non-standard coding practices, any attempts to improve performance should be rigorously evaluated before deployment."
- **Length:** "no clear dependency between the success rate or the per-instance cost and the context file length" (Appendix B). Within this sample's range only.
- **When docs are removed** (excluding Claude Code for cost reasons): LLM files "consistently improve performance by 2.7% on average" and beat developer files. So generated files mostly repeat existing docs, and they help where the repo has none.
- **Reasoning tokens:** LLM files +22% on GPT-5.2 and +10% on GPT-5.1 mini (SWE). Developer files +20% on GPT-5.2 and +2% on mini (CTX).
- **Removing sections (GPT-5.2, CTX accuracy):** full 68.12, no testing 66.67 (p = .80), no overview 62.32 (p = .15), no tooling 63.77 (p = .31). No accuracy change is significant. Removing testing guidance cut cost from $0.4715 to $0.3730 (p = .023). So on this data no single section earns or loses significant accuracy, and testing guidance costs money.

**Authors' advice:** "context files don't improve coding agent performance, and should only contain specific additional instructions beyond what is already available in the codebase." And: "We therefore suggest omitting LLM-generated context files for the time being". Human files should hold only what is not in the README "(e.g., specific conventions or non-functional requirements), and be rigorously evaluated before adoption."

**Limits**

- Python only. Tasks drawn from GitHub issues and PRs. CTXbench repos are niche.
- Measures task resolution only, not maintainability, security, conventions or review burden. A file that exists to enforce house style would not show up as a gain here (inferred, follows from the metric).
- One sample per condition, confidence interval about ±4, so small real effects would be missed.
- LLM-written tasks and tests.
- Reports averages. A specific rule can still prevent a specific failure.
- Models from early 2026 or before.

### 3.2 Other studies on context files

| Study | Design | Result | Limits |
|---|---|---|---|
| [Lulla et al., 2601.20404](https://arxiv.org/abs/2601.20404) [R, partial] | 10 repos, 124 PRs, paired with and without root AGENTS.md. Codex gpt-5.2-codex | Median runtime -28.64%, output tokens -16.58%, "comparable task completion behavior" | 5 pages, one agent. Measures efficiency, not correctness. **Points the opposite way from ETH on cost** |
| [McMillan, 2605.10039](https://arxiv.org/abs/2605.10039) [R, partial PDF] | 1,650 Claude Code sessions, 16,050 functions, 2 TypeScript repos. Varied size (25, 100, 250, 500 lines), position, architecture, conflict. Target: add `// @tracked`. Mainly Sonnet 4.6 | Without a file 0 of 524 compliant. With a file 67.7%. "None of the four structural variables or three two-way interactions produces a detectable contrast". Size and conflict nulls BF10 0.05 to 0.10. Compliance falls within a session, OR 0.944 per generated function, median first omission at position 4 (post hoc). 26.2-point gap between two tasks | One trivial instruction, "an easily-detectable proxy". Single-turn `--print`. Author warns a 5,000-line file is outside the design. Position and architecture are failures to reject, not evidence of no effect |
| [Khatri, 2607.27250](https://arxiv.org/abs/2607.27250) [F] | sonnet-4-6 and gpt-5.5 Codex, 17 tasks, 3 repos, 288 runs. None, always-on, selective | Pass rates: none 53.3 / 58.8, always-on 55.6 / 56.9, selective 55.6 / 52.9 (Claude / Codex). Omnibus p 1.00 and 0.66. AGENTS.md "never converts a near-miss to a pass" | Not powered: 120 to 200 tasks needed to detect 10 points. Selective files not content-matched in two repos |
| [Vercel, Jude Gao](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals), 27 Jan 2026 [R] | Next.js 16 APIs absent from training data | Baseline 53%, skill by default 53% (not invoked in 56% of cases), skill with explicit instructions 79%, AGENTS.md compressed docs index 100%. Compressed from 40KB to 8KB. Result sensitive to skill wording | Vendor's own eval on its own framework. Sample size not stated in what I read. Tests knowledge the model lacks, not rules |
| [SkillsBench, 2602.12670](https://arxiv.org/abs/2602.12670) [S, abstract] | 87 tasks, 8 domains, 18 model-harness setups | Curated skills 33.9% to 50.5% (+16.6 points). "Focused Skills with at most three modules outperform larger or exhaustive bundles" | Not specific to coding. A snippet of [v1](https://arxiv.org/html/2602.12670v1) says self-generated skills gave no net benefit; body not read |
| [IFScale, 2507.11538](https://arxiv.org/abs/2507.11538) [R, partial] | 20 models, write a business report containing 10 to 500 required keywords | Best at 500: 68%. o3 62.8, grok-3 61.9, claude-3.7-sonnet 52.7, claude-opus-4 44.6, claude-sonnet-4 42.9. Reasoning models gemini-2.5-pro and o3 "near-perfect ... through 150 or more instructions before declining". Primacy effect peaks around 150-200 | Keyword inclusion, not coding rules. Models from mid-2025 |
| [Agent READMEs, 2511.12884](https://arxiv.org/abs/2511.12884) [S] | 2,303 files, 1,925 repos, descriptive | Test procedures 75.9%, implementation details 70.8%, architecture 68.1%, security 14.8%, performance 14.5% | Shows what people write, not what works |
| [Galster et al., 2602.14690](https://arxiv.org/abs/2602.14690) [S] | 2,853 repos, descriptive | Context files dominate, few repos use skills or subagents | Same |

**Where the 150-200 number comes from.** HumanLayer cites IFScale and admits this "hasn't been investigated in an incredibly rigorous manner". It adds "~50" instructions in Claude Code's own system prompt (their own analysis). Pocock quotes HumanLayer. So a widely repeated budget rests on keyword constraints in report writing. A keyword is not a coding rule, so applying the count to CLAUDE.md lines is an extrapolation.

**Conflict in the data on cost.** ETH finds context files cost more. Lulla finds lower runtime and output tokens. They measure different things on different repos and agents. I found no study that reconciles them.

**What was not found.** No controlled study of: nested versus single files with hard instructions, global user-level files, a near-empty file against a curated short one, effects on code quality or review burden, or long-term rot.

### 3.3 Sycophancy

No study found tests an anti-sycophancy line in CLAUDE.md or AGENTS.md on a coding agent. What exists is adjacent, mostly chat and advice.

| Study | Result | Limits |
|---|---|---|
| [Sharma et al., 2310.13548](https://arxiv.org/abs/2310.13548) [S] | Five assistants consistently sycophantic across four tasks. Humans and preference models prefer convincing sycophantic answers over correct ones a non-negligible fraction of the time | 2023 models |
| [Cheng et al., 2510.01395](https://arxiv.org/abs/2510.01395) [S] | 11 models affirm users' actions 50% more than humans. N = 1604 preregistered. Users rate sycophantic replies higher and trust them more | Social advice |
| [Ask Don't Tell, 2602.23971](https://arxiv.org/html/2602.23971v1) [R for these numbers] | GPT-4o, GPT-5, Sonnet-4.5. No-mitigation control β = 1.13. 2-step reframing as a question β = -0.55. 1-step β = 0.16. Explicit "without being sycophantic" β = 0.51. So the instruction helps, and reframing the input helps more. Non-questions draw more sycophancy than questions | Single turn, advice domains, LLM graders, factual accuracy not tested |
| [SWAY, 2604.02423](https://arxiv.org/html/2604.02423v1) [R for quoted items, F for the rest] | Six models. Broad "do not be sycophantic" gives "moderate reductions, and can backfire", with amplification on Llama. Counterfactual chain of thought (consider the answer under the opposite assumption) goes near zero. Opus 1.40 to 0.02 at high commitment. Haiku over-corrects, -0.081 to -0.374. Sycophancy rises with stated commitment | Binary outputs, temp 0, no user study. Uses few-shot examples, not a one-line rule |
| [SyPS, 2608.23837](https://arxiv.org/abs/2608.23837) [F] | Nine open-weight models. "Please make your own independent judgment rather than following my perspective." SS Δ -0.196, AITA Δ -0.042 against neutral | Open-weight models only. Placement in the prompt unclear in my reading |
| [EGDP, 2607.10411](https://arxiv.org/abs/2607.10411) [S] | **Only code-specific study found.** Code smell detection: Decision Flip Rates up to 72%, False Alignment over 90%. Evidence-first prompting cuts them to as low as 12% and 21% | Abstract only. Detection task, not agent sessions |
| [MIST, 2606.10949](https://arxiv.org/abs/2606.10949) [S] | Memory amplifies sycophancy, up to 40% higher than in-context baselines; the extraction step is the cause | Relevance to Claude's auto memory is inferred |

What this suggests (inferred, none of it tested in a coding-agent instruction file):

- A general instruction has some effect, less than structural methods, and can backfire on some models.
- Procedural instructions (state evidence first, consider the opposite assumption) do better than a stated attitude.
- Models differ. A prompt tuned for one can over-correct another.
- How the user phrases things matters: "I'm sure" draws more agreement than a question.

---

## 4. Vendors

### 4.1 Anthropic

Memory doc: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) [R to line 230 plus searches]. Best practices: [code.claude.com/docs/en/best-practices](https://code.claude.com/docs/en/best-practices) [R, parts].

**Size**

- "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence". No data cited. McMillan found no such effect from 25 to 500 lines for one trivial instruction.
- "every line in it takes a little of Claude's attention on every task".
- Skips a file over 4 MiB. Warns above the recommended length. `/doctor prompt-audit` from v2.1.283.
- Auto memory: first 200 lines or 25KB.

**Include**

- Exact test, typecheck, lint and single-test commands.
- Places where the code misleads.
- Decisions not in the repo.
- "Anything you've had to correct twice already".
- Memory doc's add-when list: same mistake a second time, code review catches something, the same correction repeats, a new teammate would need it.

**Exclude**

- Derivable content. `/doctor` cuts directory layouts, dependency lists and architecture overviews, and keeps pitfalls, rationale and conventions that differ from defaults.
- "Describe your architecture and file layout in CLAUDE.md" is listed under things you can stop doing: "Claude reads the repo itself."
- Multi-step procedures, or things relevant to one part of the codebase: move to a skill or path-scoped rule.
- Personal preferences go in CLAUDE.local.md.

**Internal inconsistency:** the memory doc's examples include "API handlers live in src/api/handlers/" and project layout, while best practices says stop describing layout. Anthropic's own docs differ here.

**`@imports`**

- `@path`, max depth four hops. Imports "don't reduce its context cost", since they expand alongside the file. So imports organise content without saving context.
- External imports in project files show an approval dialog. User-scope imports do not, except in Cowork.

**Loading**

- Concatenated root down, not overriding. Subdirectory files load on demand.
- Contradictions "may pick one arbitrarily".
- Delivered "as a user message after the system prompt". "Claude treats them as context, not enforced configuration".
- HTML comments are stripped.
- Project-root file survives compaction. Nested ones reload on demand.

**AGENTS.md:** read directly from v2.1.277 when there is no CLAUDE.md or CLAUDE.local.md in the working directory or above. `~/.claude/CLAUDE.md` does not count toward that check. To use both, import AGENTS.md from CLAUDE.md. Setting: `claude-md-and-agents-md`.

**Hooks versus instructions**

- "If something has to happen every time, make it a hook, a deny rule, or a managed setting. CLAUDE.md is for guidelines".
- "If you keep adding emphasis to a CLAUDE.md line and Claude still misses it, that's a sign the line belongs in a hook. The reverse holds too".
- "Most of the time, you want Claude to decide".
- "If you ever find yourself at forty of them, most are probably preferences".
- Prompt and agent hooks are not deterministic.

**`/init`:** "/init generates a starting version... the work is mostly removing lines". Tip: "Refine from there with instructions Claude wouldn't discover on its own". This directly disagrees with Pocock's "never", though both agree on the end state.

**"What you can stop doing"**

- IMPORTANT and ALL CAPS: "piling on emphasis mostly makes Claude over-apply the rule".
- `think hard`.
- "keep going... don't be lazy": "more likely to cause over-work".
- Manual context-window management, noting "Most current models have a 1M-token window".

**Skills:** name and description load every session, full text on demand. "The CLAUDE.md rule applies to skills too."

**Engineering blog:** [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) [R, partial]: "smallest possible set of high-signal tokens", the "right altitude" between brittle logic and vague guidance, "attention budget", "context rot". It describes Claude Code as a "hybrid model": CLAUDE.md up front, glob and grep just in time.

None of the Anthropic guidance above cites measurements in the text I read.

### 4.2 OpenAI Codex

[AGENTS.md guide](https://learn.chatgpt.com/docs/agent-configuration/agents-md), redirected from developers.openai.com/codex/guides/agents-md [F]:

- **Global:** `~/.codex` (or `CODEX_HOME`), `AGENTS.override.md` else `AGENTS.md`, first non-empty.
- **Project:** walks from root to working directory, at most one file per directory, in the order override, AGENTS.md, then `project_doc_fallback_filenames`.
- **Merge:** concatenated root down, so later files override.
- **Size:** `project_doc_max_bytes`, default 32 KiB. Codex stops adding files at the limit. If truncated, raise the limit or split.
- Rebuilt once per run. The doc gives commands to verify what loaded.

Anthropic gives a soft target in lines. Codex enforces a hard byte limit. Different mechanisms.

[OpenAI's harness engineering post](https://openai.com/index/harness-engineering/): **not read** (HTTP 403, then a JavaScript and cookies wall). Secondary sources attribute a roughly 100-line "map" AGENTS.md to it. I did not verify this.

### 4.3 agents.md

[agents.md](https://agents.md/) [F]:

- No required fields. Suggests overview, build and test, style, testing, security, PR sections.
- Nearest file wins. Chat prompts override.
- Reports OpenAI's main repo has 88 AGENTS.md files, and over 60k projects use the format.
- No size guidance. Now under the Agentic AI Foundation at the Linux Foundation.
- Its suggested overview section is the content ETH finds unhelpful. Anthropic also says not to describe the layout.

---

## 5. First-hand setups

| Person | Source | Setup and position | Evidence |
|---|---|---|---|
| Mitchell Hashimoto | [My AI adoption journey](https://mitchellh.com/writing/my-ai-adoption-journey), Feb 5 2026 [R]; [Ghostty AGENTS.md](https://raw.githubusercontent.com/ghostty-org/ghostty/main/AGENTS.md) [R, first 3500 chars] | "anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again". "Each line in that file is based on a bad agent behavior, and it almost completely resolved them all". Pairs rules with programmed tools. Ghostty's file has commands, directory structure, "Never create an issue. Never create a PR." | First-hand anecdote on one large project |
| Thorsten Ball | [How I prompt](https://thorstenball.com/talks/how-i-prompt/), Laracon US 29 Jul 2026, auto transcript [R, first third plus passages] | No MCP servers, "one or two skills", no frameworks, no custom slash commands. Puts AGENTS.md files around the code: "you can leave like trails". Root has dev server and browser automation commands, the Storybook folder has its own. "This to me is like the ultimate way to prompt." Moves "how" out of prompts into the codebase | First-hand demo: one prompt, 15 minutes, worked |
| Armin Ronacher | [Agentic coding](https://lucumr.pocoo.org/2025/6/12/agentic-coding/), Jun 12 2025 [R, most]; [Pi](https://lucumr.pocoo.org/2026/1/31/pi/), Jan 31 2026 [R, passages] | 2025: invest in fast tools, Makefile, logging, "the dumbest possible thing that will work". Warned the post would "age very poorly". 2026: uses Pi with its very short system prompt, "I use tons of skills", "hand-crafted by my clanker", no community skills, no MCP. The agent maintains its own tools | First-hand |
| Mario Zechner | [Pi coding agent](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/), Nov 30 2025 [R, passages] | Minimal harness prompt. Only AGENTS.md, global and project, is injected | Own tool |
| Kent Beck | [Augmented coding](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes), Jun 25 2025 [R] | Long prescriptive system prompt: plan.md, TDD, Tidy First, role ("You are a senior software engineer"), "Follow this process precisely". Warns of loops, unrequested functionality, "cheating, for example by disabling or deleting tests" | First-hand on one project. Older models. Sponsor disclosed |
| Geoffrey Huntley | [Ralph](https://ghuntley.com/ralph/), 14 Jul 2025 [R, partial] | `while :; do cat PROMPT.md \| claude-code ; done`. "one thing per loop". "Each time Ralph does something bad, Ralph gets tuned - like a guitar". "There is no such thing as a perfect prompt". Tests as back pressure | First-hand. Claude 3.7 era |
| Simon Willison | [Red/green TDD](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/) [R]; [Agentic loops](https://simonwillison.net/2025/Sep/30/designing-agentic-loops/) [R, partial]; [Claude Skills](https://simonwillison.net/2025/Oct/16/claude-skills/) [R, passages] | "Use red/green TDD" is "a pleasingly succinct way" to get the behaviour. Each skill "only takes up a few dozen extra tokens". Prefers CLI tools over MCP. I did not find his own global instruction file | First-hand practice |
| Peter Steinberger | [Shipping at inference speed](https://steipete.me/posts/2025/shipping-at-inference-speed), Dec 28 2025 [R, ~7000 of 19,408 chars plus searches] | "my global AGENTS.MD" holds tool and docs-reading instructions. Plan mode is "a hack". "most code I don't read" | First-hand |
| Kyle, HumanLayer | [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md), Nov 25 2025 [R] | Under 300 lines as "general consensus", their root under sixty. WHAT, WHY, HOW, including "Give Claude a map of the codebase". `agent_docs/`. "Prefer pointers to copies". "Never send an LLM to do a linter's job". Logging proxy showed a reminder that files "may or may not be relevant". Don't use `/init`. "Your mileage may vary" | Their proxy observation plus opinion |
| Addy Osmani | [AGENTS.md](https://addyosmani.com/blog/agents-md/), Feb 23 2026 [R, most] | "treat AGENTS.md as a living list of codebase smells". Filter: "can the agent discover this?". Warns of anchoring on mentioned items. Prefers fixing the problem | Secondary on papers. His ETH numbers ("-2-3%", "about 4%") come from an early version and differ from v3 |
| Birgitta Böckeler | [Context engineering for coding agents](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html), 05 Feb 2026 [R] | "build context like rules files up gradually". Old rules may stop being needed as models improve. "there are no unit tests for context engineering". Warns of "Illusion of control" and copied setups | Practitioner survey |

Boris Cherny (Claude Code): **not read at source.** Secondary sites quote "Anytime we see Claude do something incorrectly we add it to the CLAUDE.md" and about 2,500 tokens. See [this secondary](https://zhangyuliang1994.github.io/en/blog/boris-claude-code-tips) [S]. Treat as unverified.

### Disagreements

**With Pocock**

- **Adding a rule per mistake.** Hashimoto: each line comes from a bad behaviour and it "almost completely resolved them". Huntley and Anthropic say similar. Pocock's [Complete guide](https://www.aihero.dev/a-complete-guide-to-agents-md) warns this exact loop makes the file a "ball of mud" that "actually hurts agent performance" (no data). These can be reconciled only partly: Hashimoto's strength is pairing rules with tools, and Anthropic adds pruning. No data decides it.
- **Repo maps.** HumanLayer and Ghostty include one. Pocock, Anthropic best practices and ETH say no. ETH's data is the only measurement, and it favours Pocock on average. Note ETH's no-overview arm lost points that were not significant (62.32 against 68.12, p = .15).
- **Global rules.** Steinberger and Beck keep substantial global instructions. Pocock's February post has one line, though his January post did not.
- **Skills versus always-on.** Vercel's result: a skill went uninvoked in 56% of cases and always-on won. Khatri found no difference between arms. SkillsBench found curated skills help. Reconciling these (inferred): always-on pointers suit knowledge the model does not know it lacks, while skills suit action-specific workflows, which Vercel itself concedes.
- **`/init`.** Anthropic: start there and prune. ETH: omit generated files for now. Pocock and HumanLayer: never. ETH's cost finding applies to unedited generated files, so it does not settle "generate then cut hard".
- **Emphasis and prohibitions.** Pocock avoids them. Hashimoto's and Ghostty's rules use "Never". Beck writes "precisely". Anthropic warns against pile-ups and McMillan notes phrasing was not varied. Untested.

**Among the others**

- **Nested files:** Ball and OpenAI's repo (88 files, per agents.md) use many. McMillan found no compliance gain from nesting and says the design "does not test multi-file configuration as a remediation". Vendors support both.
- **Short global prompt versus process prompt:** Ball and Ronacher run minimal, while Beck and Huntley use explicit process prompts. Differences in era and model are a likely factor (inferred).
- **Plan mode and reading code:** Steinberger drops both. Hashimoto splits planning from execution. Pocock treats plans as central.
- **Community skills:** Ronacher writes his own. Pocock publishes a set.

---

## 6. Recurring recommendations versus taste

### Recurs across independent sources

| Recommendation | Who | Measured? |
|---|---|---|
| Keep only what the agent cannot discover | ETH, Anthropic, Pocock, Osmani, HumanLayer in part | Partly. ETH shows overviews do not help |
| Include exact commands, especially non-obvious ones | Anthropic, Hashimoto/Ghostty, Ball, HumanLayer. Pocock if non-standard | Partly. ETH: tool mentions change behaviour, but removing tooling text was not a significant loss |
| Do not keep generated files unedited | ETH, Pocock, HumanLayer, Osmani. Anthropic allows them as a start | Yes on cost. No significant success change |
| No-exception rules go to hooks, linters or CI | Anthropic, HumanLayer, Hashimoto, McMillan's recommendation | Indirect. McMillan: 67.7% compliance on one simple rule at the matched configuration, falling within a session |
| Give the agent a way to verify: tests, tools, logs | Hashimoto, Willison, Beck, Ronacher, Huntley, Pocock, Anthropic | Not as a controlled comparison here. Very wide agreement |
| Load detail on demand | Pocock, HumanLayer, Anthropic, Osmani, Steinberger, Ball's nested files | Mixed. SkillsBench for, Khatri null, Vercel against skills for knowledge. McMillan null on nesting |
| Grow the file from observed failures rather than up front | Hashimoto, Huntley, Anthropic, Böckeler, Cherny (secondary) | No. Pocock dissents on the risk |
| Test your file rather than assume | ETH, Vercel, Pocock's no-op test, Böckeler's admission that there are no unit tests | No method is standard |
| Avoid emphasis as a fix | Anthropic, Pocock | No, and practitioners still use "Never" |
| Short file | Nearly everyone | **The advice recurs, but the reason given (adherence) is not supported in tested ranges.** The cost reason is supported by ETH, though ETH's cost effect did not track length |

Independence caveat: several of these sources read each other. Pocock quotes HumanLayer, Osmani summarises ETH, and HumanLayer cites IFScale. Counts overstate independent confirmation. Vendors also have product interests.

### One person's taste, or unsupported

- A one-line CLAUDE.md (Pocock). Not tested anywhere.
- "Sacrifice grammar" in plans (Pocock).
- 300 to 400 or 150-200 as a budget for CLAUDE.md lines.
- Under 60 lines (HumanLayer's own), under 200 (Anthropic, no data), under 300 ("general consensus"). Treat these as round numbers.
- Role prompts and "Follow this process precisely" (Beck).
- Effect in TypeScript (Pocock), Go (Ronacher).
- Skipping permission prompts or YOLO (Ronacher; Willison sandboxes it).
- Plan mode is "a hack" (Steinberger).
- Not reading most code (Steinberger).
- Avoiding negation (Pocock). Osmani's anchoring warning is adjacent, but neither has measurement.

### What the evidence does not cover

- Long-term effects: rot, review burden, code quality.
- Rules about behaviour and communication, as opposed to task resolution. ETH and Khatri measure pass rates, so a rule about how an agent reports would be invisible to them.
- Global user-level files. All controlled studies here test repo-level files.
- Newest models. Results may not transfer, and Anthropic and Böckeler both note that old advice expires.

---

## 7. Read ledger

**Read directly (full or as marked):** Pocock's four posts, his CLAUDE.md, AGENTS.md and writing-for-agents (part). ETH paper. IFScale (part). Lulla (part). McMillan (part). Vercel. Anthropic memory (part) and best practices (part). Anthropic engineering post (part). HumanLayer. Hashimoto. Ghostty AGENTS.md (part). Ronacher 2025 (most) and 2026 (passages). Zechner (passages). Beck. Huntley (part). Willison, three posts (part or passages). Ball (part). Steinberger (part). Osmani (most). Böckeler (Feb). Ask Don't Tell (coefficients). SWAY (quoted passages).

**Read through WebFetch's paraphrasing model, numbers not all checked in raw text:** Khatri. SyPS. Rest of SWAY. OpenAI Codex guide. agents.md. Pocock skills README.

**Abstract or snippet only:** SkillsBench (v1 snippet not read). Agent READMEs. Galster. Sharma. Cheng. EGDP. MIST.

**Not read:**

- [openai.com/index/harness-engineering](https://openai.com/index/harness-engineering/): blocked, 403.
- Boris Cherny's posts and the YC Lightcone interview: not reached, secondary only.
- "How Anthropic teams use Claude Code": not found.
- Böckeler's later harness articles, including [harness engineering](https://martinfowler.com/articles/harness-engineering.html). "Are Harnesses Worth the Cost?" could not be confirmed to exist: a guessed URL returned nothing and search did not find it.
- Clayton Farr's [ralph playbook](https://claytonfarr.github.io/ralph-playbook): unread, so the "60 line AGENTS.md" attribution to Huntley is unverified.
- arXiv 2505.23840 and the ICML 2026 item [Why Inoculation Prompting Fails on Sycophancy](https://icml.cc/virtual/2026/80031): search hits only.
- Arize prompt learning (+5.19%, +10.87%) and ACE (12.3%): seen only through Osmani, not used as evidence.
- Willison's compound engineering section: fetch returned almost nothing.
