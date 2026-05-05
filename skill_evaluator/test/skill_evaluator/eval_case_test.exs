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
