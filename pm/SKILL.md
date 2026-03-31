---
name: pm
description: Run named project-management combo operations in Linear using the linear CLI skill. Use when the user asks for PM workflows (for example "PM close-merged-main-contributor" or "PM create-parent-from-children") that combine multiple Linear steps into one repeatable operation.
---

# PM

Execute reusable, named Linear operations. Keep top-level instructions short and load only the combo file needed for the requested operation.

## Required Dependency

Always use the `linear-cli` skill before running any combo in this skill:
`/Users/frisco/src/forks/linear-cli/skills/linear-cli/SKILL.md`

## Quick Routing

1. Identify the requested combo name from the user prompt.
2. Open only the matching file in `references/combos/`.
3. Follow that combo file exactly.
4. If no exact match exists, ask whether to create a new combo spec file.

## Available Combos

- `close-merged-main-contributor`: [references/combos/close-merged-main-contributor.md](references/combos/close-merged-main-contributor.md)
- `create-parent-from-children`: [references/combos/create-parent-from-children.md](references/combos/create-parent-from-children.md)

## Execution Rules

1. Run a read-only discovery phase first (list issues, inspect PR links, check states).
2. Print a short planned action summary before mutating anything.
3. Only mutate when the request clearly implies execution; otherwise ask for confirmation.
4. When the CLI syntax is uncertain, check `linear <command> --help` before continuing.
5. Report final results as: updated issue keys, skipped keys, and reasons for skips.

## Add A New Combo

When the user asks for a new repeated workflow, create one new file in `references/combos/<combo-name>.md` using this template:
[references/combos/TEMPLATE.md](references/combos/TEMPLATE.md)
