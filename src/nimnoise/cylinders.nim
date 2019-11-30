import modulebase
from math import sqrt, floor

const
  DEFAULT_CYLINDERS_FREQUENCY = 1.0.float64

type
  Cylinders* = ref object of ModuleBase
    frequency: float64

proc newCylinders*(): Cylinders =
  result = new Cylinders
  result.frequency = DEFAULT_CYLINDERS_FREQUENCY
  result.base(0)

proc getFrequency*(c: Cylinders): float64 = c.frequency

proc setFrequency*(c: Cylinders, frequency: float64) = c.frequency = frequency

method getValue*(c: Cylinders, noiseX, noiseY, noiseZ: float64): float64 =
  let
    x = noiseX * c.frequency
    z = noiseZ * c.frequency
    dfc = sqrt(x * x + z * z)
    dfss = dfc - floor(dfc)
    dfls = 1.0 - dfss
    nd = min(dfss, dfls)
  1.0 - (nd * 4.0)
