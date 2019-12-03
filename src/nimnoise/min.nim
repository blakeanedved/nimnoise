import modulebase

type
  Min* = ref object of ModuleBase

proc newMin*(): Min =
  result = new Min
  result.base(2)

method getValue*(m: Min, noiseX, noiseY, noiseZ: float64): float64 =
  min(m.sourceModules[0].getValue(noiseX, noiseY, noiseZ), m.sourceModules[0].getValue(noiseX, noiseY, noiseZ))