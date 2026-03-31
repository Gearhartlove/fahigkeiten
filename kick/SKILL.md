---
name: kick
description: Kickstart work on a new Linear ticket. Use when the user starts a new ticket or asks to begin implementation. If a ticket key is provided, look it up with linear-cli; if not, create one with required title, description, priority, status, and project, defaulting assignee to self unless the user specifies otherwise, and defaulting status to in progress. After ticket setup, create a new git worktree with ./new-worktree.sh and begin the implementation work.
---

# Kick

Run this workflow to move from "new ticket" to active implementation with minimal manual steps.

## Workflow

1. Determine whether the user provided a Linear issue key.
2. Ensure the issue exists and has required fields.
3. Create a branch/worktree with `./new-worktree.sh`.
4. Analyze the issue and start implementing.

## 1) Determine the issue

- Detect an issue key from the request using a pattern like `[A-Z]+-[0-9]+`.
- Always include `--team GOV` for Linear commands.
- If a key exists, use `$linear-cli` at `/Users/frisco/src/forks/linear-cli/skills/linear-cli/SKILL.md` and fetch details:

```bash
linear issue view <ISSUE_KEY> --team GOV --json --no-comments --no-pager
```

- If no key exists, create a new issue with the user.

## 2) Create or normalize the issue

When creating an issue, ensure these fields exist:
- Title
- Description
- Project
- Assignee
- Priority
- Status

Rules:
- Default assignee to `self` unless the user explicitly asks otherwise.
- Default status to in progress (`--state started`) when not specified.
- Ask for priority when it is not provided; do not guess priority.
- Ask only for missing critical fields you cannot infer from the request.
- Prefer concise clarification over long questionnaires.
- Use `--description-file` for markdown descriptions.

Create command pattern:

```bash
linear issue create \
  --title "<TITLE>" \
  --description-file /tmp/kick-description.md \
  --project "<PROJECT>" \
  --team GOV \
  --assignee self \
  --priority <PRIORITY_1_TO_4> \
  --state started \
  --no-interactive
```

If an existing issue is missing required fields, patch it:

```bash
linear issue update <ISSUE_KEY> \
  --project "<PROJECT>" \
  --team GOV \
  --assignee self \
  --priority <PRIORITY_1_TO_4> \
  --state started
```

Also add `--title` and `--description-file` when missing.
If priority is missing, ask the user before creating/updating.

## 3) Create branch and worktree

- Use the branch name from Linear as the source of truth.
- Resolve it with:

```bash
linear issue view <ISSUE_KEY> --team GOV --json | jq -r .branchName
```

- If you specifically need the user-provided variant, use:

```bash
linear view <ISSUE_KEY> --team GOV --json | jq -r .branchName
```

- If `branchName` is empty or null, fall back to:
  - `kristofffinley/<issue-key-lower>-<short-kebab-title>`
- Run from the repository root where `new-worktree.sh` exists.

```bash
./new-worktree.sh <BRANCH_NAME>
```

If base branch is requested, pass it as the second argument.

## 4) Start implementation immediately

After the worktree is ready:
- Read the issue title and description.
- Extract clear acceptance criteria and constraints.
- Identify likely code areas to change.
- Begin implementation in the new worktree instead of stopping at planning.
- Surface blockers quickly if any required detail is still missing.

## Output expectations

When using this skill, report:
- Final issue key used/created
- Issue URL (if available)
- Worktree path
- Branch name
- First implementation step completed
