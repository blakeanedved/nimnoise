import modulebase

let
  DEFAULT_CLAMP_LOWER_BOUND = -1.0.float64
  DEFAULT_CLAMP_UPPER_BOUND = 1.0.float64

type
  Clamp* = ref object of ModuleBase
    lower_bound, upper_bound: float64

proc newClamp*(): Clamp =
  result = new Clamp
  result.lower_bound = DEFAULT_CLAMP_LOWER_BOUND
  result.upper_bound = DEFAULT_CLAMP_UPPER_BOUND
  result.base(1)

proc getLowerBound*(c: Clamp): float64 = c.lower_bound
proc getUpperBound*(c: Clamp): float64 = c.upper_bound

proc setBounds*(c: Clamp, lower, upper: float64) =
  c.lower_bound = lower
  c.upper_bound = upper

method getValue*(c: Clamp, noiseX, noiseY, noiseZ: float64): float64 =
  result = c.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
  if result > c.upper_bound:
    result = c.upper_bound
  elif result < c.lower_bound:
    result = c.lower_bound
