defmodule SkillEvaluator.YamlTest do
  use ExUnit.Case, async: true

  alias SkillEvaluator.Yaml

  test "read_file returns parsed YAML maps" do
    path = Path.expand("../../../evals/readme-writer/basic-elixir-project/eval.yml", __DIR__)

    assert {:ok, config} = Yaml.read_file(path)
    assert config["skill"] == "readme-writer"
    assert config["name"] == "basic-elixir-project"
  end

  test "read_file wraps parser errors" do
    path = Path.join(System.tmp_dir!(), "invalid-skill-eval-yaml.yml")

    try do
      File.write!(path, "checks:\n  - id: [")

      assert {:error, {:invalid_yaml, ^path, _reason}} = Yaml.read_file(path)
    after
      File.rm(path)
    end
  end
end
