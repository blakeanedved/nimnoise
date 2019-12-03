import modulebase

const
  DEFAULT_BIAS = 0.0.float64
  DEFAULT_SCALE = 1.0.float64

type
  ScaleBias* = ref object of ModuleBase
    scale, bias: float64

proc newScaleBias*(): ScaleBias =
  result = new ScaleBias
  result.bias = DEFAULT_BIAS
  result.scale = DEFAULT_SCALE
  result.base(1)

proc getBias*(sb: ScaleBias): float64 = sb.bias
proc getScale*(sb: ScaleBias): float64 = sb.scale

proc setBias*(sb: ScaleBias, bias: float64): float64 = sb.bias = bias
proc setScale*(sb: ScaleBias, scale: float64): float64 = sb.scale = scale

method getValue*(sb: ScaleBias, noiseX, noiseY, noiseZ: float64): float64 =
  sb.sourceModules[0].getValue(noiseX, noiseY, noiseZ) * sb.scale + sb.bias