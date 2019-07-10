defmodule FastRGC do
  @moduledoc """
  Fast Reverse geocoding for china region, and based on city-level.

  ## Usage

  To prepare lookup by latitude and longitude, you need parse database first and
  hold the parsed object for later usage:

      iex(1)> {:ok, database} = FastRGC.load()

  then lookup by latitude and longitude pair:

      iex(2)> FastRGC.lookup(database, %{lat: 39, lng: 116})
      %{
        "adcode" => "130632",
        "center" => "115.931979,38.929912",
        "name" => "安新县",
        "path" => "中华人民共和国,河北省,保定市,安新县"
      }

  if coordinate is outside of china, `nil` will be returned by `lookup/2` function.

      iex(3)> FastRGC.lookup(database, %{lat: 39, lng: 200})
      nil

  """

  alias FastRGC.Latlng
  alias FastRGC.MetaData
  alias FastRGC.Tiled

  @database :ex_fast_rgc
            |> Application.app_dir("priv")
            |> Path.join("china.tile12")
            |> File.read!()

  def load do
    @database |> Tiled.decode()
  end

  def lookup(database, latlng) when is_binary(latlng) or is_list(latlng) or is_map(latlng) do
    Tiled.lookup(database, Latlng.parse(latlng))
  end

  def lookup_index(database, x, y) do
    Tiled.lookup_index(database, x, y)
  end

  def lookup_meta(id) do
    MetaData.query(id)
  end
end
