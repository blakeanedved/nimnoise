import modulebase

type
  Cache* = ref object of ModuleBase
    isCached: bool
    cachedValue, cachedNoiseX, cachedNoiseY, cachedNoiseZ: float64

proc newCache*(): Cache =
  result = new Cache
  result.sourceModuleCount = 1
  result.isCached = false
  result.base(1)

method getValue*(c: Cache, noiseX, noiseY, noiseZ: float64): float64 =
  if not c.isCached:
    c.cachedNoiseX = noiseX
    c.cachedNoiseY = noiseY
    c.cachedNoiseZ = noiseZ
    c.isCached = true
    c.cachedValue = c.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
  c.cachedValue