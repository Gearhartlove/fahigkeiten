# README Skill Eval Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal README-writing skill plus an artifact-only Elixir evaluation harness that scores generated README files with deterministic YAML-defined checks.

**Architecture:** Runtime skill files live in `skills/`, reusable Elixir evaluator code lives in `skill_evaluator/`, and skill-specific eval cases live in `evals/`. V1 uses an `ArtifactRunner` that loads existing run directories, then builds a normalized context and executes registered check modules from declarative YAML.

**Tech Stack:** Elixir, Mix, ExUnit, `yaml_elixir` for YAML parsing.

---

## File Structure

- Create `skills/readme-writer/SKILL.md`: concise runtime instructions for writing factual project READMEs.
- Create `skills/readme-writer/references/readme-quality.md`: optional reference with README quality rules.
- Create `evals/readme-writer/basic-elixir-project/eval.yml`: eval case metadata.
- Create `evals/readme-writer/basic-elixir-project/prompt.md`: user-like task prompt.
- Create `evals/readme-writer/basic-elixir-project/expectations.yml`: declarative deterministic checks.
- Create `evals/readme-writer/basic-elixir-project/fixture/mix.exs`: small Elixir project fixture.
- Create `evals/readme-writer/basic-elixir-project/fixture/lib/example.ex`: fixture source file.
- Create `evals/readme-writer/basic-elixir-project/runs/passing/README.md`: passing artifact for integration tests.
- Create `evals/readme-writer/basic-elixir-project/runs/failing/README.md`: failing artifact for integration tests.
- Create `skill_evaluator/mix.exs`: Mix project and dependencies.
- Create `skill_evaluator/lib/skill_evaluator.ex`: public scoring entry point.
- Create `skill_evaluator/lib/skill_evaluator/yaml.ex`: YAML parser wrapper.
- Create `skill_evaluator/lib/skill_evaluator/eval_case.ex`: eval case loader.
- Create `skill_evaluator/lib/skill_evaluator/run.ex`: run artifact struct.
- Create `skill_evaluator/lib/skill_evaluator/runner.ex`: runner behavior.
- Create `skill_evaluator/lib/skill_evaluator/runners/artifact_runner.ex`: loads an existing run directory.
- Create `skill_evaluator/lib/skill_evaluator/context.ex`: normalized check context.
- Create `skill_evaluator/lib/skill_evaluator/detector.ex`: conservative fixture fact detection.
- Create `skill_evaluator/lib/skill_evaluator/check_result.ex`: pass/fail/skip result struct.
- Create `skill_evaluator/lib/skill_evaluator/check_registry.ex`: maps YAML check types to modules.
- Create `skill_evaluator/lib/skill_evaluator/checker.ex`: executes checks.
- Create `skill_evaluator/lib/skill_evaluator/checks/readme_exists.ex`: README existence check.
- Create `skill_evaluator/lib/skill_evaluator/checks/has_project_title.ex`: project-title check.
- Create `skill_evaluator/lib/skill_evaluator/checks/mentions_detected_language.ex`: language mention check.
- Create `skill_evaluator/lib/skill_evaluator/checks/includes_command.ex`: command inclusion check.
- Create `skill_evaluator/lib/skill_evaluator/checks/does_not_claim_file.ex`: unsupported-claim check.
- Create `skill_evaluator/lib/skill_evaluator/console_reporter.ex`: text report formatting.
- Create `skill_evaluator/lib/mix/tasks/skill_eval.score.ex`: CLI task.
- Create `skill_evaluator/test/skill_evaluator/eval_case_test.exs`: eval case loader tests.
- Create `skill_evaluator/test/skill_evaluator/context_test.exs`: context and detection tests.
- Create `skill_evaluator/test/skill_evaluator/checker_test.exs`: deterministic check tests.
- Create `skill_evaluator/test/skill_evaluator/score_integration_test.exs`: end-to-end artifact scoring tests.

### Task 1: Add Runtime Skill And Eval Fixture

**Files:**
- Create: `skills/readme-writer/SKILL.md`
- Create: `skills/readme-writer/references/readme-quality.md`
- Create: `evals/readme-writer/basic-elixir-project/eval.yml`
- Create: `evals/readme-writer/basic-elixir-project/prompt.md`
- Create: `evals/readme-writer/basic-elixir-project/expectations.yml`
- Create: `evals/readme-writer/basic-elixir-project/fixture/mix.exs`
- Create: `evals/readme-writer/basic-elixir-project/fixture/lib/example.ex`
- Create: `evals/readme-writer/basic-elixir-project/runs/passing/README.md`
- Create: `evals/readme-writer/basic-elixir-project/runs/failing/README.md`

- [ ] **Step 1: Create the README writer skill**

Create `skills/readme-writer/SKILL.md`:

```markdown
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
```

- [ ] **Step 2: Create the README quality reference**

Create `skills/readme-writer/references/readme-quality.md`:

