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
