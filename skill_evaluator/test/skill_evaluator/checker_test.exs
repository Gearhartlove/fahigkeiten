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