```markdown
# README Quality Reference

Useful READMEs answer four questions quickly:

- What is this project?
- How do I set it up?
- How do I run it?
- How do I test it?

Good README behavior:

- Use the repository's real project name.
- Prefer short, scannable sections.
- Include commands only when project files support them.
- Keep setup and test instructions copy-pasteable.

Unsupported claims to avoid:

- License names when no license file exists.
- CI status when no CI configuration exists.
- Deployment targets when no deployment files exist.
- Package publication when no package metadata exists.
```

- [ ] **Step 3: Create the eval metadata**

Create `evals/readme-writer/basic-elixir-project/eval.yml`:

```yaml
skill: readme-writer
name: basic-elixir-project
prompt: prompt.md
fixture: fixture
expectations: expectations.yml
```

- [ ] **Step 4: Create the eval prompt**

Create `evals/readme-writer/basic-elixir-project/prompt.md`:

```markdown
Use the README writer skill to create a README.md for this project.
```

- [ ] **Step 5: Create declarative expectations**

Create `evals/readme-writer/basic-elixir-project/expectations.yml`:

```yaml
checks:
  - id: readme_exists

  - id: has_project_title
    title: Basic Elixir Project

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
      - license

  - id: no_ci_claim
    check: does_not_claim_file
    file: .github/workflows
    forbidden_claims:
      - GitHub Actions
      - continuous integration
```

- [ ] **Step 6: Create the Elixir fixture project**

Create `evals/readme-writer/basic-elixir-project/fixture/mix.exs`:

```elixir
defmodule BasicElixirProject.MixProject do
  use Mix.Project

  def project do
    [
      app: :basic_elixir_project,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
```

Create `evals/readme-writer/basic-elixir-project/fixture/lib/example.ex`:

```elixir
defmodule BasicElixirProject.Example do
  def greeting(name) when is_binary(name) do
    "Hello, " <> name
  end
end
```

- [ ] **Step 7: Create a passing README run**

Create `evals/readme-writer/basic-elixir-project/runs/passing/README.md`:

````markdown
# Basic Elixir Project

Basic Elixir Project is a small Elixir project.

## Setup

```bash
mix deps.get
```

## Usage

The project contains `BasicElixirProject.Example`, which exposes a `greeting/1` function.

## Tests

```bash
mix test
```
````

- [ ] **Step 8: Create a failing README run**

Create `evals/readme-writer/basic-elixir-project/runs/failing/README.md`:

```markdown
# Demo

This MIT-licensed project is tested by GitHub Actions.

## Install

Run the app with Elixir.
```

- [ ] **Step 9: Commit the runtime skill and eval fixture**

Run:

```bash
git add skills evals
git commit -m "Add README writer skill and eval fixture"
```

Expected: commit succeeds with new skill and eval fixture files.

### Task 2: Create Mix Project And YAML Loader

**Files:**
- Create: `skill_evaluator/mix.exs`
- Create: `skill_evaluator/lib/skill_evaluator/yaml.ex`
- Create: `skill_evaluator/test/test_helper.exs`
- Create: `skill_evaluator/test/skill_evaluator/yaml_test.exs`

- [ ] **Step 1: Create the Mix project files**

Create `skill_evaluator/mix.exs`:

```elixir
defmodule SkillEvaluator.MixProject do
  use Mix.Project

  def project do
    [
      app: :skill_evaluator,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 2.12"}
    ]
  end
end
```

Create `skill_evaluator/test/test_helper.exs`:

```elixir
ExUnit.start()
```

- [ ] **Step 2: Fetch dependencies**

Run:

```bash
cd skill_evaluator
mix deps.get
```

Expected: `yaml_elixir` and its dependency are fetched successfully.

- [ ] **Step 3: Write the failing YAML loader test**

Create `skill_evaluator/test/skill_evaluator/yaml_test.exs`:

```elixir
defmodule SkillEvaluator.YamlTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.Yaml

  test "read_file returns parsed YAML maps" do
    path = Path.expand("../../../evals/readme-writer/basic-elixir-project/eval.yml", __DIR__)

    assert {:ok, config} = Yaml.read_file(path)
    assert config["skill"] == "readme-writer"
    assert config["name"] == "basic-elixir-project"
  end

  test "read_file wraps parser errors" do
    path = Path.join(System.tmp_dir!(), "invalid-skill-eval-yaml.yml")

    try do
      File.write!(path, "checks:\n  - id: [")

      assert {:error, {:invalid_yaml, ^path, _reason}} = Yaml.read_file(path)
    after
      File.rm(path)
    end
  end
end
```

- [ ] **Step 4: Run the YAML loader test to verify it fails**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/yaml_test.exs
```

Expected: FAIL because `SkillEvaluator.Yaml` is not defined.

- [ ] **Step 5: Implement the YAML loader**

Create `skill_evaluator/lib/skill_evaluator/yaml.ex`:

```elixir
defmodule SkillEvaluator.Yaml do
  @moduledoc false

  def read_file(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:invalid_yaml, path, reason}}
    end
  rescue
    error -> {:error, {:invalid_yaml, path, error}}
  end
