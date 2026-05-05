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

  test "malformed checks return setup errors instead of raising" do
    context = context_for!("passing")

    assert {:error, {:invalid_check, "includes_command", message}} =
             Checker.run([%{"id" => "includes_command"}], context)

    assert message =~ "command"
  end

  test "project title check requires an exact Markdown H1 line" do
    context = context_for!("passing")
    spec = %{"id" => "has_project_title", "title" => "Basic Elixir Project"}

    assert {:ok, [%{status: :fail}]} =
             Checker.run([spec], %{context | readme_text: "## Basic Elixir Project\n"})

    assert {:ok, [%{status: :fail}]} =
             Checker.run([spec], %{context | readme_text: "# Basic Elixir Project Extra\n"})
  end

  test "unsupported claim check ignores token substrings and negative license statements" do
    context = context_for!("passing")

    spec = %{
      "id" => "no_license_claim",
      "check" => "does_not_claim_file",
      "file" => "LICENSE",
      "forbidden_claims" => ["MIT", "Apache", "license"]
    }

    readme_text = """
    # Basic Elixir Project

    Use submit to create a permit.

    No license file is included.

    No MIT license is included.

    Without an Apache license file, no license claims should be inferred.
    """

    assert {:ok, [%{status: :pass}]} = Checker.run([spec], %{context | readme_text: readme_text})
  end

  defp context_for!(run_id) do
    {:ok, eval_case} = EvalCase.load(@eval_path)
    {:ok, run} = ArtifactRunner.run(eval_case, run_id: run_id)
    {:ok, context} = Context.build(eval_case, run)
    context
  end
end
