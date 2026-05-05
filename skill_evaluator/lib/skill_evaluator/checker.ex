defmodule SkillEvaluator.Checker do
  @moduledoc false

  alias SkillEvaluator.CheckRegistry

  def run(check_specs, context) when is_list(check_specs) do
    Enum.reduce_while(check_specs, {:ok, []}, fn spec, {:ok, results} ->
      with {:ok, id} <- fetch_id(spec),
           check_type = Map.get(spec, "check", id),
           {:ok, module} <- CheckRegistry.fetch(check_type),
           :ok <- module.validate(spec) do
        {:cont, {:ok, [module.run(spec, context) | results]}}
      else
        :error -> {:halt, {:error, {:unknown_check, unknown_check_type(spec)}}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, results} -> {:ok, Enum.reverse(results)}
      error -> error
    end
  end

  defp fetch_id(%{"id" => id}) when is_binary(id), do: {:ok, id}

  defp fetch_id(spec) when is_map(spec),
    do: {:error, {:invalid_check, spec["id"], "id is required"}}

  defp fetch_id(_spec), do: {:error, {:invalid_check, nil, "id is required"}}

  defp unknown_check_type(spec) when is_map(spec), do: Map.get(spec, "check", spec["id"])
  defp unknown_check_type(_spec), do: nil
end
