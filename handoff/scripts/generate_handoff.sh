#!/usr/bin/env bash

set -euo pipefail

PROJECT="Application Assistant"
TEAM="GOV"
ASSIGNEE="self"
REVIEWERS="Chris,Maxwell,Eric,Gia"
TITLE="quick handoff"
LIMIT=200

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDER_SCRIPT="$SCRIPT_DIR/render_handoff.exs"

usage() {
  cat <<'USAGE'
Usage:
  generate_handoff.sh [options]

Options:
  --project <name>      Linear project name (default: Application Assistant)
  --team <key>          Linear team key (default: GOV)
  --assignee <value>    self | all | username (default: self)
  --reviewers <csv>     Reviewer names CSV (default: Chris,Maxwell,Eric,Gia)
  --title <text>        Handoff title/context line
  --limit <n>           Max issue count from Linear list (default: 200)
  -h, --help            Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT="${2:-}"
      shift 2
      ;;
    --team)
      TEAM="${2:-}"
      shift 2
      ;;
    --assignee)
      ASSIGNEE="${2:-}"
      shift 2
      ;;
    --reviewers)
      REVIEWERS="${2:-}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

for cmd in linear jq rg elixir; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$RENDER_SCRIPT" ]]; then
  echo "Missing renderer script: $RENDER_SCRIPT" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

list_cmd=(linear issue list --team "$TEAM" --project "$PROJECT" --all-states --limit "$LIMIT" --no-pager)

case "$ASSIGNEE" in
  self)
    list_cmd+=(--assignee self)
    ;;
  all)
    list_cmd+=(--all-assignees)
    ;;
  *)
    list_cmd+=(--assignee "$ASSIGNEE")
    ;;
esac

NO_COLOR=1 "${list_cmd[@]}" > "$tmpdir/issue-list.txt"

rg -o '[A-Z]+-[0-9]+' "$tmpdir/issue-list.txt" | sort -u > "$tmpdir/issue-ids.txt" || true

if [[ ! -s "$tmpdir/issue-ids.txt" ]]; then
  echo "No issue IDs found for the provided filters." >&2
  exit 0
fi

> "$tmpdir/issues.ndjson"
while IFS= read -r issue_id; do
  linear issue view "$issue_id" --json --no-comments >> "$tmpdir/issues.ndjson"
done < "$tmpdir/issue-ids.txt"

jq -s --arg project "$PROJECT" '
[
  .[] |
  select((.project.name // "") == $project) |
  {
    id: .identifier,
    title: .title,
    description: (.description // ""),
    state: (.state.name // "Unknown"),
    linear_url: .url,
    prs: [
      .attachments[]? |
      select(.sourceType == "github" and .metadata.status == "open" and (.metadata.mergedAt == null)) |
      {
        number: ((.metadata.number // "") | tostring),
        title: (.title // .metadata.title // ""),
        url: .url
      }
    ]
  } |
  select((.prs | length) > 0) |
  . + {pr: .prs[0]} |
  del(.prs)
]
' "$tmpdir/issues.ndjson" > "$tmpdir/open-pr-issues.json"

if [[ "$(jq 'length' "$tmpdir/open-pr-issues.json")" -eq 0 ]]; then
  echo "No open unmerged PR-backed issues matched the filters." >&2
  exit 0
fi

jq -r '.[] | [
  .id,
  .title,
  .state,
  .linear_url,
  .pr.number,
  .pr.title,
  .pr.url,
  (.description | gsub("[\\r\\n\\t]+"; " "))
] | @tsv' "$tmpdir/open-pr-issues.json" > "$tmpdir/handoff-rows.tsv"

elixir "$RENDER_SCRIPT" \
  --rows "$tmpdir/handoff-rows.tsv" \
  --reviewers "$REVIEWERS" \
  --title "$TITLE" \
  --project "$PROJECT" \
  --assignee "$ASSIGNEE"
