# FastRGC

Fast reverse geocoding at city level. it's inspired by [reversegeocode](https://github.com/kno10/reversegeocode), we implement same policy in elixir only for china region.

## Usage

To prepare lookup by latitude and longitude, you need parse database first and
hold the parsed object for later usage:

```elixir
    iex(1)> {:ok, database} = FastRGC.load()
```

then lookup by latitude and longitude pair:

```elixir
    iex(2)> FastRGC.lookup(database, %{lat: 39, lng: 116})
    %{
      "adcode" => "130632",
      "center" => "115.931979,38.929912",
      "name" => "安新县",
      "path" => "中华人民共和国,河北省,保定市,安新县"
    }
```

if coordinate is outside of china, `nil` will be returned by `lookup/2` function.

```elixir
    iex(3)> FastRGC.lookup(database, %{lat: 39, lng: 200})
    nil
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_fast_rgc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_fast_rgc, "~> 0.1.0"}
  ]
end
```

## Format of Database

The file format is designed to support reading read every bits directly without any decompress or query, and this binary decrease final file size from `44MB` to `~1MB`.

Orignal data is splited to 12 * 12 block, and only have four types of blocks:

Type 0, only one id in this block
Type 1, only two ids in this block
Type 2, three or four ids in this block
Type 3, four above ids in this block

```
<HEADER>
 4 Bytes - SDB\01 <0x53444201>
 2 Bytes - width of the map in pixel
 2 Bytes - height of the map in pixel
 4 Bytes - width of the map in degree
 4 Bytes - height of the map in degree
 4 Bytes - longitude offset of the map in degree
 4 Bytes - latitude offset of the map in degree
 2 Bytes - tile size
 2 Bytes - y, div(height, tile_size)
 2 Bytes - x, div(width, tile_size)
 2 Bytes - delta, offset of id number
 2 Bytes - c0, count of type 0 block
 2 Bytes - c1, count of type 1 block
 2 Bytes - c2, count of type 2 block
 2 Bytes - c3, count of type 3 block

<INDEX>
  x * y * 2 Bytes - query map for every tiled block

<BODY>
  c1 * (2 * 2 + n * n / 8) Bytes - Type1 Block Data
  c2 * (2 * 4 + 2 * n * n / 8) Bytes - Type2 Block Data
  c3 * (2 * n * n) Bytes - Type3 Block Data
<BODY>
 x bytes for each row (run-length ecoding)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_fast_rgc](https://hexdocs.pm/ex_fast_rgc).

