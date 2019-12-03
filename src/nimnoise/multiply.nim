import modulebase

type
  Multiply* = ref object of ModuleBase

proc newMultiply*(): Multiply =
  result = new Multiply
  result.base(2)

method getValue*(m: Multiply, noiseX, noiseY, noiseZ: float64): float64 =
  m.sourceModules[0].getValue(noiseX, noiseY, noiseZ) * m.sourceModules[0].getValue(noiseX, noiseY, noiseZ)