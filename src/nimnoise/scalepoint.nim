import modulebase

const
  DEFAULT_SCALE_POINT_X = 0.0.float64
  DEFAULT_SCALE_POINT_Y = 0.0.float64
  DEFAULT_SCALE_POINT_Z = 0.0.float64

type
  ScalePoint* = ref object of ModuleBase
    xScale, yScale, zScale: float64

proc newScalePoint*(): ScalePoint =
  result = new ScalePoint
  result.xScale = DEFAULT_SCALE_POINT_X
  result.yScale = DEFAULT_SCALE_POINT_Y
  result.zScale = DEFAULT_SCALE_POINT_Z
  result.sourceModuleCount = 1
  result.base(1)

proc getXScale*(sp: ScalePoint): float64 = sp.xScale
proc getYScale*(sp: ScalePoint): float64 = sp.yScale
proc getZScale*(sp: ScalePoint): float64 = sp.zScale

proc setXScale*(sp: ScalePoint, xScale: float64) = sp.xScale = xScale
proc setXScale*(sp: ScalePoint, yScale: float64) = sp.yScale = yScale
proc setXScale*(sp: ScalePoint, zScale: float64) = sp.zScale = zScale

proc setScale*(sp: ScalePoint, scale: float64) =
  sp.xScale = scale
  sp.yScale = scale
  sp.zScale = scale

proc setScale*(sp: ScalePoint, xScale, yScale, zScale: float64) =
  sp.xScale = xScale
  sp.yScale = yScale
  sp.zScale = zScale

method getValue*(sp: ScalePoint, noiseX, noiseY, noiseZ: float64): float64 =
  sp.sourceModules[0].getValue(noiseX * sp.xScale, noiseY * sp.yScale, noiseZ * sp.zScale)