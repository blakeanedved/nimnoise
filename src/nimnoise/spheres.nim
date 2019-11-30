import modulebase
from math import sqrt, floor

const
  DEFAULT_SPHERES_FREQUENCY = 1.0.float64

type
  Spheres* = ref object of ModuleBase
    frequency: float64

proc newSpheres*(): Spheres =
  result = new Spheres
  result.frequency = DEFAULT_SPHERES_FREQUENCY
  result.base(0)

proc getSpheres*(s: Spheres): float64 = s.frequency

proc setSpheres*(s: Spheres, frequency: float64) = s.frequency = frequency

method getValue*(s: Spheres, noiseX, noiseY, noiseZ: float64): float64 =
  let
    x = noiseX * s.frequency
    y = noiseY * s.frequency
    z = noiseZ * s.frequency
    dfc = sqrt(x * x + y * y + z * z)
    dfss = dfc - floor(dfc)
    dfls = 1.0 - dfss
    nd = min(dfss, dfls)
  1.0 - (nd * 4.0)
