defmodule SkillEvaluator.CheckResult do
  @moduledoc false

  @enforce_keys [:id, :status, :message]
  defstruct [:id, :status, :message]

  def pass(id, message), do: %__MODULE__{id: id, status: :pass, message: message}
  def fail(id, message), do: %__MODULE__{id: id, status: :fail, message: message}
  def skip(id, message), do: %__MODULE__{id: id, status: :skip, message: message}
end
