import modulebase
from utils import interpolateLinear

type
  Blend* = ref object of ModuleBase

proc newBlend*(): Blend =
  result = new Blend
  result.sourceModuleCount = 3
  result.base(3)

proc getControlModule*(b: Blend): ModuleBase = b.sourceModules[2]

proc setControlModule*(b: Blend, mb: ModuleBase) = b.sourceModules[2] = mb

method getValue*(b: Blend, noiseX, noiseY, noiseZ: float64): float64 =
  let
    h = b.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    j = b.sourceModules[1].getValue(noiseX, noiseY, noiseZ)
    k = b.sourceModules[2].getValue(noiseX, noiseY, noiseZ)
  interpolateLinear(h, j, (k + 1.0) / 2.0)