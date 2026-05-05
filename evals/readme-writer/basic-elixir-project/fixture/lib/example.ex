defmodule BasicElixirProject.Example do
  def greeting(name) when is_binary(name) do
    "Hello, " <> name
  end
end
