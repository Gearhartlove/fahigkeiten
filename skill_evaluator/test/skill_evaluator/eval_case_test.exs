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
      File.mkdir_p!(Path.join(path, "fixture"))

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

      File.write!(Path.join(path, "prompt.md"), "Write a README")

      assert {:error, {:duplicate_check_id, "readme_exists"}} = EvalCase.load(path)
    after
      File.rm_rf(path)
    end
  end

  test "returns a clear error when prompt file is missing" do
    path = Path.join(System.tmp_dir!(), "missing-prompt-eval-case")

    try do
      File.rm_rf!(path)
      File.mkdir_p!(Path.join(path, "fixture"))
      write_eval_files(path)

      prompt_path = Path.join(path, "prompt.md")
      assert {:error, {:missing_file, ^prompt_path}} = EvalCase.load(path)
    after
      File.rm_rf(path)
    end
  end

  test "returns a clear error when fixture directory is missing" do
    path = Path.join(System.tmp_dir!(), "missing-fixture-eval-case")

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      write_eval_files(path)
      File.write!(Path.join(path, "prompt.md"), "Write a README")

      fixture_path = Path.join(path, "fixture")
      assert {:error, {:missing_directory, ^fixture_path}} = EvalCase.load(path)
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

  test "artifact runner errors when run_id is missing" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)

    assert {:error, {:invalid_run_id, :missing}} = ArtifactRunner.run(eval_case, [])
  end

  test "artifact runner errors when run_id is invalid" do
    assert {:ok, eval_case} = EvalCase.load(@eval_path)

    for bad_value <- [123, "", "..", "../passing", "passing/child", "/tmp/x", "passing\\child"] do
      assert {:error, {:invalid_run_id, ^bad_value}} =
               ArtifactRunner.run(eval_case, run_id: bad_value)
    end
  end

  defp write_eval_files(path) do
    File.write!(Path.join(path, "eval.yml"), """
    skill: readme-writer
    name: invalid-paths
    prompt: prompt.md
    fixture: fixture
    expectations: expectations.yml
    """)

    File.write!(Path.join(path, "expectations.yml"), """
    checks:
      - id: readme_exists
    """)
  end
end
