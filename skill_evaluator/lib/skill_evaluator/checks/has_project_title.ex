defmodule SkillEvaluator.Checks.HasProjectTitle do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def validate(%{"id" => _id, "title" => title}) when is_binary(title), do: :ok
  def validate(%{"id" => id}), do: {:error, {:invalid_check, id, "title is required"}}

  def run(%{"id" => id, "title" => title}, context) do
    expected_heading = "# " <> title

    if exact_line?(context.readme_text, expected_heading) do
      CheckResult.pass(id, "README includes title #{inspect(title)}")
    else
      CheckResult.fail(id, "README does not include title heading #{inspect(expected_heading)}")
    end
  end

  defp exact_line?(text, expected_heading) do
    text
    |> String.split("\n")
    |> Enum.any?(&(String.trim(&1) == expected_heading))
  end
end
