# README Skill Evaluation Harness Design

## Problem

The repository needs a small, portable example of how to treat an AI skill as a versioned artifact and improve it through repeatable evaluation. The first skill will create a `README.md` for a project. The first evaluator should be useful without binding the project to a specific agent CLI or LLM provider.

## Goals

- Store installable skills under `skills/`.
- Store reusable Elixir evaluator code under `skill_evaluator/`.
- Store skill-specific eval cases under `evals/`.
- Start with artifact-only scoring: the evaluator scores an existing generated README rather than invoking an agent.
- Model the evaluator so CLI and API runners can be added later.
- Keep checks deterministic for V1.

## Non-Goals

- No direct LLM provider integration in V1.
- No Codex, Claude, or other CLI runner in V1.
- No subjective LLM-as-judge scoring in V1.
- No broad skill marketplace or installer behavior in V1.

## Repository Shape

```text
/skills
  /readme-writer
    SKILL.md
    references/
      readme-quality.md

/skill_evaluator
  mix.exs
  lib/
    skill_evaluator/
      eval_case.ex
      run.ex
      checker.ex
      checks/
        markdown_check.ex
        readme_check.ex
      runner.ex
      runners/
        artifact_runner.ex

/evals
  /readme-writer
    /basic-elixir-project
      eval.yml
      prompt.md
      fixture/
        mix.exs
        lib/example.ex
      expectations.yml
      runs/
        .gitkeep
```

`skills/` contains runtime skill artifacts only. The first skill is `readme-writer`.

`skill_evaluator/` is a normal Elixir project. It owns parsing, context construction, check execution, result formatting, and runner behavior definitions.

`evals/` contains eval cases. Each case owns the task prompt, fixture project, expectations, and saved run artifacts.

## V1 Evaluation Flow

1. A human or external agent uses `skills/readme-writer` against an eval fixture.
2. The generated `README.md` is saved under an eval run directory, for example:
   `evals/readme-writer/basic-elixir-project/runs/2026-05-05-codex/README.md`.
3. The Elixir evaluator loads the eval case, fixture facts, expectations, and run artifact.
4. The evaluator executes deterministic checks.
5. The evaluator reports pass, fail, and skip results with human-readable reasons.

The intended command shape is:

```bash
cd skill_evaluator
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run 2026-05-05-codex
```

## YAML Check Model

YAML check files are declarative. They name checks and pass parameters. They do not contain executable logic.

Example:

```yaml
checks:
  - id: readme_exists

  - id: has_project_title
    source: fixture_directory_name

  - id: mentions_detected_language
    language: elixir

  - id: includes_command
    command: mix test
    when_file_exists: mix.exs

  - id: no_license_claim
    check: does_not_claim_file
    file: LICENSE
    forbidden_claims:
      - MIT
      - Apache
      - licensed

  - id: no_ci_claim
    check: does_not_claim_file
    file: .github/workflows
    forbidden_claims:
      - GitHub Actions
      - continuous integration
```

Each check `id` is the stable result identity and must be unique within an eval. The optional `check` field names the implementation type for registry lookup. When `check` is omitted, the evaluator uses the `id` value as the check type.

The evaluator maps check implementation types to Elixir modules through a registry:

```elixir
%{
  "readme_exists" => SkillEvaluator.Checks.ReadmeExists,
  "has_project_title" => SkillEvaluator.Checks.HasProjectTitle,
  "mentions_detected_language" => SkillEvaluator.Checks.MentionsDetectedLanguage,
  "includes_command" => SkillEvaluator.Checks.IncludesCommand,
  "does_not_claim_file" => SkillEvaluator.Checks.DoesNotClaimFile
}
```

Each check receives a normalized context and its YAML parameters. Checks return `:pass`, `:fail`, or `:skip` with an explanation while preserving the YAML `id` as the result identity.

## Evaluation Context

The evaluator builds a context similar to:

```elixir
%SkillEvaluator.Context{
  eval_dir: ".../evals/readme-writer/basic-elixir-project",
  fixture_dir: ".../fixture",
  run_dir: ".../runs/2026-05-05-codex",
  readme_path: ".../runs/2026-05-05-codex/README.md",
  readme_text: "...",
  detected: %{
    project_name: "basic-elixir-project",
    languages: [:elixir],
    commands: ["mix test"]
  }
}
```

Detection should be intentionally conservative. For example, `mix.exs` implies Elixir and makes `mix test` a plausible test command. The evaluator should not infer a license, CI provider, deployment platform, package registry, or production status without fixture evidence.

## Runner Boundary

V1 implements only artifact loading, but the code should leave room for runners:

```elixir
run(eval_case, opts) :: {:ok, run} | {:error, reason}
```

The initial runner is `ArtifactRunner`, which loads an existing run directory.

Future runners can include:

- `CliRunner`: shell out to a configured agent command and save outputs under `runs/`.
- `ApiRunner`: call an LLM provider directly and save outputs under `runs/`.

This keeps V1 portable while preserving a path to automation.

## Error Handling

- Missing eval files should produce clear configuration errors.
- Unknown check types should fail the eval setup before scoring starts.
- Missing run artifacts should produce a run-loading error, not a failed README-quality check.
- Conditional checks should return `:skip` when their preconditions are not met.
- Checks should avoid raising for normal evaluation failures.

## Testing Strategy

V1 should include unit tests for:

- Parsing eval and expectation files.
- Building context from fixture and run directories.
- Mapping check types to check modules.
- Executing deterministic README checks.
- Reporting pass, fail, and skip results.

V1 should include at least one integration-style fixture:

- `readme-writer/basic-elixir-project`
- One passing run artifact.
- One failing run artifact that demonstrates unsupported claims or missing required content.

## Acceptance Criteria

- The repository contains the agreed top-level directories: `skills/`, `skill_evaluator/`, and `evals/`.
- `skills/readme-writer/SKILL.md` exists and gives concise instructions for writing project READMEs without inventing facts.
- `skill_evaluator` can score an existing run artifact from an eval case.
- YAML checks are declarative and implemented by Elixir modules.
- The evaluator emits actionable pass, fail, and skip output.
- The first eval case covers a basic Elixir project.
- Tests validate the evaluator behavior.

## Decisions

- Start with artifact-only scoring to avoid provider credentials, CLI variance, and premature runner complexity.
- Keep skill runtime files separate from eval harness files so the skill can be packaged independently.
- Use deterministic checks first; subjective judging can be added later as a separate check type.
- Treat YAML as data and Elixir modules as executable check logic.
- Design a runner boundary now, but only implement `ArtifactRunner` in V1.

## Risks and Follow-Ups

- Deterministic checks may miss prose-quality issues. Follow-up: add optional manual-review or LLM-judge checks after the deterministic foundation works.
- File-based language detection can become overconfident. Follow-up: keep detection conservative and make check parameters explicit when possible.
- Eval fixtures may become stale or too narrow. Follow-up: add regression cases whenever the skill fails on a real project.
- Runner abstractions can be overdesigned. Follow-up: keep V1 focused on artifact scoring and add runner features only when a real workflow needs them.
