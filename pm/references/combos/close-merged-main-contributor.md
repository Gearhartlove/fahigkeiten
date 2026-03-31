# close-merged-main-contributor

Close issues in a given Linear project when they have merged PR links and the user is the primary contributor on those PRs.

## Inputs

- Project identifier: project key, name, or id
- Contributor identity: GitHub login and/or email used in commits
- Optional scope filters: team, label, cycle
- Optional execution mode: `plan` (default) or `apply`

## Workflow

1. Verify CLI syntax needed for project and issue filtering with `linear issue list --help` and `linear project --help`.
2. Resolve the project to a unique project id/key.
3. List candidate issues in that project that are not closed.
4. For each issue, inspect linked PR metadata via available CLI fields or `linear api` fallback.
5. Keep only issues where at least one linked PR is merged.
6. For kept issues, determine whether the contributor appears to be the main contributor (author, or highest commit share if data is available).
7. Build action groups:
- `to_close`: merged PR + main contributor match
- `skip_not_merged`: no merged PR
- `skip_not_main_contributor`: merged PR but contributor mismatch
- `skip_already_closed`: already done/canceled
8. Print the action plan with issue keys before mutation.
9. If mode is `apply`, close each `to_close` issue using the team workflow state for done/completed.
10. Report final counts and per-issue outcomes.

## Guardrails

- Never close issues without showing the candidate list first.
- If contributor matching is ambiguous, default to `plan` and request confirmation.
- If PR metadata is unavailable, stop and report the missing fields instead of guessing.

## Output Format

- `closed`: list of issue keys updated
- `skipped`: issue keys grouped by reason
- `notes`: assumptions, missing metadata, follow-up commands
