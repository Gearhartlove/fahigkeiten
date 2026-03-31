# create-parent-from-children

Create a new parent ticket and attach a provided set of existing issues as child tickets.

## Inputs

- Child issue keys (required)
- Parent title (required)
- Parent description/body (optional)
- Team (optional if inferable from children)
- Project, milestone, labels, priority (optional)
- Optional execution mode: `plan` (default) or `apply`

## Workflow

1. Verify exact flags using `linear issue create --help` and `linear issue update --help`.
2. Resolve all child keys and validate they exist.
3. Ensure all children are compatible for one parent (for example same team/workspace expectations).
4. Draft the parent payload:
- title from input
- description summarizing child scope
- optional metadata from input or dominant child metadata
5. Print a plan that includes:
- proposed parent fields
- child keys to attach
- any metadata assumptions
6. If mode is `apply`, create the parent issue.
7. Attach every child to the parent using the correct parent/sub-issue update command.
8. Re-read all updated issues and confirm linkage.
9. Report created parent key and child attachment results.

## Guardrails

- Fail fast if any child key is invalid.
- Do not attach children until parent creation succeeds.
- If children span different teams and the CLI/workflow forbids it, stop and ask for split strategy.

## Output Format

- `parent`: created issue key and URL
- `attached`: child keys successfully linked
- `failed`: child keys not linked with reason
- `notes`: assumptions and follow-up actions
