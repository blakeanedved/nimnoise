import modulebase

const
  DEFAULT_CONST_VALUE = 0.0.float64

type
  Const* = ref object of ModuleBase
    value: float64

proc newConst*(): Const =
  result = new Const
  result.value = DEFAULT_CONST_VALUE
  result.base(0)

proc getConstValue*(c: Const): float64 = c.value

proc setConstValue*(c: Const, value: float64) = c.value = value

method getValue*(c: Const, noiseX, noiseY, noiseZ: float64): float64 =
  c.value
