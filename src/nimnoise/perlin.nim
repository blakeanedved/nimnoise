import modulebase
from utils import makeInt32Range, gradientCoherentNoise3D

const
  PERLIN_DEFAULT_FREQUENCY = 1.0
  PERLIN_DEFAULT_LACUNARITY = 2.0
  PERLIN_DEFAULT_PERSISTENCE = 0.5
  PERLIN_DEFAULT_OCTAVES = 6
  PERLIN_MAX_OCTAVE = 30
  PERLIN_DEFAULT_SEED = 0
  PERLIN_DEFAULT_QUALITY = High

type
  Perlin* = ref object of ModuleBase
    lacunarity: float64
    frequency: float64
    persistence: float64
    octaveCount: int
    seed: int
    quality: NoiseQuality

proc newPerlin*(): Perlin =
  result = new Perlin
  result.frequency = PERLIN_DEFAULT_FREQUENCY
  result.lacunarity = PERLIN_DEFAULT_LACUNARITY
  result.persistence = PERLIN_DEFAULT_PERSISTENCE
  result.octaveCount = PERLIN_DEFAULT_OCTAVES
  result.seed = PERLIN_DEFAULT_SEED
  result.quality = PERLIN_DEFAULT_QUALITY
  result.base(0)

proc getFrequency*(p: Perlin): float = p.frequency
proc getLacunarity*(p: Perlin): float = p.lacunarity
proc getPersistence*(p: Perlin): float = p.persistence
proc getSeed*(p: Perlin): int = p.seed
proc getOctaveCount*(p: Perlin): int = p.octaveCount
proc getNoiseQuality*(p: Perlin): NoiseQuality = p.quality

proc setFrequency*(p: Perlin, frequency: float) = p.frequency = frequency
proc setLacunarity*(p: Perlin, lacunarity: float) = p.lacunarity = lacunarity
proc setPersistence*(p: Perlin, persistence: float) = p.persistence = persistence
proc setSeed*(p: Perlin, seed: int) = p.seed = seed
proc setNoiseQuality*(p: Perlin, quality: NoiseQuality) = p.quality = quality
proc setOctaveCount*(p: Perlin, octaveCount: int) =
  assert octaveCount > 0 and octaveCount <= PERLIN_MAX_OCTAVE
  p.octaveCount = octaveCount

method getValue*(p: Perlin, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = noiseX * p.frequency
    y = noiseY * p.frequency
    z = noiseZ * p.frequency
    amplitude: float64 = 1.0
    nx, ny, nz: float64
    seed: int
    signal: float64

  for i in 0..<p.octaveCount:
    nx = makeInt32Range(x)
    ny = makeInt32Range(y)
    nz = makeInt32Range(z)
    seed = (p.seed + i) and 0xffffffff.int
    signal = gradientCoherentNoise3D(nx, ny, nz, seed, p.quality)
    result += signal * amplitude
    x *= p.lacunarity
    y *= p.lacunarity
    z *= p.lacunarity
    amplitude *= p.persistence
