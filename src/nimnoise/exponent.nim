import modulebase
from math import pow

const
  DEFAULT_EXPONENT = 1.0.float64

type
  Exponent* = ref object of ModuleBase
    exponent: float64

proc newExponent*(): Exponent =
  result = new Exponent
  result.exponent = DEFAULT_EXPONENT
  result.sourceModuleCount = 1
  result.base(1)

proc getExponent*(e: Exponent): float64 = e.exponent

proc setExponent*(e: Exponent, ex: float64) = e.exponent = ex

method getValue*(e: Exponent, noiseX, noiseY, noiseZ: float64): float64 =
  let val = e.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
  pow(((val + 1.0) / 2.0), e.exponent) * 2.0 - 1.0