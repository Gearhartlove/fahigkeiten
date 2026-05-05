# README Skill Eval Harness Ticket

## Links

- Design note: `docs/superpowers/specs/2026-05-05-readme-skill-eval-harness-design.md`
- Implementation plan: `docs/superpowers/plans/2026-05-05-readme-skill-eval-harness.md`
- PR summary draft: `docs/superpowers/pr-summaries/2026-05-05-readme-skill-eval-harness.md`

## Problem

AI skills are useful as reusable instructions, but this repository did not yet have a concrete pattern for storing a skill, evaluating generated artifacts, and preserving an improvement loop that can be extracted to other systems.

## Goal

Create a minimal `readme-writer` skill and an Elixir-based artifact-only evaluation harness that scores saved README outputs against deterministic checks.

## Constraints

- Keep runtime skills under `skills/`.
- Keep reusable evaluator code under `skill_evaluator/`.
- Keep skill-specific eval fixtures under `evals/`.
- Start with artifact-only scoring; do not call an LLM provider or agent CLI in V1.
- Use Elixir for the evaluator.
- Keep YAML declarative: check specs describe what to run, while Elixir modules own executable logic.
- Preserve a future runner boundary for CLI/API execution without implementing those runners now.

## Acceptance Criteria

- `skills/readme-writer/SKILL.md` exists and gives concise, factual README-writing guidance.
- `evals/readme-writer/basic-elixir-project` contains a prompt, fixture project, expectations, and passing/failing run artifacts.
- `skill_evaluator` can load eval cases, validate duplicate check IDs, load artifact runs safely, build context, detect conservative fixture facts, and score deterministic checks.
- `mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing` exits `0`.
- `mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing` exits `1` and reports expected failures.
- Full evaluator tests pass.

## Decision Log

- Artifact-only scoring is V1. CLI and API runners are deferred until there is a real automation need.
- YAML uses unique `id` values as result identity and optional `check` values as implementation type. If `check` is omitted, it defaults to `id`.
- Duplicate check IDs are configuration errors.
- Artifact run IDs are validated to avoid missing options, non-string values, empty IDs, separators, and path traversal.
- Fixture detection stays conservative. Empty `.github/workflows` directories do not count as CI evidence; at least one workflow YAML file is required.
- Deterministic checks use structured setup errors for malformed specs instead of crashing during scoring.
- README title checks require an exact Markdown H1 line.
- License claim matching is token-aware and ignores explicitly negated license contexts.

## Follow-Up Work

- Add a `CliRunner` once artifact-only scoring is useful enough to automate agent runs.
- Add broader eval fixtures from real README failures.
- Consider manual-review or LLM-judge checks for prose quality after deterministic checks are stable.
