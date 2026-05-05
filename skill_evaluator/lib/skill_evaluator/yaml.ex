defmodule SkillEvaluator.Yaml do
  @moduledoc false

  def read_file(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:invalid_yaml, path, reason}}
    end
  rescue
    error -> {:error, {:invalid_yaml, path, error}}
  end
end
