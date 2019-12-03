import modulebase
from utils import interpolateLinear

type
  Terrace* = ref object of ModuleBase
    controlPoints: seq[float64]
    invertTerraces: bool

proc newTerrace*(): Terrace =
  result = new Terrace
  result.invertTerraces = false
  result.base(1)

proc addControlPoint*(t: Terrace, value: float64) =
  assert not t.controlPoints.contains(value)
  var index: int
  for i in t.controlPoints:
    if value < i: break
    index += 1
  t.controlPoints.insert(value, index)

proc clearAllControlPoints*(t: Terrace) = t.controlPoints = @[]

proc getControlPointArray*(t: Terrace): seq[float64] = t.controlPoints

proc getControlPointCount*(t: Terrace): int = t.controlPoints.len

proc makeControlPoints*(t: Terrace, controlPointCount: int) =
  assert controlPointCount >= 2
  t.clearAllControlPoints()
  let
    ts = 2.0 / (controlPointCount - 1).float64
  var cv = -1.0
  for i in 0..<controlPointCount:
    t.controlPoints.add(cv)
    cv += ts

proc invertTerraces*(t: Terrace, invert: bool = true) = t.invertTerraces = invert

proc isTerracesInverted*(t: Terrace): bool = t.invertTerraces

method getValue*(t: Terrace, noiseX, noiseY, noiseZ: float64): float64 =
  assert t.controlPoints.len >= 2
  var
    smv = t.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    ip: int
  
  for i in t.controlPoints:
    if smv < i: break
    ip += 1

  let
    i0 = clamp(ip - 1, 0, t.controlPoints.len - 1)
    i1 = clamp(ip, 0, t.controlPoints.len - 1)
  
  if i0 == i1:
    return t.controlPoints[i1]
  
  var
    v0 = t.controlPoints[i0]
    v1 = t.controlPoints[i1]
    a = (smv - v0) / (v1 - v0)
  
  if t.invertTerraces:
    a = 1.0 - a
    let t = v0
    v0 = v1
    v1 = t

  a *= a

  interpolateLinear(v0, v1, a)