defmodule SkillEvaluator.Checker do
  @moduledoc false

  alias SkillEvaluator.CheckRegistry

  def run(check_specs, context) when is_list(check_specs) do
    Enum.reduce_while(check_specs, {:ok, []}, fn spec, {:ok, results} ->
      with {:ok, id} <- fetch_id(spec),
           check_type = Map.get(spec, "check", id),
           {:ok, module} <- CheckRegistry.fetch(check_type) do
        {:cont, {:ok, [module.run(spec, context) | results]}}
      else
        :error -> {:halt, {:error, {:unknown_check, Map.get(spec, "check", spec["id"])}}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, results} -> {:ok, Enum.reverse(results)}
      error -> error
    end
  end

  defp fetch_id(%{"id" => id}) when is_binary(id), do: {:ok, id}
  defp fetch_id(_spec), do: {:error, {:invalid_check, "id is required"}}
end
