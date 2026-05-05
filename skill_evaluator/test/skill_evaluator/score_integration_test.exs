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
