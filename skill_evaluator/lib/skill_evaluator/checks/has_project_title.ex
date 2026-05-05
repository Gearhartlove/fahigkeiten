defmodule SkillEvaluator.Checks.HasProjectTitle do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "title" => title}, context) do
    expected_heading = "# " <> title

    if String.contains?(context.readme_text, expected_heading) do
      CheckResult.pass(id, "README includes title #{inspect(title)}")
    else
      CheckResult.fail(id, "README does not include title heading #{inspect(expected_heading)}")
    end
  end
end
