defmodule SkillEvaluator.Run do
  @moduledoc false

  @enforce_keys [:id, :path, :readme_path]
  defstruct [:id, :path, :readme_path]

  @type t :: %__MODULE__{
          id: String.t(),
          path: String.t(),
          readme_path: String.t()
        }
end
