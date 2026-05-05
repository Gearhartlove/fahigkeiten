defmodule SkillEvaluator.EvalCase do
  @moduledoc false

  alias SkillEvaluator.Yaml

  @enforce_keys [:path, :skill, :name, :prompt_path, :fixture_dir, :expectations_path, :checks]
  defstruct [:path, :skill, :name, :prompt_path, :fixture_dir, :expectations_path, :checks]

  @type t :: %__MODULE__{
          path: String.t(),
          skill: String.t(),
          name: String.t(),
          prompt_path: String.t(),
          fixture_dir: String.t(),
          expectations_path: String.t(),
          checks: [map()]
        }

  def load(path) do
    eval_file = Path.join(path, "eval.yml")

    with :ok <- require_file(eval_file),
         {:ok, config} <- Yaml.read_file(eval_file),
         {:ok, eval_case} <- from_config(path, config),
         :ok <- require_file(eval_case.prompt_path),
         :ok <- require_directory(eval_case.fixture_dir),
         :ok <- require_file(eval_case.expectations_path),
         {:ok, expectations} <- Yaml.read_file(eval_case.expectations_path),
         {:ok, checks} <- fetch_checks(expectations) do
      {:ok, %{eval_case | checks: checks}}
    end
  end

  defp from_config(path, config) do
    with {:ok, skill} <- fetch_string(config, "skill"),
         {:ok, name} <- fetch_string(config, "name"),
         {:ok, prompt} <- fetch_string(config, "prompt"),
         {:ok, fixture} <- fetch_string(config, "fixture"),
         {:ok, expectations} <- fetch_string(config, "expectations") do
      {:ok,
       %__MODULE__{
         path: path,
         skill: skill,
         name: name,
         prompt_path: Path.join(path, prompt),
         fixture_dir: Path.join(path, fixture),
         expectations_path: Path.join(path, expectations),
         checks: []
       }}
    end
  end

  def fetch_checks(%{"checks" => checks}) when is_list(checks), do: validate_check_ids(checks)
  def fetch_checks(_), do: {:error, {:invalid_expectations, "checks must be a list"}}

  defp validate_check_ids(checks) do
    Enum.reduce_while(checks, {:ok, MapSet.new()}, fn
      %{"id" => id}, {:ok, seen} when is_binary(id) ->
        if MapSet.member?(seen, id) do
          {:halt, {:error, {:duplicate_check_id, id}}}
        else
          {:cont, {:ok, MapSet.put(seen, id)}}
        end

      _check, _acc ->
        {:halt, {:error, {:invalid_expectations, "check id must be a string"}}}
    end)
    |> case do
      {:ok, _seen} -> {:ok, checks}
      error -> error
    end
  end

  defp fetch_string(config, key) do
    case Map.fetch(config, key) do
      {:ok, value} when is_binary(value) -> {:ok, value}
      {:ok, _value} -> {:error, {:invalid_eval_config, key, "must be a string"}}
      :error -> {:error, {:invalid_eval_config, key, "is required"}}
    end
  end

  defp require_file(path) do
    if File.regular?(path), do: :ok, else: {:error, {:missing_file, path}}
  end

  defp require_directory(path) do
    if File.dir?(path), do: :ok, else: {:error, {:missing_directory, path}}
  end
end
