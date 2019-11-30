import modulebase

type
  Displace* = ref object of ModuleBase

proc newDisplace*(): Displace =
  result = new Displace
  result.sourceModuleCount = 4
  result.base(4)

proc getXDisplaceModule*(d: Displace): ModuleBase = d.sourceModules[1]
proc getYDisplaceModule*(d: Displace): ModuleBase = d.sourceModules[2]
proc getZDisplaceModule*(d: Displace): ModuleBase = d.sourceModules[3]

proc setXDisplaceModule*(d: Displace, mb: ModuleBase) = d.sourceModules[1] = mb
proc setYDisplaceModule*(d: Displace, mb: ModuleBase) = d.sourceModules[2] = mb
proc setZDisplaceModule*(d: Displace, mb: ModuleBase) = d.sourceModules[3] = mb

proc setDisplaceModules*(d: Displace, mbx, mby, mbz: ModuleBase) =
  d.sourceModules[1] = mbx
  d.sourceModules[2] = mby
  d.sourceModules[3] = mbz

method getValue*(d: Displace, noiseX, noiseY, noiseZ: float64): float64 =
  let
    x = noiseX + d.sourceModules[1].getValue(noiseX, noiseY, noiseZ)
    y = noiseY + d.sourceModules[2].getValue(noiseX, noiseY, noiseZ)
    z = noiseZ + d.sourceModules[3].getValue(noiseX, noiseY, noiseZ)
  d.sourceModules[0].getValue(x, y, z)