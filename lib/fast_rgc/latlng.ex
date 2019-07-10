defmodule FastRGC.Latlng do
  @moduledoc false
  alias FastRGC.Latlng

  @type t :: %__MODULE__{
          lat: number(),
          lng: number()
        }

  @fields ~w|lat lng|a

  defstruct @fields

  @doc """
  Converts literally any input to `FastRGC.Latlng` instance.

  ## Examples
      iex> FastRGC.Latlng.parse(lat: 41.38, lon: 2.19)
      %FastRGC.Latlng{lat: 41.38, lon: 2.19}

      iex> FastRGC.Latlng.parse({lat: 41.38, lon: 2.19})
      %FastRGC.Latlng{lat: 41.38, lon: 2.19}
  """
  @spec parse(
          {number(), number()}
          | [number()]
          | map()
          | binary()
          | Keyword.t()
        ) :: FastRGC.Latlng.t() | {:error, any()}
  def parse(latitude: lat, longitude: lng), do: parse({lat, lng})
  def parse(%{latitude: lat, longitude: lng}), do: parse({lat, lng})

  def parse(%{lat: lat, lon: lng}), do: parse({lat, lng})
  def parse(lat: lat, lon: lng), do: parse({lat, lng})

  def parse(%{lat: lat, lng: lng}), do: parse({lat, lng})
  def parse(lat: lat, lng: lng), do: parse({lat, lng})

  def parse([lat, lng]), do: parse({lat, lng})

  def parse(latlng) when is_binary(latlng) do
    latlng
    |> String.split([",", ";", ":"])
    |> Enum.map(&Latlng.strict_float/1)
    |> parse()
  end

  def parse({lat, lng}) when is_number(lat) and is_number(lng) do
    %Latlng{lat: lat, lng: lng}
  end

  def parse(_), do: {:error, :invalid_latlng}

  @spec strict_float(binary()) :: float() | nil
  def strict_float(v) when is_binary(v) do
    case Float.parse(v) do
      {float, ""} -> float
      {_float, _non_empty} -> nil
      :error -> nil
    end
  end
end
