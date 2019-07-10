defmodule FastRGCTest do
  use ExUnit.Case

  @lat 39.942618
  @lng 116.572266

  @adcode "110105"
  @name "朝阳区"

  def decode_map(<<num::unsigned-little-16, rest::binary>>, order, min, max) do
    if num > min and num < max do
      order
    else
      decode_map(rest, order + 1, min, max)
    end
  end

  def decode_map(<<num::unsigned-little-16, rest::binary>>, min, max) do
    if num > min and num < max do
      0
    else
      decode_map(rest, 1, min, max)
    end
  end

  test "load reverse geocoder database" do
    {:ok, db} = FastRGC.load()
    assert db.width > 0
  end

  test "load database and query beijing latlng" do
    {:ok, db} = FastRGC.load()
    data = FastRGC.lookup(db, [@lat, @lng])
    assert data["adcode"] == @adcode
    assert data["name"] == @name
  end

  test "query outsize of china" do
    {:ok, db} = FastRGC.load()
    data = FastRGC.lookup(db, [20, 20])
    assert data == nil
  end

  test "query with different query styles" do
    {:ok, db} = FastRGC.load()
    data = FastRGC.lookup(db, %{lat: @lat, lng: @lng})
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, %{latitude: @lat, longitude: @lng})
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, latitude: @lat, longitude: @lng)
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, %{lat: @lat, lon: @lng})
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, lat: @lat, lon: @lng)
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, lat: @lat, lng: @lng)
    assert data["adcode"] == @adcode

    data = FastRGC.lookup(db, "#{@lat}:#{@lng}")
    assert data["adcode"] == @adcode
  end

  test "query different type of database" do
    {:ok, db} = FastRGC.load()

    {base1, base2, base3} = db.base

    x1 = decode_map(db.map, 0, base1 - 1)
    x2 = decode_map(db.map, base1, base2 - 1)
    x3 = decode_map(db.map, base2, base3 - 1)
    x4 = decode_map(db.map, base3, base3 + 1000)

    IO.puts("#{base1}, #{base2}, #{base3}")
    IO.puts("#{x1}, #{x2}, #{x3} #{x4}")

    [x1, x2, x3, x4]
    |> Enum.each(fn xx ->
      y = div(xx, db.x) * db.tile
      x = rem(xx, db.x) * db.tile

      0..11
      |> Enum.each(fn i ->
        0..11
        |> Enum.each(fn j ->
          FastRGC.lookup_index(db, x + i, y + j)
        end)
      end)
    end)
  end

  test "query index directly" do
    {:ok, db} = FastRGC.load()
    id = FastRGC.lookup_index(db, 4357, 1405)
    assert FastRGC.lookup_meta(id)["adcode"] == @adcode
  end

  test "query meta" do
    assert FastRGC.lookup_meta(1002)["adcode"] == @adcode
    assert FastRGC.lookup_meta("1002")["adcode"] == @adcode
  end
end
