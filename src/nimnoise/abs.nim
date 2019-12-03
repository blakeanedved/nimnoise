import modulebase

type
  Abs* = ref object of ModuleBase

proc newAbs*(): Abs =
  result = new Abs
  result.base(1)

method getValue*(a: Abs, noiseX, noiseY, noiseZ: float64): float64 =
  abs(a.sourceModules[0].getValue(noiseX, noiseY, noiseZ))
