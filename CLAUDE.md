# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A plugin containing one skill, `refactoring`, at `skills/refactoring/`. It encodes Martin Fowler's
*Refactoring* (2nd ed.; Korean translation 『리팩터링 2판』, 한빛미디어) so an agent can refactor code the way the
book prescribes. There is no application code or build — the deliverable is the Markdown itself. `scripts/check.sh`
is the only static check (see Invariants) and `evals/` the only behavioral one.

The repo root is simultaneously the plugin root and a marketplace for both Claude Code and Codex:

- `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` (marketplace `zeromountain`, plugin source `./`)
- `plugin.json` (Agent Plugins portable manifest, used by Codex) + `.agents/plugins/marketplace.json` (same names)

Both tools discover `skills/<name>/SKILL.md` at the plugin root, so there is one copy of the skill. `agents/` is
Claude Code-only (Codex ignores it); SKILL.md carries a fallback sentence wherever it references the agent. It is **not**
project-local to this repo (`.claude/skills/` is intentionally absent) — install it via the marketplace to use it.

Validate / test: `scripts/check.sh` runs every invariant below plus `claude plugin validate --strict .` (both Claude
manifests). For an end-to-end check,
`claude plugin marketplace add <abs path>` → `claude plugin install refactoring@zeromountain` → `claude plugin details
refactoring@zeromountain`, and `codex plugin marketplace add <abs path>` → `codex plugin add refactoring@zeromountain`
→ `codex plugin list`; both write to the user's global config, so uninstall and `marketplace remove zeromountain`
afterwards.

Everything is written in Korean with the canonical English technique name in parentheses
(e.g. `## 6.1 함수 추출하기 (Extract Function)`).

## Layout and how the pieces reference each other

Outside the skill:

- `agents/refactoring-verifier.md` — read-only subagent (Claude Code only) that takes a diff base and hunts for
  lines that are not a pure move/rename/extract, classified by the `safety.md` grey-zone list. SKILL.md step 6
  invokes it as `refactoring:refactoring-verifier`; Codex sessions do the same diff read themselves.
- `scripts/check.sh` — the invariants below as a script (exit 1 lists every failure). `scripts/bump.sh <ver>` writes
  the version to all three manifests and then runs check.sh.

All paths below are under `skills/refactoring/`.

- `SKILL.md` — entry point loaded on trigger. Two modes (진단 = report only, 적용 = edit), principles,
  a checklist-form procedure, the diagnosis report template, the smell→technique quick table, the file map
  with "when to read", prohibitions, completion report format. Technique detail is *not* here; keep it lean.
- `references/principles.md` — book ch.2 (principles), ch.4 (tests), ch.5 (catalog entry format).
- `references/smells.md` — ch.3: the 24 smells. Each smell ends with a `- → ...(6.1), ...(8.6)` line listing
  the techniques the book actually prescribes, plus the appendix-B table at the bottom.
- `references/catalog-index.md` — appendix A: the 66 techniques with section number, Korean name, English name,
  1st-edition alias, inverse, and the source list.
- `references/recipes.md` — technique chains R1–R10 (which order, why, where to commit) plus one end-to-end
  worked example. This is the file that turns the catalog into practice; when adding a technique to a chain,
  cite its section number.
- `references/safety.md` — the agent's behavior-preservation protocol: pre-flight checklist, characterization
  tests, finding every caller, grey areas that need user sign-off, commit granularity.
- `references/judgment.md` — prioritization, when to stop, over-refactoring signals, the recurring "which of
  these two techniques" choices, and how diagnosis-report ranking works.
- `references/language-notes.md` — book techniques mapped onto TS/Python/Java/Kotlin/Go/Rust/C# idioms and LSP
  tooling. Explicitly *not* book content; keep that caveat in its header.
- `references/large-scale.md` — parallel change, branch by abstraction, strangler fig, DB expand/contract
  (grounded in Fowler bliki entries, cited in the file).
- `references/catalog-*.md` — one file per book chapter 6–12. Each technique is a `## N.M 한국어 (English)`
  heading followed by `**배경**` → `**절차**` (numbered, one small step each, "테스트" as its own step) → `**예시**`.

Techniques are cross-referenced everywhere by **book section number** (`6.1`, `10.4`, …), never by page.
The numbering follows the Korean 2nd-edition table of contents exactly, and the Korean↔English mapping is
by position in that TOC.

## Evals

`evals/` holds six `claude plugin eval` cases. Three are diagnosis-mode and need no Bash:

- `diagnose-plan` — "계획 세워줘" alone must select 진단 mode: diagnosis report, zero Edit/Write.
- `two-hats` — refactor + feature request must be split into separate steps.
- `non-js` — Python fixture: must read `language-notes.md` and prescribe Python idioms, not JS class inheritance.

