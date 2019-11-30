type
  ModuleBase* = ref object of RootObj
    sourceModuleCount*: uint
    sourceModules*: seq[ModuleBase]

  NoiseQuality* = enum
    Low, Medium, High

proc setSourceModule*(mb: ModuleBase, index: uint, sm: ModuleBase) =
  assert index >= 0.uint and index < mb.sourceModuleCount
  mb.sourceModules[index] = sm

proc getSourceModule*(mb: ModuleBase, index: uint): ModuleBase =
  assert index >= 0.uint and index < mb.sourceModuleCount
  mb.sourceModules[index]

method getValue*(mb: ModuleBase, noiseX, noiseY, noiseZ: float64): float64 {.base.} = 0.0

proc base*(mb: ModuleBase, sourceModuleCount: uint) =
  mb.sourceModuleCount = sourceModuleCount
  mb.sourceModules = newSeq[ModuleBase](sourceModuleCount)
