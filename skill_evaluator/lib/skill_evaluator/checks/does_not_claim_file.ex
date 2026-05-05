defmodule SkillEvaluator.Checks.DoesNotClaimFile do
  @moduledoc false

  alias SkillEvaluator.CheckResult

  def validate(%{"id" => id, "file" => file, "forbidden_claims" => claims})
      when is_binary(file) and is_list(claims) do
    if Enum.all?(claims, &is_binary/1) do
      :ok
    else
      {:error, {:invalid_check, id, "forbidden_claims must contain only strings"}}
    end
  end

  def validate(%{"id" => id}),
    do: {:error, {:invalid_check, id, "file and forbidden_claims are required"}}

  def run(%{"id" => id, "file" => file, "forbidden_claims" => claims}, context) do
    if context.detected.files[file] == true do
      CheckResult.skip(id, "#{file} exists, so forbidden claim check is not applicable")
    else
      found =
        Enum.filter(claims, fn claim ->
          unsupported_claim?(context.readme_text, claim)
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

  defp unsupported_claim?(text, claim) do
    text
    |> claim_contexts(claim)
    |> Enum.any?(&(not negative_license_context?(&1, claim)))
  end

  defp claim_contexts(text, claim) do
    text
    |> String.split(~r/[.!?\n]/u)
    |> Enum.filter(&token_match?(&1, claim))
  end

  defp token_match?(text, claim) do
    words = Regex.scan(~r/[\p{L}\p{N}_]+/u, claim) |> List.flatten()
    pattern = Enum.map_join(words, ~S/\W+/, &Regex.escape/1)

    words != [] and Regex.match?(~r/(^|[^\p{L}\p{N}_])#{pattern}($|[^\p{L}\p{N}_])/iu, text)
  end

  defp negative_license_context?(text, claim) do
    license_claim?(claim) and
      Regex.match?(~r/\b(no|without)\b.{0,40}\blicens(e|ed|ing)\b/iu, text)
  end

  defp license_claim?(claim), do: String.downcase(claim) in ["license", "licensed", "licensing"]
end
