defmodule FastRGC.Tiled do
  @moduledoc false
  alias FastRGC.Latlng
  alias FastRGC.MetaData
  require Logger
  @compile :native

  @type t :: %__MODULE__{
          width: non_neg_integer,
          height: non_neg_integer,
          xscale: float,
          yscale: float,
          xshift: float,
          yshift: float,
          tile: non_neg_integer,
          y: non_neg_integer,
          x: non_neg_integer,
          delta: non_neg_integer,
          base: list,
          map: binary,
          tile1: binary,
          tile2: binary,
          tile3: binary
        }

  defstruct width: 0,
            height: 0,
            xscale: 100,
            yscale: 100,
            xshift: 0,
            yshift: 0,
            tile: 0,
            y: 0,
            x: 0,
            delta: 0,
            base: {},
            map: <<>>,
            tile1: <<>>,
            tile2: <<>>,
            tile3: <<>>

  def decode(data) do
    case verify_magic(data) do
      {:ok, stream} ->
        {:ok, decode_meta(stream)}

      {:error, _} ->
        {:error, :invalid_database}
    end
  end

  def lookup(database, %Latlng{lat: _lat, lng: _lng} = latlng) do
    idx = lookup_index(database, latlng)
    MetaData.query(idx)
  end

  def lookup_index(database, %{lat: lat, lng: lng}) do
    # Logger.debug("xshift - #{database.xshift}")
    # Logger.debug("yshift - #{database.yshift}")
    # Logger.debug("latlng - #{lat}, #{lng}")
    x = round((lng + database.xshift) * database.xscale)
    y = round((lat + database.yshift) * database.yscale)

    lookup_index(database, x, y)
  end

  def lookup_index(
        %{
          tile: tile,
          delta: delta,
          base: {base1, base2, base3}
        } = database,
        x,
        y
      ) do
    # Logger.debug("x,y - #{x}, #{y}")

    if x < 0 or x >= database.width or y < 0 or y >= database.height do
      0
    else
      <<num::unsigned-little-16>> =
        binary_part(database.map, 2 * (div(y, tile) * database.x + div(x, tile)), 2)

      # Logger.debug("num - #{num} - order #{div(y, tile) * database.x + div(x, tile)}")
      cond do
        num == 0 ->
          0

        num < base1 ->
          num + delta

        num < base2 ->
          block_offset = (16 * 2 + tile * tile) * (num - base1)
          offset = rem(y, tile) * tile + rem(x, tile)

          # Logger.debug("block_offset - #{block_offset}, offset - #{offset}")
          <<_::bitstring-size(block_offset), id_a::unsigned-little-16, id_b::unsigned-little-16,
            _::bitstring-size(offset), bit::unsigned-size(1), _::bitstring>> = database.tile1

          case bit do
            0 -> id_a
            1 -> id_b
          end

        num < base3 ->
          block_offset = (16 * 4 + tile * tile * 2) * (num - base2)
          offset = 2 * (rem(y, tile) * tile + rem(x, tile))

          # Logger.debug("block_offset - #{block_offset}, offset - #{offset}")
          <<_::bitstring-size(block_offset), id_a::unsigned-little-16, id_b::unsigned-little-16,
            id_c::unsigned-little-16, id_d::unsigned-little-16, _::bitstring-size(offset),
            bit::unsigned-size(2), _::bitstring>> = database.tile2

          case bit do
            0 -> id_a
            1 -> id_b
            2 -> id_c
            3 -> id_d
          end

        true ->
          block_offset = tile * tile * 2 * (num - base3)
          offset = rem(y, tile) * tile + rem(x, tile)
          # Logger.debug("block_offset - #{block_offset}, offset - #{offset}")
          <<id::unsigned-little-16>> = binary_part(database.tile3, block_offset + 2 * offset, 2)
          id
      end
    end
  end

  defp verify_magic(<<0x53, 0x44, 0x42, 0x01, stream::binary>>), do: {:ok, stream}
  defp verify_magic(stream), do: {:error, stream}

  defp decode_meta(<<
         width::unsigned-little-16,
         height::unsigned-little-16,
         xscale::float-little-32,
         yscale::float-little-32,
         xshift::float-little-32,
         yshift::float-little-32,
         n::unsigned-little-16,
         y::unsigned-little-16,
         x::unsigned-little-16,
         delta::unsigned-little-16,
         count0::unsigned-little-16,
         count1::unsigned-little-16,
         count2::unsigned-little-16,
         _count3::unsigned-little-16,
         data::binary
       >>) do
    map_size = x * y * 2
    tile1_size = count1 * (16 * 2 + n * n)
    tile2_size = count2 * (16 * 4 + 2 * n * n)
    # tile3_size = count3 * (2 * n * n)

    <<map::binary-size(map_size), tile1::bitstring-size(tile1_size),
      tile2::bitstring-size(tile2_size), tile3::binary>> = data

    %FastRGC.Tiled{
      width: width,
      height: height,
      xscale: width / xscale,
      yscale: height / yscale,
      xshift: xshift,
      yshift: yshift,
      tile: n,
      y: y,
      x: x,
      delta: delta,
      base: {count0, count0 + count1, count0 + count1 + count2},
      map: map,
      tile1: tile1,
      tile2: tile2,
      tile3: tile3
    }
  end
end
