defmodule SkillEvaluator.Checks.IncludesCommand do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "command" => command} = spec, context) do
    required_file = spec["when_file_exists"]

    cond do
      required_file && context.detected.files[required_file] != true ->
        CheckResult.skip(id, "Skipped because #{required_file} was not detected")

      command not in context.detected.commands ->
        CheckResult.skip(id, "Skipped because command #{command} was not detected")

      String.contains?(context.readme_text, command) ->
        CheckResult.pass(id, "README includes command #{command}")

      true ->
        CheckResult.fail(id, "README does not include command #{command}")
    end
  end
end
