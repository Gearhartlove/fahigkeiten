defmodule SkillEvaluator.Checks.DoesNotClaimFile do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def run(%{"id" => id, "file" => file, "forbidden_claims" => claims}, context) do
    if context.detected.files[file] == true do
      CheckResult.skip(id, "#{file} exists, so forbidden claim check is not applicable")
    else
      lower_readme = String.downcase(context.readme_text)

      found =
        Enum.filter(claims, fn claim ->
          String.contains?(lower_readme, String.downcase(claim))
        end)

      if found == [] do
        CheckResult.pass(id, "README does not claim #{file} details without evidence")
      else
        CheckResult.fail(
          id,
          "README claims #{file} details without evidence: #{Enum.join(found, ", ")}"
        )
      end
    end
  end
end
