defmodule SkillEvaluator.ContextTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.Context
  alias SkillEvaluator.Detector
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

      File.write!(
        Path.join(eval_dir, "eval.yml"),
        "skill: readme-writer\nname: missing-readme\nprompt: prompt.md\nfixture: fixture\nexpectations: expectations.yml\n"
      )

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

  test "does not detect GitHub workflows from an empty workflows directory" do
    root = Path.join(System.tmp_dir!(), "empty-workflows-fixture")
    workflows_dir = Path.join(root, ".github/workflows")

    try do
      File.rm_rf!(root)
      File.mkdir_p!(workflows_dir)

      detected = Detector.detect(root)

      assert detected.files[".github/workflows"] == false
    after
      File.rm_rf(root)
    end
  end

  test "detects GitHub workflows from YAML workflow files" do
    for file_name <- ["ci.yml", "release.yaml"] do
      root = Path.join(System.tmp_dir!(), "workflow-file-fixture-#{file_name}")
      workflows_dir = Path.join(root, ".github/workflows")

      try do
        File.rm_rf!(root)
        File.mkdir_p!(workflows_dir)
        File.write!(Path.join(workflows_dir, file_name), "name: CI\n")

        detected = Detector.detect(root)

        assert detected.files[".github/workflows"] == true
      after
        File.rm_rf(root)
      end
    end
  end
end
