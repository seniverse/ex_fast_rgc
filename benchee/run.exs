{:ok, db} = FastRGC.load()

:mybench.run([
    lookup:
      fn ->
        FastRGC.lookup(db, %{lat: 39.0, lng: 116.0})
      end,
    rand: {
      fn ->
        x = :rand.uniform(6300) - 1
        y = :rand.uniform(3700) - 1
        FastRGC.lookup_index(db, x, y)      
      end,
      fn -> 
        :rand.seed(:exrop, {0,0,0}) 
      end    
    }
  ], 5000, %{
    base: {
      fn -> 
        x = :rand.uniform(6300) - 1
        y = :rand.uniform(3700) - 1
        {x, y}
      end,
      fn -> 
        :rand.seed(:exrop, {0,0,0}) 
      end
    }
  }
)