end
```

- [ ] **Step 6: Run the YAML loader test to verify it passes**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/yaml_test.exs
```

Expected: PASS.

- [ ] **Step 7: Commit the Mix project and YAML loader**

Run:

```bash
git add skill_evaluator
git commit -m "Add Elixir evaluator project and YAML loader"
```

Expected: commit succeeds.

### Task 3: Load Eval Cases And Artifact Runs

**Files:**
- Create: `skill_evaluator/lib/skill_evaluator/eval_case.ex`
- Create: `skill_evaluator/lib/skill_evaluator/run.ex`
- Create: `skill_evaluator/lib/skill_evaluator/runner.ex`
- Create: `skill_evaluator/lib/skill_evaluator/runners/artifact_runner.ex`
- Create: `skill_evaluator/test/skill_evaluator/eval_case_test.exs`

- [ ] **Step 1: Write failing eval case and runner tests**

Create `skill_evaluator/test/skill_evaluator/eval_case_test.exs`:

```elixir
defmodule SkillEvaluator.EvalCaseTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.EvalCase
  alias SkillEvaluator.Runners.ArtifactRunner

  @eval_path Path.expand("../../../evals/readme-writer/basic-elixir-project", __DIR__)

  test "loads eval case metadata and expectations" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)

    assert eval_case.skill == "readme-writer"
    assert eval_case.name == "basic-elixir-project"
    assert eval_case.prompt_path == Path.join(@eval_path, "prompt.md")
    assert eval_case.fixture_dir == Path.join(@eval_path, "fixture")
    assert length(eval_case.checks) == 6
  end

  test "returns a clear error when eval.yml is missing" do
    path = Path.join(System.tmp_dir!(), "missing-eval-case")

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)

      assert {:error, {:missing_file, missing}} = EvalCase.load(path)
      assert missing == Path.join(path, "eval.yml")
    after
      File.rm_rf(path)
    end
  end

  test "returns a clear error when expectation check IDs are duplicated" do
    path = Path.join(System.tmp_dir!(), "duplicate-check-id-eval-case")

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)

      File.write!(Path.join(path, "eval.yml"), """
      skill: readme-writer
      name: duplicate-check-id
      prompt: prompt.md
      fixture: fixture
      expectations: expectations.yml
      """)

      File.write!(Path.join(path, "expectations.yml"), """
      checks:
        - id: readme_exists
        - id: readme_exists
      """)

      assert {:error, {:duplicate_check_id, "readme_exists"}} = EvalCase.load(path)
    after
      File.rm_rf(path)
    end
  end

  test "artifact runner loads an existing run directory" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)
    assert {:ok, run} = ArtifactRunner.run(eval_case, run_id: "passing")

    assert run.id == "passing"
    assert run.path == Path.join(@eval_path, "runs/passing")
    assert run.readme_path == Path.join(@eval_path, "runs/passing/README.md")
  end

  test "artifact runner errors when the run directory is missing" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)

    assert {:error, {:missing_run, path}} = ArtifactRunner.run(eval_case, run_id: "absent")
    assert path == Path.join(@eval_path, "runs/absent")
  end
end
```

- [ ] **Step 2: Run the eval case test to verify it fails**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/eval_case_test.exs
```

Expected: FAIL because eval case and runner modules are not defined.

- [ ] **Step 3: Implement eval case loading**

Create `skill_evaluator/lib/skill_evaluator/eval_case.ex`:

```elixir
defmodule SkillEvaluator.EvalCase do
  @moduledoc false

  alias SkillEvaluator.Yaml

  @enforce_keys [:path, :skill, :name, :prompt_path, :fixture_dir, :expectations_path, :checks]
  defstruct [:path, :skill, :name, :prompt_path, :fixture_dir, :expectations_path, :checks]

  @type t :: %__MODULE__{
          path: String.t(),
          skill: String.t(),
          name: String.t(),
          prompt_path: String.t(),
          fixture_dir: String.t(),
          expectations_path: String.t(),
          checks: [map()]
        }

  def load(path) do
    eval_file = Path.join(path, "eval.yml")

    with :ok <- require_file(eval_file),
         {:ok, config} <- Yaml.read_file(eval_file),
         {:ok, eval_case} <- from_config(path, config),
         :ok <- require_file(eval_case.expectations_path),
         {:ok, expectations} <- Yaml.read_file(eval_case.expectations_path),
         {:ok, checks} <- fetch_checks(expectations) do
      {:ok, %{eval_case | checks: checks}}
    end
  end

  defp from_config(path, config) do
    with {:ok, skill} <- fetch_string(config, "skill"),
         {:ok, name} <- fetch_string(config, "name"),
         {:ok, prompt} <- fetch_string(config, "prompt"),
         {:ok, fixture} <- fetch_string(config, "fixture"),
         {:ok, expectations} <- fetch_string(config, "expectations") do
      {:ok,
       %__MODULE__{
         path: path,
         skill: skill,
         name: name,
         prompt_path: Path.join(path, prompt),
         fixture_dir: Path.join(path, fixture),
         expectations_path: Path.join(path, expectations),
         checks: []
       }}
    end
  end

  defp fetch_checks(%{"checks" => checks}) when is_list(checks), do: validate_check_ids(checks)
  defp fetch_checks(_), do: {:error, {:invalid_expectations, "checks must be a list"}}

  defp validate_check_ids(checks) do
    Enum.reduce_while(checks, {:ok, MapSet.new()}, fn
      %{"id" => id}, {:ok, seen} when is_binary(id) ->
        if MapSet.member?(seen, id) do
          {:halt, {:error, {:duplicate_check_id, id}}}
        else
          {:cont, {:ok, MapSet.put(seen, id)}}
        end

      _check, _acc ->
        {:halt, {:error, {:invalid_expectations, "check id must be a string"}}}
    end)
    |> case do
      {:ok, _seen} -> {:ok, checks}
      error -> error
    end
  end

  defp fetch_string(config, key) do
    case Map.fetch(config, key) do
      {:ok, value} when is_binary(value) -> {:ok, value}
      {:ok, _value} -> {:error, {:invalid_eval_config, key, "must be a string"}}
      :error -> {:error, {:invalid_eval_config, key, "is required"}}
    end
  end

  defp require_file(path) do
    if File.regular?(path), do: :ok, else: {:error, {:missing_file, path}}
  end
