import modulebase

const
  DEFAULT_TRANSLATE_POINT_X = 0.0.float64
  DEFAULT_TRANSLATE_POINT_Y = 0.0.float64
  DEFAULT_TRANSLATE_POINT_Z = 0.0.float64

type
  TranslatePoint* = ref object of ModuleBase
    xTranslation, yTranslation, zTranslation: float64

proc newTranslatePoint*(): TranslatePoint =
  result = new TranslatePoint
  result.xTranslation = DEFAULT_TRANSLATE_POINT_X
  result.yTranslation = DEFAULT_TRANSLATE_POINT_Y
  result.zTranslation = DEFAULT_TRANSLATE_POINT_Z
  result.sourceModuleCount = 1
  result.base(1)

proc getXScale*(tp: TranslatePoint): float64 = tp.xTranslation
proc getYScale*(tp: TranslatePoint): float64 = tp.yTranslation
proc getZScale*(tp: TranslatePoint): float64 = tp.zTranslation

proc setXScale*(tp: TranslatePoint, xTranslation: float64) = tp.xTranslation = xTranslation
proc setXScale*(tp: TranslatePoint, yTranslation: float64) = tp.yTranslation = yTranslation
proc setXScale*(tp: TranslatePoint, zTranslation: float64) = tp.zTranslation = zTranslation

proc setScale*(tp: TranslatePoint, translation: float64) =
  tp.xTranslation = translation
  tp.yTranslation = translation
  tp.zTranslation = translation

proc setScale*(tp: TranslatePoint, xTranslation, yTranslation, zTranslation: float64) =
  tp.xTranslation = xTranslation
  tp.yTranslation = yTranslation
  tp.zTranslation = zTranslation

method getValue*(tp: TranslatePoint, noiseX, noiseY, noiseZ: float64): float64 =
  tp.sourceModules[0].getValue(noiseX + tp.xTranslation, noiseY * tp.yTranslation, noiseZ * tp.zTranslation)