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
