import modulebase
from math import pow

type
  Power* = ref object of ModuleBase

proc newPower*(): Power =
  result = new Power
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(p: Power, noiseX, noiseY, noiseZ: float64): float64 =
  pow(p.sourceModules[0].getValue(noiseX, noiseY, noiseZ), p.sourceModules[0].getValue(noiseX, noiseY, noiseZ))