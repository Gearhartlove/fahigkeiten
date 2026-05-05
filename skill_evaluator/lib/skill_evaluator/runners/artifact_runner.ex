defmodule SkillEvaluator.Runners.ArtifactRunner do
  @moduledoc false

  @behaviour SkillEvaluator.Runner

  alias SkillEvaluator.Run

  @impl true
  def run(eval_case, opts) do
    with {:ok, run_id} <- fetch_run_id(opts),
         runs_dir <- Path.expand(Path.join(eval_case.path, "runs")),
         run_path <- Path.expand(run_id, runs_dir),
         true <- inside_directory?(run_path, runs_dir) do
      if File.dir?(run_path) do
        {:ok, %Run{id: run_id, path: run_path, readme_path: Path.join(run_path, "README.md")}}
      else
        {:error, {:missing_run, run_path}}
      end
    else
      {:error, _reason} = error -> error
      false -> {:error, {:invalid_run_id, Keyword.get(opts, :run_id, :missing)}}
    end
  end

  defp fetch_run_id(opts) do
    case Keyword.fetch(opts, :run_id) do
      {:ok, run_id} -> validate_run_id(run_id)
      :error -> {:error, {:invalid_run_id, :missing}}
    end
  end

  defp validate_run_id(run_id)
       when is_binary(run_id) and run_id != "" do
    if String.contains?(run_id, ["/", "\\"]) or traversal_segment?(run_id) do
      {:error, {:invalid_run_id, run_id}}
    else
      {:ok, run_id}
    end
  end

  defp validate_run_id(run_id), do: {:error, {:invalid_run_id, run_id}}

  defp traversal_segment?(run_id) do
    run_id
    |> String.split(["/", "\\"], trim: false)
    |> Enum.any?(&(&1 == ".."))
  end

  defp inside_directory?(path, directory) do
    relative = Path.relative_to(path, directory)

    relative != path and relative != "." and
      not String.starts_with?(relative, ["../", ".."])
  end
end
