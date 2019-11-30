import modulebase
from utils import ControlPoint, interpolateCubic

type
  Curve* = ref object of ModuleBase
    controlPoints: seq[ControlPoint]

proc newCurve*(): Curve =
  result = new Curve
  result.sourceModuleCount = 1
  result.base(1)

proc addControlPoint*(c: Curve, inputValue, outputValue: float64) =
  var index: int
  for i in c.controlPoints:
    assert inputValue != i.inputValue
    if inputValue < i.inputValue: break
    index += 1
  c.controlPoints.insert(ControlPoint(inputValue: inputValue, outputValue: outputValue), index)

proc clearAllControlPoints*(c: Curve) = c.controlPoints = @[]

proc getControlPointArray*(c: Curve): seq[ControlPoint] = c.controlPoints

proc getControlPointCount*(c: Curve): int = c.controlPoints.len

method getValue*(c: Curve, noiseX, noiseY, noiseZ: float64): float64 =
  assert c.controlPoints.len >= 4
  let cpa = c.controlPoints.len
  var
    smv = c.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    ip: int

  for cp in c.controlPoints:
    if smv < cp.inputValue: break
    ip += 1
  
  let
    i0 = clamp(ip - 2, 0, cpa - 1)
    i1 = clamp(ip - 1, 0, cpa - 1)
    i2 = clamp(ip    , 0, cpa - 1)
    i3 = clamp(ip + 1, 0, cpa - 1)
  if i1 == i2:
    result = c.controlPoints[i1].outputValue
  else:
    let
      ip0 = c.controlPoints[i1].inputValue
      ip1 = c.controlPoints[i2].inputValue
      a = (smv - ip0) / (ip1 - ip0)
    result = interpolateCubic(c.controlPoints[i0].outputValue, c.controlPoints[i1].outputValue, c.controlPoints[i2].outputValue, c.controlPoints[i3].outputValue, a)
  