defmodule SkillEvaluator.Checks.ReadmeExists do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id}, context) do
    if File.regular?(context.readme_path) do
      CheckResult.pass(id, "README.md exists")
    else
      CheckResult.fail(id, "README.md was not found at #{context.readme_path}")
    end
  end
end
