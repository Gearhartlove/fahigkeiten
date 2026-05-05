---
name: readme-writer
description: Use when creating or revising a README.md for a software project, especially when project files must be inspected and unsupported claims must be avoided.
---

# README Writer

Write a useful `README.md` from evidence in the project files.

## Workflow

1. Inspect project files before writing.
2. Identify the project name, language, setup commands, test commands, and usage entry points from files.
3. Write only claims supported by the repository.
4. Include concise sections for overview, setup, usage, and tests when evidence exists.
5. Omit sections that would require guessing.

## Rules

- Do not invent license, CI, deployment, package registry, production status, or maintainership details.
- Prefer exact commands visible from project conventions, such as `mix test` when `mix.exs` exists.
- Mention uncertainty by omission, not by speculative prose.
- Keep the README practical for a developer opening the repository for the first time.

## Reference

For quality criteria and common failure modes, read `references/readme-quality.md` when the README requirements are ambiguous or when evaluating a draft.
