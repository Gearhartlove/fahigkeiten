defmodule SkillEvaluator.Detector do
  @moduledoc false

  def detect(fixture_dir) do
    files = %{
      "mix.exs" => File.regular?(Path.join(fixture_dir, "mix.exs")),
      "LICENSE" => license_file?(fixture_dir),
      ".github/workflows" => File.dir?(Path.join(fixture_dir, ".github/workflows"))
    }

    %{
      languages: detect_languages(files),
      commands: detect_commands(files),
      files: files
    }
  end

  defp detect_languages(%{"mix.exs" => true}), do: [:elixir]
  defp detect_languages(_files), do: []

  defp detect_commands(%{"mix.exs" => true}), do: ["mix test"]
  defp detect_commands(_files), do: []

  defp license_file?(fixture_dir) do
    Enum.any?(["LICENSE", "LICENSE.md", "LICENSE.txt"], fn name ->
      File.regular?(Path.join(fixture_dir, name))
    end)
  end
end
