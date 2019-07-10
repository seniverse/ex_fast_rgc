defmodule FastRGC.ProfileRunner do
  import ExProf.Macro

  @doc "analyze with profile macro"
  def do_analyze do
    {:ok, db} = FastRGC.load()
    profile do
      1..100000
        |> Enum.map(fn _ -> FastRGC.lookup(db, %{lat: 39, lng: 116}) end)
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    {records, _block_result} = do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect "total = #{total_percent}"
  end
end

FastRGC.ProfileRunner.run()