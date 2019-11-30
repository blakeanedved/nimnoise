import modulebase
from utils import mapCubicSCurve, interpolateLinear

const
  DEFAULT_SELECT_EDGE_FALLOFF = 0.0.float64
  DEFAULT_SELECT_LOWER_BOUND = -1.0.float64
  DEFAULT_SELECT_UPPER_BOUND = 1.0.float64

type
  Select* = ref object of ModuleBase
    edgeFalloff, lowerBound, upperBound: float64

proc newSelect*(): Select =
  result = new Select
  result.edgeFalloff = DEFAULT_SELECT_EDGE_FALLOFF
  result.lowerBound = DEFAULT_SELECT_LOWER_BOUND
  result.upperBound = DEFAULT_SELECT_UPPER_BOUND
  result.sourceModuleCount = 3
  result.base(3)

proc getControlModule*(s: Select): ModuleBase = s.sourceModules[2]
proc getEdgeFalloff*(s: Select): float64 = s.edgeFalloff
proc getLowerBound*(s: Select): float64 = s.lowerBound
proc getUpperBound*(s: Select): float64 = s.upperBound

proc setControlModule*(s: Select, mb: ModuleBase) = s.sourceModules[2] = mb
proc setEdgeFalloff*(s: Select, edgeFalloff: float64) = s.edgeFalloff = edgeFalloff
proc setLowerBound*(s: Select, lowerBound: float64) = s.lowerBound = lowerBound
proc setUpperBound*(s: Select, upperBound: float64) = s.upperBound = upperBound
proc setBounds*(s: Select, lowerBound, upperBound: float64) =
  s.lowerBound = lowerBound
  s.upperBound = upperBound

method getValue*(s: Select, noiseX, noiseY, noiseZ: float64): float64 =
  let cv = s.sourceModules[2].getValue(noiseX, noiseY, noiseZ)
  if s.edgeFalloff > 0.0:
    var a: float64
    if cv < (s.lowerBound - s.edgeFalloff):
      return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)

    if cv < (s.lowerBound + s.edgeFalloff):
      let
        lc = s.lowerBound - s.edgeFalloff
        uc = s.lowerBound + s.edgeFalloff
      a = mapCubicSCurve((cv - lc) / (uc - lc))
      return interpolateLinear(s.sourceModules[0].getValue(noiseX, noiseY, noiseZ), s.sourceModules[1].getValue(noiseX, noiseY, noiseZ), a)
    
    if cv < (s.upperBound - s.edgeFalloff):
      return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    
    if cv < (s.upperBound + s.edgeFalloff):
      let
        lc = s.upperBound - s.edgeFalloff
        uc = s.upperBound + s.edgeFalloff
      a = mapCubicSCurve((cv - lc) / (uc - lc))
      return interpolateLinear(s.sourceModules[1].getValue(noiseX, noiseY, noiseZ), s.sourceModules[0].getValue(noiseX, noiseY, noiseZ), a)
    
    return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)

  if cv < s.lowerBound or cv > s.upperBound:
    return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    
  return s.sourceModules[1].getValue(noiseX, noiseY, noiseZ)

    