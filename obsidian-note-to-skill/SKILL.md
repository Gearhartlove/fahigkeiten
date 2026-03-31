---
name: obsidian-note-to-skill
description: Create or update a single-file skill from one Obsidian Markdown note. Use when a user points to a note and asks to convert it into a production-ready SKILL.md without pulling in linked documents, scripts, references, or assets.
---

# Obsidian Note To Skill

## Goal

Convert one Obsidian note into one usable skill folder with a complete `SKILL.md`.
Optimize for small, single-file skills.

## Required Inputs

- Absolute path to one source note (`.md`)
- Destination skills directory (default: `${CODEX_HOME:-$HOME/.codex}/skills`)
- Skill name (derive from note title when missing, normalize to lowercase hyphen-case)

## Workflow

1. Read the source note and extract:
- Purpose of the skill
- Trigger conditions (when to use it)
- Concrete workflow steps
- Constraints and guardrails
2. Create or reuse the target skill folder.
3. If the folder does not exist, scaffold it:
```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/init_skill.py <skill-name> --path "${CODEX_HOME:-$HOME/.codex}/skills"
```
4. Rewrite content into `SKILL.md`:
- Keep frontmatter to `name` and `description` only.
- Make `description` explicit about what the skill does and when to use it.
- Use imperative instructions.
- Keep content concise and operational.
- Exclude linked-note expansion by default.
5. Keep the skill single-file unless the user explicitly asks for resource folders.
6. Validate:
```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py "${CODEX_HOME:-$HOME/.codex}/skills/<skill-name>"
```
7. Report assumptions, changed files, and any follow-up needed.

## Conversion Rules

- Convert narrative prose into actionable steps.
- Replace Obsidian-specific markup (callouts, wikilinks, embeds) with plain Markdown.
- Preserve intent, remove repetition, and avoid filler.
- Prefer deterministic wording over abstract guidance.
- If key behavior is unclear, make a minimal assumption and state it.

## Update Mode

When the skill already exists:

1. Keep existing structure if it is clear and working.
2. Merge in new behaviors from the note.
3. Preserve valid frontmatter keys and skill name.
4. Re-run validation after edits.
