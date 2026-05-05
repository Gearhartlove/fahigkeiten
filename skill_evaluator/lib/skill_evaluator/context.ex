defmodule SkillEvaluator.Context do
  @moduledoc false

  alias SkillEvaluator.Detector

  @enforce_keys [
    :eval_case,
    :run,
    :fixture_dir,
    :run_dir,
    :readme_path,
    :readme_text,
    :detected
  ]
  defstruct [
    :eval_case,
    :run,
    :fixture_dir,
    :run_dir,
    :readme_path,
    :readme_text,
    :detected
  ]

  def build(eval_case, run) do
    readme_text =
      if File.regular?(run.readme_path) do
        File.read!(run.readme_path)
      else
        ""
      end

    {:ok,
     %__MODULE__{
       eval_case: eval_case,
       run: run,
       fixture_dir: eval_case.fixture_dir,
       run_dir: run.path,
       readme_path: run.readme_path,
       readme_text: readme_text,
       detected: Detector.detect(eval_case.fixture_dir)
     }}
  end
end
