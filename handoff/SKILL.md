---
name: handoff
description: Build team handoff and review-delegation messages for batches of Linear issues with GitHub PRs. Use when the user is traveling, offline, or wrapping up a work block and needs open PR-backed stories assigned to reviewers and grouped into a paste-ready team update.
---

# Handoff

Use this workflow to generate a repeatable handoff message for team review.

## Workflow

1. Collect candidate issues from Linear.
2. Keep only issues that have at least one open, unmerged GitHub PR attachment.
3. Randomly assign a reviewer for each issue using the exact method:
   `reviewers |> Enum.shuffle() |> hd()`
4. Group issues by reviewer.
5. Render a paste-ready team message with short per-story descriptions and both Linear/PR links.

## Run The Script

From any repository directory, run:

```bash
/Users/frisco/.codex/skills/handoff/scripts/generate_handoff.sh \
  --project "Application Assistant" \
  --team GOV \
  --assignee self \
  --reviewers "Chris,Maxwell,Eric,Gia" \
  --title "quick handoff before I am in flight"
```

## Script Behavior

- Pulls issue IDs from `linear issue list` using the supplied team/project/assignee filters.
- Fetches each issue using `linear issue view --json --no-comments`.
- Filters to issues in the specified project with GitHub attachments where:
  - `status == open`
  - `mergedAt == null`
- Uses the first qualifying open PR attachment per issue.
- Summarizes each story from the first sentence of the Linear description (falls back to title).
- Prints grouped output by reviewer, ready to paste in Slack/Linear.

## Inputs

- `--project`: Linear project name (default `Application Assistant`)
- `--team`: Linear team key (default `GOV`)
- `--assignee`: `self`, username, or `all` (default `self`)
- `--reviewers`: comma-separated reviewer names (default `Chris,Maxwell,Eric,Gia`)
- `--title`: short handoff context line
- `--limit`: issue list cap (default `200`)

## Validation Checklist

- Confirm every listed PR URL is open and not merged.
- Confirm each issue is in the intended project.
- Confirm reviewer list matches current availability.
- If distribution looks skewed, rerun the script for a fresh random assignment.

## Resources

- Script entrypoint: `scripts/generate_handoff.sh`
- Message renderer: `scripts/render_handoff.exs`
