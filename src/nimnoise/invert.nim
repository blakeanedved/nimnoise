import modulebase

type
  Invert* = ref object of ModuleBase

proc newInvert*(): Invert =
  result = new Invert
  result.sourceModuleCount = 1
  result.base(1)

method getValue*(i: Invert, noiseX, noiseY, noiseZ: float64): float64 =
  -i.sourceModules[0].getValue(noiseX, noiseY, noiseZ)