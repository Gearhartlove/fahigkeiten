defmodule SkillEvaluator.Checks.MentionsDetectedLanguage do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def validate(%{"id" => _id, "language" => language}) when is_binary(language), do: :ok
  def validate(%{"id" => id}), do: {:error, {:invalid_check, id, "language is required"}}

  def run(%{"id" => id, "language" => language}, context) do
    language_atom = String.to_existing_atom(language)

    cond do
      language_atom not in context.detected.languages ->
        CheckResult.skip(id, "Language #{language} was not detected in fixture")

      String.contains?(String.downcase(context.readme_text), String.downcase(language)) ->
        CheckResult.pass(id, "README mentions detected language #{language}")

      true ->
        CheckResult.fail(id, "README does not mention detected language #{language}")
    end
  rescue
    ArgumentError -> CheckResult.fail(id, "Unsupported language parameter #{inspect(language)}")
  end
end