end
```

- [ ] **Step 4: Implement run and runner modules**

Create `skill_evaluator/lib/skill_evaluator/run.ex`:

```elixir
defmodule SkillEvaluator.Run do
  @moduledoc false

  @enforce_keys [:id, :path, :readme_path]
  defstruct [:id, :path, :readme_path]

  @type t :: %__MODULE__{
          id: String.t(),
          path: String.t(),
          readme_path: String.t()
        }
end
```

Create `skill_evaluator/lib/skill_evaluator/runner.ex`:

```elixir
defmodule SkillEvaluator.Runner do
  @moduledoc false

  @callback run(SkillEvaluator.EvalCase.t(), keyword()) ::
              {:ok, SkillEvaluator.Run.t()} | {:error, term()}
end
```

Create `skill_evaluator/lib/skill_evaluator/runners/artifact_runner.ex`:

```elixir
defmodule SkillEvaluator.Runners.ArtifactRunner do
  @moduledoc false

  @behaviour SkillEvaluator.Runner

  alias SkillEvaluator.Run

  @impl true
  def run(eval_case, opts) do
    run_id = Keyword.fetch!(opts, :run_id)
    run_path = Path.join([eval_case.path, "runs", run_id])

    if File.dir?(run_path) do
      {:ok, %Run{id: run_id, path: run_path, readme_path: Path.join(run_path, "README.md")}}
    else
      {:error, {:missing_run, run_path}}
    end
  end
end
```

- [ ] **Step 5: Run eval case tests to verify they pass**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/eval_case_test.exs
```

Expected: PASS.

- [ ] **Step 6: Commit eval case and artifact runner**

Run:

```bash
git add skill_evaluator
git commit -m "Load eval cases and artifact runs"
```

Expected: commit succeeds.

### Task 4: Build Context And Detect Fixture Facts

**Files:**
- Create: `skill_evaluator/lib/skill_evaluator/context.ex`
- Create: `skill_evaluator/lib/skill_evaluator/detector.ex`
- Create: `skill_evaluator/test/skill_evaluator/context_test.exs`

- [ ] **Step 1: Write failing context tests**

Create `skill_evaluator/test/skill_evaluator/context_test.exs`:

```elixir
defmodule SkillEvaluator.ContextTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.Context
  alias SkillEvaluator.EvalCase
  alias SkillEvaluator.Runners.ArtifactRunner

  @eval_path Path.expand("../../../evals/readme-writer/basic-elixir-project", __DIR__)

  test "builds context with README text and conservative detections" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)
    assert {:ok, run} = ArtifactRunner.run(eval_case, run_id: "passing")
    assert {:ok, context} = Context.build(eval_case, run)

    assert context.eval_case == eval_case
    assert context.run == run
    assert context.readme_text =~ "# Basic Elixir Project"
    assert context.detected.languages == [:elixir]
    assert context.detected.commands == ["mix test"]
    assert context.detected.files["mix.exs"] == true
    assert context.detected.files["LICENSE"] == false
  end

  test "builds context when README is missing so readme_exists can fail normally" do
    root = Path.join(System.tmp_dir!(), "missing-readme-eval")
    eval_dir = Path.join(root, "case")
    fixture_dir = Path.join(eval_dir, "fixture")
    run_dir = Path.join(eval_dir, "runs/no-readme")

    try do
      File.rm_rf!(root)
      File.mkdir_p!(fixture_dir)
      File.mkdir_p!(run_dir)
      File.write!(Path.join(eval_dir, "eval.yml"), "skill: readme-writer\nname: missing-readme\nprompt: prompt.md\nfixture: fixture\nexpectations: expectations.yml\n")
      File.write!(Path.join(eval_dir, "prompt.md"), "Create a README.")
      File.write!(Path.join(eval_dir, "expectations.yml"), "checks:\n  - id: readme_exists\n")

      assert {:ok, eval_case} = EvalCase.load(eval_dir)
      assert {:ok, run} = ArtifactRunner.run(eval_case, run_id: "no-readme")
      assert {:ok, context} = Context.build(eval_case, run)

      assert context.readme_text == ""
      assert context.readme_path == Path.join(run_dir, "README.md")
    after
      File.rm_rf(root)
    end
  end
end
```

