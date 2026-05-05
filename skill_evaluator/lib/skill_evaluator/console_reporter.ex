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
