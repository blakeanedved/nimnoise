import modulebase
from utils import makeInt32Range, gradientCoherentNoise3D

const
  BILLOW_DEFAULT_FREQUENCY = 1.0
  BILLOW_DEFAULT_LACUNARITY = 2.0
  BILLOW_DEFAULT_PERSISTENCE = 0.5
  BILLOW_DEFAULT_OCTAVES = 6
  BILLOW_MAX_OCTAVE = 30
  BILLOW_DEFAULT_SEED = 0
  BILLOW_DEFAULT_QUALITY = High

type
  Billow* = ref object of ModuleBase
    lacunarity: float64
    frequency: float64
    persistence: float64
    octaveCount: int
    seed: int
    quality: NoiseQuality

proc newBillow*(): Billow =
  result = new Billow
  result.frequency = BILLOW_DEFAULT_FREQUENCY
  result.lacunarity = BILLOW_DEFAULT_LACUNARITY
  result.persistence = BILLOW_DEFAULT_PERSISTENCE
  result.octaveCount = BILLOW_DEFAULT_OCTAVES
  result.seed = BILLOW_DEFAULT_SEED
  result.quality = BILLOW_DEFAULT_QUALITY
  result.base(0)

proc getFrequency*(b: Billow): float = b.frequency
proc getLacunarity*(b: Billow): float = b.lacunarity
proc getPersistence*(b: Billow): float = b.persistence
proc getSeed*(b: Billow): int = b.seed
proc getOctaveCount*(b: Billow): int = b.octaveCount
proc getNoiseQuality*(b: Billow): NoiseQuality = b.quality

proc setFrequency*(b: Billow, frequency: float) = b.frequency = frequency
proc setLacunarity*(b: Billow, lacunarity: float) = b.lacunarity = lacunarity
proc setPersistence*(b: Billow, persistence: float) = b.persistence = persistence
proc setSeed*(b: Billow, seed: int) = b.seed = seed
proc setNoiseQuality*(b: Billow, quality: NoiseQuality) = b.quality = quality
proc setOctaveCount*(b: Billow, octaveCount: int) =
  assert octaveCount > 0 and octaveCount <= BILLOW_MAX_OCTAVE
  b.octaveCount = octaveCount

method getValue*(b: Billow, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = noiseX * b.frequency
    y = noiseY * b.frequency
    z = noiseZ * b.frequency
    amplitude: float64 = 1.0
    nx, ny, nz: float64
    seed: int
    signal: float64

  for i in 0..<b.octaveCount:
    nx = makeInt32Range(x)
    ny = makeInt32Range(y)
    nz = makeInt32Range(z)
    seed = (b.seed + i) and 0xffffffff.int
    signal = gradientCoherentNoise3D(nx, ny, nz, seed, b.quality)
    signal = 2.0 * abs(signal) - 1.0;
    result += signal * amplitude
    x *= b.lacunarity
    y *= b.lacunarity
    z *= b.lacunarity
    amplitude = amplitude * b.persistence

  result += 0.5