- [ ] **Step 2: Run context tests to verify they fail**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/context_test.exs
```

Expected: FAIL because `SkillEvaluator.Context` is not defined.

- [ ] **Step 3: Implement detector**

Create `skill_evaluator/lib/skill_evaluator/detector.ex`:

```elixir
defmodule SkillEvaluator.Detector do
  @moduledoc false

  def detect(fixture_dir) do
    files = %{
      "mix.exs" => File.regular?(Path.join(fixture_dir, "mix.exs")),
      "LICENSE" => license_file?(fixture_dir),
      ".github/workflows" => File.dir?(Path.join(fixture_dir, ".github/workflows"))
    }

    %{
      languages: detect_languages(files),
      commands: detect_commands(files),
      files: files
    }
  end

  defp detect_languages(%{"mix.exs" => true}), do: [:elixir]
  defp detect_languages(_files), do: []

  defp detect_commands(%{"mix.exs" => true}), do: ["mix test"]
  defp detect_commands(_files), do: []

  defp license_file?(fixture_dir) do
    Enum.any?(["LICENSE", "LICENSE.md", "LICENSE.txt"], fn name ->
      File.regular?(Path.join(fixture_dir, name))
    end)
  end
end
```

- [ ] **Step 4: Implement context builder**

Create `skill_evaluator/lib/skill_evaluator/context.ex`:

```elixir
defmodule SkillEvaluator.Context do
  @moduledoc false

  alias SkillEvaluator.Detector

  @enforce_keys [
    :eval_case,
    :run,
    :fixture_dir,
    :run_dir,
    :readme_path,
    :readme_text,
    :detected
  ]
  defstruct [
    :eval_case,
    :run,
    :fixture_dir,
    :run_dir,
    :readme_path,
    :readme_text,
    :detected
  ]

  def build(eval_case, run) do
    readme_text =
      if File.regular?(run.readme_path) do
        File.read!(run.readme_path)
      else
        ""
      end

    {:ok,
     %__MODULE__{
       eval_case: eval_case,
       run: run,
       fixture_dir: eval_case.fixture_dir,
       run_dir: run.path,
       readme_path: run.readme_path,
       readme_text: readme_text,
       detected: Detector.detect(eval_case.fixture_dir)
     }}
  end
end
```

- [ ] **Step 5: Run context tests to verify they pass**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/context_test.exs
```

Expected: PASS.

- [ ] **Step 6: Commit context and detection**

Run:

```bash
git add skill_evaluator
git commit -m "Build evaluation context from artifacts"
```

Expected: commit succeeds.

### Task 5: Implement Deterministic Checks

**Files:**
- Create: `skill_evaluator/lib/skill_evaluator/check_result.ex`
- Create: `skill_evaluator/lib/skill_evaluator/check_registry.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checker.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checks/readme_exists.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checks/has_project_title.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checks/mentions_detected_language.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checks/includes_command.ex`
- Create: `skill_evaluator/lib/skill_evaluator/checks/does_not_claim_file.ex`
- Create: `skill_evaluator/test/skill_evaluator/checker_test.exs`

- [ ] **Step 1: Write failing checker tests**

Create `skill_evaluator/test/skill_evaluator/checker_test.exs`:

```elixir
defmodule SkillEvaluator.CheckerTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.Checker
  alias SkillEvaluator.Context
  alias SkillEvaluator.EvalCase
  alias SkillEvaluator.Runners.ArtifactRunner

  @eval_path Path.expand("../../../evals/readme-writer/basic-elixir-project", __DIR__)

  test "passing README passes deterministic checks" do
    context = context_for!("passing")

    assert {:ok, results} = Checker.run(context.eval_case.checks, context)
    assert Enum.all?(results, &(&1.status in [:pass, :skip]))
    assert Enum.any?(results, &(&1.id == "includes_command" and &1.status == :pass))
  end

  test "failing README reports unsupported claims and missing expected content" do
    context = context_for!("failing")

    assert {:ok, results} = Checker.run(context.eval_case.checks, context)

    failures = Enum.filter(results, &(&1.status == :fail))
    assert Enum.any?(failures, &(&1.id == "has_project_title"))
    assert Enum.any?(failures, &(&1.id == "includes_command"))
    assert Enum.any?(failures, &(&1.id == "no_license_claim" and &1.message =~ "LICENSE"))
    assert Enum.any?(failures, &(&1.id == "no_ci_claim" and &1.message =~ ".github/workflows"))
  end

  test "unknown check types fail setup before scoring" do
    context = context_for!("passing")

    assert {:error, {:unknown_check, "missing_check"}} =
             Checker.run([%{"id" => "missing_check"}], context)
  end

  defp context_for!(run_id) do
    {:ok, eval_case} = EvalCase.load(@eval_path)
    {:ok, run} = ArtifactRunner.run(eval_case, run_id: run_id)
    {:ok, context} = Context.build(eval_case, run)
    context
  end
end
```

