import modulebase
import perlin

const
  X0 = (12414.0 / 65536.0).float64
  Y0 = (65124.0 / 65536.0).float64
  Z0 = (31337.0 / 65536.0).float64
  X1 = (26519.0 / 65536.0).float64
  Y1 = (18128.0 / 65536.0).float64
  Z1 = (60493.0 / 65536.0).float64
  X2 = (53820.0 / 65536.0).float64
  Y2 = (11213.0 / 65536.0).float64
  Z2 = (44845.0 / 65536.0).float64

type
  Turbulence* = ref object of ModuleBase
    power: float64
    xDistortModule, yDistortModule, zDistortModule: Perlin

proc newTurbulence*(): Turbulence =
  result = new Turbulence
  result.xDistortModule = newPerlin()
  result.yDistortModule = newPerlin()
  result.zDistortModule = newPerlin()
  result.sourceModuleCount = 1
  result.base(1)

proc getFrequency*(t: Turbulence): float64 = t.xDistortModule.getFrequency()
proc getPower*(t: Turbulence): float64 = t.power
proc getRoughnessCount*(t: Turbulence): int = t.xDistortModule.getOctaveCount()
proc getRoughness*(t: Turbulence): int = t.xDistortModule.getOctaveCount()
proc getSeed*(t: Turbulence): int = t.xDistortModule.getSeed()

proc setFrequency*(t: Turbulence, frequency: float64) =
  t.xDistortModule.setFrequency(frequency)
  t.yDistortModule.setFrequency(frequency)
  t.zDistortModule.setFrequency(frequency)
proc setPower*(t: Turbulence, power: float64) = t.power = power
proc setRoughnessCount*(t: Turbulence, roughness: int) =
  t.xDistortModule.setOctaveCount(roughness)
  t.yDistortModule.setOctaveCount(roughness)
  t.zDistortModule.setOctaveCount(roughness)
proc setRoughness*(t: Turbulence, roughness: int) =
  t.xDistortModule.setOctaveCount(roughness)
  t.yDistortModule.setOctaveCount(roughness)
  t.zDistortModule.setOctaveCount(roughness)
proc setSeed*(t: Turbulence, seed: int) =
  t.xDistortModule.setSeed(seed    )
  t.yDistortModule.setSeed(seed + 1)
  t.zDistortModule.setSeed(seed + 2)

method getValue*(t: Turbulence, noiseX, noiseY, noiseZ: float64): float64 =
  let
    xd = noiseX + (t.xDistortModule.getValue(noiseX + X0, noiseY + Y0, noiseZ + Z0) * t.power)
    yd = noiseY + (t.yDistortModule.getValue(noiseX + X1, noiseY + Y1, noiseZ + Z1) * t.power)
    zd = noiseZ + (t.zDistortModule.getValue(noiseX + X2, noiseY + Y2, noiseZ + Z2) * t.power)
  t.sourceModules[0].getValue(xd, yd, zd)