Three are apply-mode and grant Bash so the agent can run `node --test` (each `setup.sh` also does `git init` +
commit so steps 1 and 6 of the skill can run `git status`/`git diff`; the prompts say "커밋은 하지 마" because
there is no user to answer step 1's commit question):

- `technique-by-name` — "임시 변수를 질의 함수로" by name: must Read `catalog-encapsulation.md`, run tests ≥2×,
  follow the 7.4 mechanics, keep the `basePrice` return key.
- `no-tests` — fixture without tests: must Write a `*test*.js` before editing, deliberately break it, and freeze
  (not fix) the unknown-region behavior.
- `grey-zone-stop` — asked to remove a flag argument from a documented public API: must not touch `pricing.js`,
  propose the 6.5 migration, and end by asking.

Two commands (all three diagnosis cases carry the `diagnosis` tag; there is no exclude-tag flag):

- local, diagnosis only: `claude plugin eval . --tag diagnosis --scaffold --allow-tools Edit Write --runs 1
  --ablation none --no-publish`
- full six (CI or a machine without Docker Desktop, see below): `claude plugin eval . --scaffold --allow-tools
  Edit Write Bash --runs 1 --ablation none --no-publish --max-cost-usd 8`

`--scaffold` is required (without it the agent finds no file). Granting Edit/Write to the
diagnosis cases is what makes their `no-edits`/`no-writes` graders meaningful. Results land in `evals/results/`
(git-ignored). Measured cost: ~$0.35–0.55 per diagnosis case, more for apply cases — expect $2.5–3 for all six;
each run is a real Sonnet session executed as you, so don't put it in a loop. The threshold is 1.0: one red
grader fails the whole case, so read the grader breakdown before treating a red as a regression. First grader
to suspect on a spurious red: `read-catalog` (agent `cat`ed the file via Bash instead of Read), `wrote-tests`
(test file name without "test"), `tests-run` (agent ran a single file without the `--test` flag — the regex
covers `.test.js` but not e.g. `node run.js`).

**Bash-granting cases cannot run on a machine where `~/.docker` contains symlinks** (Docker Desktop's default
`bin/` and `cli-plugins/` layout) — the eval sandbox refuses the Bash grant outright, and `DOCKER_CONFIG` does
not bypass the check. Run the three apply cases in CI or on a machine without Docker Desktop; the three
diagnosis cases run anywhere with `--allow-tools Edit Write`. As of 1.2.0 the apply cases have been written and
their fixtures sanity-checked (`node --test` / `unittest` green locally) but **never executed end to end**, so
their LLM graders and `max_turns` are uncalibrated — on the first run elsewhere, suspect the scaffold's
`git init`/`git commit` inside the sandbox before suspecting the skill.

Run the evals after any change to `SKILL.md`, `recipes.md`, `safety.md`, `judgment.md` or
`agents/refactoring-verifier.md` — they are the only check that the wiring between those files actually
changes behavior.

## Invariants to keep when editing

- Exactly 66 technique headings across the `catalog-*.md` files, matching `catalog-index.md` one-for-one.
- Every technique number cited in a smell's `- →` line (and in the appendix-B table) must exist as a heading.
  The smell→technique mapping was extracted from the publisher's published ch.3 text; don't add or remove
  prescriptions from it based on memory.
- Inverse pairs (Extract/Inline Function, Hide Delegate/Remove Middle Man, Pull Up/Push Down, …) are noted
  under the heading of *both* members.
- Mechanics summarize the book in our own words; example code is short and original (not book text).
  Fence language must match the example (`js` by default, `java` where the example is Java).
- `SKILL.md` frontmatter `description` is single-quoted YAML (it contains double quotes); keep it that way.
- Every `(N.M)` section reference in `recipes.md`, `safety.md`, `judgment.md`, `language-notes.md`,
  `large-scale.md`, `SKILL.md` and `agents/*.md` must resolve to a catalog heading (6.x–12.x) or a smell/principle section
  (2.x–5.x). Recipes are named R1–R10; SKILL.md's diagnosis template cites them by that name.
- `version` must be bumped in lockstep in three places: `plugin.json`, `.claude-plugin/plugin.json`, and the
  plugin entry in `.claude-plugin/marketplace.json` — use `scripts/bump.sh <ver>`. Users only receive updates
  when the version changes; new files or features → minor bump, wording fixes → patch.
- Commit-message template for refactoring commits is `refactor: <한국어 기법> (<English>) — <대상>`; it is stated
  in `safety.md` 커밋 단위 and referenced from `recipes.md`, keep the two in sync.

`scripts/check.sh` checks all of the above and exits 1 with every failure listed.
