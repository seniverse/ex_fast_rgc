
{:ok, db} = FastRGC.load()

loop = 1000000

start = :erlang.monotonic_time()
1..loop
  |> Enum.each(fn _ -> 
    FastRGC.lookup_index(db, :random.uniform(6100), :random.uniform(5100)) 
  end)
finish = :erlang.monotonic_time()

ts = :erlang.convert_time_unit(finish - start, :native, :microsecond)

IO.puts "#{ts/loop} us"
