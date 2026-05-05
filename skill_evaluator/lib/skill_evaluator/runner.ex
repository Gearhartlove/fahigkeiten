defmodule SkillEvaluator.Runner do
  @moduledoc false

  @callback run(SkillEvaluator.EvalCase.t(), keyword()) ::
              {:ok, SkillEvaluator.Run.t()} | {:error, term()}
end
