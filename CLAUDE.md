# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A plugin containing one skill, `refactoring`, at `skills/refactoring/`. It encodes Martin Fowler's
*Refactoring* (2nd ed.; Korean translation 『리팩터링 2판』, 한빛미디어) so an agent can refactor code the way the
book prescribes. There is no application code, build, lint, or test suite — the deliverable is the Markdown itself.

The repo root is simultaneously the plugin root and a marketplace for both Claude Code and Codex:

- `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` (marketplace `zeromountain`, plugin source `./`)
- `plugin.json` (Agent Plugins portable manifest, used by Codex) + `.agents/plugins/marketplace.json` (same names)

Both tools discover `skills/<name>/SKILL.md` at the plugin root, so there is one copy of the skill. It is **not**
project-local to this repo (`.claude/skills/` is intentionally absent) — install it via the marketplace to use it.

Validate / test: `claude plugin validate --strict .` checks both Claude manifests. For an end-to-end check,
`claude plugin marketplace add <abs path>` → `claude plugin install refactoring@zeromountain` → `claude plugin details
refactoring@zeromountain`, and `codex plugin marketplace add <abs path>` → `codex plugin add refactoring@zeromountain`
→ `codex plugin list`; both write to the user's global config, so uninstall and `marketplace remove zeromountain`
afterwards.

Everything is written in Korean with the canonical English technique name in parentheses
(e.g. `## 6.1 함수 추출하기 (Extract Function)`).

## Layout and how the pieces reference each other

All paths below are under `skills/refactoring/`.

- `SKILL.md` — entry point loaded on trigger. Kept lean (~100 lines): principles, the agent workflow,
  the smell→technique quick table, the file map, prohibitions, report format. Technique detail is *not* here.
- `references/principles.md` — book ch.2 (principles), ch.4 (tests), ch.5 (catalog entry format).
- `references/smells.md` — ch.3: the 24 smells. Each smell ends with a `- → ...(6.1), ...(8.6)` line listing
  the techniques the book actually prescribes, plus the appendix-B table at the bottom.
- `references/catalog-index.md` — appendix A: the 66 techniques with section number, Korean name, English name,
  1st-edition alias, inverse, and the source list.
- `references/catalog-*.md` — one file per book chapter 6–12. Each technique is a `## N.M 한국어 (English)`
  heading followed by `**배경**` → `**절차**` (numbered, one small step each, "테스트" as its own step) → `**예시**`.

Techniques are cross-referenced everywhere by **book section number** (`6.1`, `10.4`, …), never by page.
The numbering follows the Korean 2nd-edition table of contents exactly, and the Korean↔English mapping is
by position in that TOC.

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
- `version` must be bumped in lockstep in three places: `plugin.json`, `.claude-plugin/plugin.json`, and the
  plugin entry in `.claude-plugin/marketplace.json`. Users only receive updates when the version changes.

A quick way to check the invariants: grep `^## \d+\.\d+ ` across `skills/refactoring/references/catalog-*.md` and
count 66, then confirm every `(\d+\.\d+)` in `skills/refactoring/references/smells.md` appears in that heading list.