- [ ] **Step 2: Run checker tests to verify they fail**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/checker_test.exs
```

Expected: FAIL because checker modules are not defined.

- [ ] **Step 3: Implement check result and registry**

Create `skill_evaluator/lib/skill_evaluator/check_result.ex`:

```elixir
defmodule SkillEvaluator.CheckResult do
  @moduledoc false

  @enforce_keys [:id, :status, :message]
  defstruct [:id, :status, :message]

  def pass(id, message), do: %__MODULE__{id: id, status: :pass, message: message}
  def fail(id, message), do: %__MODULE__{id: id, status: :fail, message: message}
  def skip(id, message), do: %__MODULE__{id: id, status: :skip, message: message}
end
```

Create `skill_evaluator/lib/skill_evaluator/check_registry.ex`:

```elixir
defmodule SkillEvaluator.CheckRegistry do
  @moduledoc false

  @checks %{
    "readme_exists" => SkillEvaluator.Checks.ReadmeExists,
    "has_project_title" => SkillEvaluator.Checks.HasProjectTitle,
    "mentions_detected_language" => SkillEvaluator.Checks.MentionsDetectedLanguage,
    "includes_command" => SkillEvaluator.Checks.IncludesCommand,
    "does_not_claim_file" => SkillEvaluator.Checks.DoesNotClaimFile
  }

  def fetch(check_type), do: Map.fetch(@checks, check_type)
end
```

- [ ] **Step 4: Implement checker execution**

Create `skill_evaluator/lib/skill_evaluator/checker.ex`:

```elixir
defmodule SkillEvaluator.Checker do
  @moduledoc false

  alias SkillEvaluator.CheckRegistry

  def run(check_specs, context) when is_list(check_specs) do
    Enum.reduce_while(check_specs, {:ok, []}, fn spec, {:ok, results} ->
      with {:ok, id} <- fetch_id(spec),
           check_type = Map.get(spec, "check", id),
           {:ok, module} <- CheckRegistry.fetch(check_type) do
        {:cont, {:ok, [module.run(spec, context) | results]}}
      else
        :error -> {:halt, {:error, {:unknown_check, Map.get(spec, "check", spec["id"])}}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, results} -> {:ok, Enum.reverse(results)}
      error -> error
    end
  end

  defp fetch_id(%{"id" => id}) when is_binary(id), do: {:ok, id}
  defp fetch_id(_spec), do: {:error, {:invalid_check, "id is required"}}
end
```

The checker preserves each YAML `id` as the result identity. Registry lookup uses `check` when present and falls back to `id` when `check` is omitted.

- [ ] **Step 5: Implement README existence and title checks**

Create `skill_evaluator/lib/skill_evaluator/checks/readme_exists.ex`:

```elixir
defmodule SkillEvaluator.Checks.ReadmeExists do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id}, context) do
    if File.regular?(context.readme_path) do
      CheckResult.pass(id, "README.md exists")
    else
      CheckResult.fail(id, "README.md was not found at #{context.readme_path}")
    end
  end
end
```

Create `skill_evaluator/lib/skill_evaluator/checks/has_project_title.ex`:

```elixir
defmodule SkillEvaluator.Checks.HasProjectTitle do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "title" => title}, context) do
    expected_heading = "# " <> title

    if String.contains?(context.readme_text, expected_heading) do
      CheckResult.pass(id, "README includes title #{inspect(title)}")
    else
      CheckResult.fail(id, "README does not include title heading #{inspect(expected_heading)}")
    end
  end
end
```

- [ ] **Step 6: Implement language and command checks**

Create `skill_evaluator/lib/skill_evaluator/checks/mentions_detected_language.ex`:

```elixir
defmodule SkillEvaluator.Checks.MentionsDetectedLanguage do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "language" => language}, context) do
    language_atom = String.to_existing_atom(language)

    cond do
      language_atom not in context.detected.languages ->
        CheckResult.skip(id, "Language #{language} was not detected in fixture")

      String.contains?(String.downcase(context.readme_text), String.downcase(language)) ->
        CheckResult.pass(id, "README mentions detected language #{language}")

      true ->
        CheckResult.fail(id, "README does not mention detected language #{language}")
    end
  rescue
    ArgumentError -> CheckResult.fail(id, "Unsupported language parameter #{inspect(language)}")
  end
