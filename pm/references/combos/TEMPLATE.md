# <combo-name>

One-sentence summary of the repeated Linear operation.

## Inputs

- Required inputs
- Optional inputs
- Execution mode: `plan` (default) or `apply`

## Workflow

1. Validate command syntax using `linear ... --help`.
2. Gather read-only data.
3. Build and print mutation plan.
4. Execute only in `apply` mode.
5. Re-read and verify outcomes.
6. Report results.

## Guardrails

- List non-negotiable safety checks.
- Define when to stop and ask for clarification.

## Output Format

- `updated`: what changed
- `skipped`: what was skipped and why
- `notes`: assumptions and follow-up actions
