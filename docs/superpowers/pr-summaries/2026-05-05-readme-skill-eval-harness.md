# README Skill Eval Harness PR Summary

## Why

This change establishes a portable pattern for treating AI skills as versioned artifacts and improving them with repeatable evaluations. The first example skill writes project READMEs, and the first evaluator scores saved README artifacts without depending on a specific LLM provider or agent CLI.

Linked ticket: `docs/superpowers/tickets/2026-05-05-readme-skill-eval-harness.md`

## What Changed

- Added `skills/readme-writer` with concise README-writing guidance and a quality reference.
- Added `evals/readme-writer/basic-elixir-project` with a prompt, Elixir fixture, expectations, and passing/failing README artifacts.
- Added `skill_evaluator`, an Elixir Mix project that:
  - parses declarative YAML eval files,
  - validates eval cases and artifact run IDs,
  - builds scoring context from fixture and run artifacts,
  - detects conservative fixture facts,
  - runs deterministic README checks,
  - reports pass/fail/skip summaries,
  - exposes `mix skill_eval.score`.
- Added repository README usage instructions and evaluator formatter config.

## Validation

- `cd skill_evaluator && mix deps.get`
- `cd skill_evaluator && mix format --check-formatted`
- `cd skill_evaluator && mix test`
- `cd skill_evaluator && mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing`
- `cd skill_evaluator && mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing`

Expected validation behavior:

- The passing artifact exits `0` with `Summary: 6 passed, 0 failed, 0 skipped`.
- The failing artifact intentionally exits `1` with `Summary: 2 passed, 4 failed, 0 skipped`.

## Risk Notes

- Failure mode: YAML dependency behavior changes. Rollback: revert evaluator commits; mitigation: YAML parsing is isolated in `SkillEvaluator.Yaml`.
- Failure mode: deterministic checks miss prose-quality problems. Rollback: remove or disable affected checks; follow-up: add manual-review or judge-style checks later.
- Failure mode: conservative fixture detection omits valid facts. Rollback: adjust detector rules; follow-up: add real-world regression fixtures before expanding detection.
- Failure mode: CLI behavior surprises users because failing eval artifacts exit `1`. Mitigation: README explicitly calls out the expected non-zero exit for the failing artifact.

## Design Note

Written: `docs/superpowers/specs/2026-05-05-readme-skill-eval-harness-design.md`

This change is non-trivial because it introduces a new repository structure, evaluator architecture, YAML schema, and runner boundary. The design note records architecture, data flow, decisions, and risks.
