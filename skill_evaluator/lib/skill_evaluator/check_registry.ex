defmodule SkillEvaluator.CheckRegistry do
  @moduledoc false

  @checks %{
    "readme_exists" => SkillEvaluator.Checks.ReadmeExists,
    "has_project_title" => SkillEvaluator.Checks.HasProjectTitle,
    "mentions_detected_language" => SkillEvaluator.Checks.MentionsDetectedLanguage,
    "includes_command" => SkillEvaluator.Checks.IncludesCommand,
    "does_not_claim_file" => SkillEvaluator.Checks.DoesNotClaimFile
  }

  def fetch(check_type), do: Map.fetch(@checks, check_type)
end
