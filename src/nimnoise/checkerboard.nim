import modulebase
from utils import fast_floor, makeInt32Range

type
  Checkerboard* = ref object of ModuleBase

proc newCheckerboard*(): Checkerboard =
  result = new Checkerboard
  result.base(0)

method getValue*(cb: Checkerboard, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = fast_floor(makeInt32Range(noiseX))
    y = fast_floor(makeInt32Range(noiseY))
    z = fast_floor(makeInt32Range(noiseZ))
  result = if ((x and 1) xor (y and 1) xor (z and 1)) != 0:
      -1.0
    else:
      1.0