end
```

Create `skill_evaluator/lib/skill_evaluator/checks/includes_command.ex`:

```elixir
defmodule SkillEvaluator.Checks.IncludesCommand do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "command" => command} = spec, context) do
    required_file = spec["when_file_exists"]

    cond do
      required_file && context.detected.files[required_file] != true ->
        CheckResult.skip(id, "Skipped because #{required_file} was not detected")

      command not in context.detected.commands ->
        CheckResult.skip(id, "Skipped because command #{command} was not detected")

      String.contains?(context.readme_text, command) ->
        CheckResult.pass(id, "README includes command #{command}")

      true ->
        CheckResult.fail(id, "README does not include command #{command}")
    end
  end
end
```

- [ ] **Step 7: Implement unsupported-claim check**

Create `skill_evaluator/lib/skill_evaluator/checks/does_not_claim_file.ex`:

```elixir
defmodule SkillEvaluator.Checks.DoesNotClaimFile do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "file" => file, "forbidden_claims" => claims}, context) do
    if context.detected.files[file] == true do
      CheckResult.skip(id, "#{file} exists, so forbidden claim check is not applicable")
    else
      lower_readme = String.downcase(context.readme_text)

      found =
        Enum.filter(claims, fn claim ->
          String.contains?(lower_readme, String.downcase(claim))
        end)

      if found == [] do
        CheckResult.pass(id, "README does not claim #{file} details without evidence")
      else
        CheckResult.fail(id, "README claims #{file} details without evidence: #{Enum.join(found, ", ")}")
      end
    end
  end
end
```

- [ ] **Step 8: Run checker tests to verify they pass**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/checker_test.exs
```

Expected: PASS.

- [ ] **Step 9: Commit deterministic checks**

Run:

```bash
git add skill_evaluator
git commit -m "Add deterministic README checks"
```

Expected: commit succeeds.

### Task 6: Add Public Scoring API And Mix Task

**Files:**
- Create: `skill_evaluator/lib/skill_evaluator.ex`
- Create: `skill_evaluator/lib/skill_evaluator/console_reporter.ex`
- Create: `skill_evaluator/lib/mix/tasks/skill_eval.score.ex`
- Create: `skill_evaluator/test/skill_evaluator/score_integration_test.exs`

- [ ] **Step 1: Write failing integration tests**

Create `skill_evaluator/test/skill_evaluator/score_integration_test.exs`:

```elixir
defmodule SkillEvaluator.ScoreIntegrationTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.ConsoleReporter

  @eval_path Path.expand("../../../evals/readme-writer/basic-elixir-project", __DIR__)

  test "score returns passing summary for passing artifact" do
    assert {:ok, report} = SkillEvaluator.score(@eval_path, run_id: "passing")

    assert report.summary.fail == 0
    assert report.summary.pass > 0
    assert Enum.any?(report.results, &(&1.id == "readme_exists" and &1.status == :pass))
  end

  test "score returns failing summary for failing artifact" do
    assert {:ok, report} = SkillEvaluator.score(@eval_path, run_id: "failing")

    assert report.summary.fail > 0
    assert Enum.any?(report.results, &(&1.status == :fail))
  end

  test "console reporter prints actionable result lines" do
    assert {:ok, report} = SkillEvaluator.score(@eval_path, run_id: "failing")

    output = ConsoleReporter.format(report)

    assert output =~ "FAIL"
    assert output =~ "has_project_title"
    assert output =~ "Summary:"
  end
end
```

- [ ] **Step 2: Run integration tests to verify they fail**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/score_integration_test.exs
```

Expected: FAIL because `SkillEvaluator.score/2` and `ConsoleReporter` are not defined.

- [ ] **Step 3: Implement public scoring API**

Create `skill_evaluator/lib/skill_evaluator.ex`:

```elixir
defmodule SkillEvaluator do
  @moduledoc false

  alias SkillEvaluator.Checker
  alias SkillEvaluator.Context
  alias SkillEvaluator.EvalCase
  alias SkillEvaluator.Runners.ArtifactRunner

  def score(eval_path, opts) do
    with {:ok, eval_case} <- EvalCase.load(eval_path),
         {:ok, run} <- ArtifactRunner.run(eval_case, opts),
         {:ok, context} <- Context.build(eval_case, run),
         {:ok, results} <- Checker.run(eval_case.checks, context) do
      {:ok, build_report(eval_case, run, results)}
    end
  end

  defp build_report(eval_case, run, results) do
    summary =
      Enum.reduce(results, %{pass: 0, fail: 0, skip: 0}, fn result, acc ->
        Map.update!(acc, result.status, &(&1 + 1))
      end)

    %{
      eval_case: eval_case,
      run: run,
      results: results,
      summary: summary
    }
  end
