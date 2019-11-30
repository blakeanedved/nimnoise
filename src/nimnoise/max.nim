import modulebase

type
  Max* = ref object of ModuleBase

proc newMax*(): Max =
  result = new Max
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(m: Max, noiseX, noiseY, noiseZ: float64): float64 =
  max(m.sourceModules[0].getValue(noiseX, noiseY, noiseZ), m.sourceModules[0].getValue(noiseX, noiseY, noiseZ))