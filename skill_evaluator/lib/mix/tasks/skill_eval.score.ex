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
