import modulebase

type
  Add* = ref object of ModuleBase

proc newAdd*(): Add =
  result = new Add
  result.base(2)

method getValue*(a: Add, noiseX, noiseY, noiseZ: float64): float64 =
  a.sourceModules[0].getValue(noiseX, noiseY, noiseZ) + a.sourceModules[1].getValue(noiseX, noiseY, noiseZ)