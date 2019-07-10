defmodule FastRGC.MetaData do
  @moduledoc false
  @metadata :ex_fast_rgc
            |> Application.app_dir("priv")
            |> Path.join("china.meta.json")
            |> File.read!()
            |> Poison.decode!()

  def query(id) when is_number(id) do
    Map.get(@metadata, to_string(id))
  end

  def query(id) when is_binary(id) do
    Map.get(@metadata, id)
  end
end
