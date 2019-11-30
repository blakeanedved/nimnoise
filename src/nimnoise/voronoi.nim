import modulebase
from utils import fast_floor, SQRT3, valueNoise3D
from math import sqrt

const
  DEFAULT_VORONOI_DISPLACEMENT = 1.0.float64
  DEFAULT_VORONOI_FREQUENCY = 1.0.float64
  DEFAULT_VORONOI_SEED = 0.int

type
  Voronoi* = ref object of ModuleBase
    displacement: float64
    frequency: float64
    seed: int
    distance: bool

proc newVoronoi*(): Voronoi =
  result = new Voronoi
  result.displacement = DEFAULT_VORONOI_DISPLACEMENT
  result.frequency = DEFAULT_VORONOI_FREQUENCY
  result.seed = DEFAULT_VORONOI_SEED
  result.distance = false
  result.base(0)

proc getDisplacement*(v: Voronoi): float64 = v.displacement
proc getFrequency*(v: Voronoi): float64 = v.frequency
proc getSeed*(v: Voronoi): int = v.seed
proc isDistanceEnabled*(v: Voronoi): bool = v.distance

proc setDisplacement*(v: Voronoi, displacement: float64) = v.displacement = displacement
proc setFrequency*(v: Voronoi, frequency: float64) = v.frequency = frequency
proc setSeed*(v: Voronoi, seed: int) = v.seed = seed
proc enableDistance*(v: Voronoi, distance: bool = true) = v.distance = distance
proc disableDistance*(v: Voronoi) = v.distance = false

method getValue*(v: Voronoi, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = noiseX * v.frequency
    y = noiseY * v.frequency
    z = noiseZ * v.frequency
    xi = fast_floor(x)
    yi = fast_floor(y)
    zi = fast_floor(z)
    md = 2147483647.0.float64
    xc = 0.float64
    yc = 0.float64
    zc = 0.float64
    xp, yp, zp, xd, yd, zd, d: float64

  for zcu in zi-2..zi+2:
    for ycu in yi-2..yi+2:
      for xcu in xi-2..xi+2:
        xp = xcu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed)
        yp = ycu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed + 1)
        zp = zcu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed + 2)
        xd = xp - x
        yd = yp - y
        zd = zp - z
        d = xd * xd + yd * yd + zd * zd
        if d < md:
          md = d
          xc = xp
          yc = yp
          zc = zp

  var val: float64
  if v.distance:
    xd = xc - x
    yd = yc - y
    zd = zc - z
    val = sqrt(xd * xd + yd * yd + zd * zd) * SQRT3 - 1.0
  else:
    val = 0.0

  val + (v.displacement * valueNoise3D(fast_floor(xc), fast_floor(yc), fast_floor(zc), 0))