end
```

- [ ] **Step 4: Implement console reporter**

Create `skill_evaluator/lib/skill_evaluator/console_reporter.ex`:

```elixir
defmodule SkillEvaluator.ConsoleReporter do
  @moduledoc false

  def format(report) do
    result_lines =
      Enum.map(report.results, fn result ->
        "#{label(result.status)} #{result.id}: #{result.message}"
      end)

    summary = report.summary

    Enum.join(
      [
        "Eval: #{report.eval_case.skill}/#{report.eval_case.name}",
        "Run: #{report.run.id}",
        "",
        Enum.join(result_lines, "\n"),
        "",
        "Summary: #{summary.pass} passed, #{summary.fail} failed, #{summary.skip} skipped"
      ],
      "\n"
    )
  end

  defp label(:pass), do: "PASS"
  defp label(:fail), do: "FAIL"
  defp label(:skip), do: "SKIP"
end
```

- [ ] **Step 5: Implement Mix task**

Create `skill_evaluator/lib/mix/tasks/skill_eval.score.ex`:

```elixir
defmodule Mix.Tasks.SkillEval.Score do
  @moduledoc "Scores an existing skill eval run artifact."
  use Mix.Task

  alias SkillEvaluator.ConsoleReporter

  @shortdoc "Scores an existing skill eval run"

  @impl true
  def run(args) do
    {opts, positional, invalid} = OptionParser.parse(args, switches: [run: :string])

    case {positional, opts[:run], invalid} do
      {[eval_path], run_id, []} when is_binary(run_id) ->
        execute(eval_path, run_id)

      _ ->
        Mix.shell().error("Usage: mix skill_eval.score PATH_TO_EVAL --run RUN_ID")
        exit({:shutdown, 2})
    end
  end

  defp execute(eval_path, run_id) do
    case SkillEvaluator.score(eval_path, run_id: run_id) do
      {:ok, report} ->
        Mix.shell().info(ConsoleReporter.format(report))

        if report.summary.fail > 0 do
          exit({:shutdown, 1})
        end

      {:error, reason} ->
        Mix.shell().error("Error: #{inspect(reason)}")
        exit({:shutdown, 2})
    end
  end
end
```

- [ ] **Step 6: Run integration tests to verify they pass**

Run:

```bash
cd skill_evaluator
mix test test/skill_evaluator/score_integration_test.exs
```

Expected: PASS.

- [ ] **Step 7: Manually verify the Mix task on passing and failing runs**

Run:

```bash
cd skill_evaluator
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing
```

Expected: command exits `0` and prints a summary with `0 failed`.

Run:

```bash
cd skill_evaluator
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing
```

Expected: command exits `1` and prints failures for title, command, license, and CI claims.

- [ ] **Step 8: Commit scoring API and CLI task**

Run:

```bash
git add skill_evaluator
git commit -m "Add artifact scoring CLI"
```

Expected: commit succeeds.

### Task 7: Validate Full Body Of Work

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update the repository README**

Replace `README.md` with:

````markdown
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
````

- [ ] **Step 2: Run formatter**

Run:

```bash
cd skill_evaluator
mix format
```

Expected: formatter completes without errors.

- [ ] **Step 3: Run full tests**

Run:

```bash
cd skill_evaluator
mix test
```

Expected: all tests pass.

- [ ] **Step 4: Verify final CLI behavior**

Run:

```bash
cd skill_evaluator
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing
```

Expected: exits `0`, includes `Summary:`, and reports no failures.

Run:

```bash
cd skill_evaluator
mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing
```

Expected: exits `1`, includes `Summary:`, and reports at least one failure.

- [ ] **Step 5: Check git status**

Run:

```bash
git status --short
```

Expected: only intended files are modified or untracked before the final commit.

- [ ] **Step 6: Commit final README and formatting changes**

Run:

```bash
git add README.md skill_evaluator
git commit -m "Document skill evaluator usage"
```

Expected: commit succeeds.

## Validation Evidence To Capture

Before opening or updating a PR, capture these in the PR summary:

- `cd skill_evaluator && mix deps.get`
- `cd skill_evaluator && mix format`
- `cd skill_evaluator && mix test`
- `cd skill_evaluator && mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run passing`
- `cd skill_evaluator && mix skill_eval.score ../evals/readme-writer/basic-elixir-project --run failing`

The failing artifact command is expected to exit `1`; record the failure output as evidence that deterministic checks catch bad README claims.

## Risk Notes

- Failure mode: YAML dependency API changes. Mitigation: all YAML parsing is isolated in `SkillEvaluator.Yaml`.
- Failure mode: deterministic checks are too shallow. Mitigation: add regression evals from real README failures before adding subjective checks.
- Failure mode: language detection overclaims facts. Mitigation: keep `SkillEvaluator.Detector` conservative and favor explicit check parameters.
- Rollback path: revert the implementation commits; the repository returns to the design-only state.
- Follow-up work: add `CliRunner` once artifact-only scoring is useful enough to automate real agent runs.
