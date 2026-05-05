# fahigkeiten

`fahigkeiten` is a small repository for experimenting with AI skills as versioned artifacts and evaluating them with a reusable Elixir harness.

## Layout

- `skills/` contains runtime skill definitions and bundled skill resources.
- `skill_evaluator/` contains the Elixir evaluation harness.
- `evals/` contains skill-specific eval cases, fixtures, expectations, and saved runs.

## First Skill

The first skill is `skills/readme-writer`, which helps create factual project READMEs from repository evidence.

## Running The Evaluator

Fetch dependencies:

```bash
cd skill_evaluator
mix deps.get
```

Run tests:

```bash
mix test
```

Score a passing artifact:

```bash
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing
```

Score a failing artifact:

```bash
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing
```
