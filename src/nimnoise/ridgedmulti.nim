import modulebase
from math import pow
from utils import makeInt32Range, gradientCoherentNoise3D

const
  DEFAULT_RIDGED_FREQUENCY = 1.0.float64
  DEFAULT_RIDGED_LACUNARITY = 2.0.float64
  DEFAULT_RIDGED_OCTAVE_COUNT = 6.int
  DEFAULT_RIDGED_QUALITY = High
  DEFAULT_RIDGED_SEED = 0.int
  DEFAULT_RIDGED_EXPONENT = 1.0.float64
  DEFAULT_RIDGED_GAIN = 2.0.float64
  DEFAULT_RIDGED_OFFSET = 1.0.float64
  RIDGED_MAX_OCTAVE = 30.int

type
  RidgedMulti* = ref object of ModuleBase
    frequency: float64
    lacunarity: float64
    quality: NoiseQuality
    octaveCount: int
    exponent: float64
    gain: float64
    offset: float64
    seed: int
    weights: array[RIDGED_MAX_OCTAVE, float64]

proc updateWeights(rm: RidgedMulti) =
  var f = 1.0.float64
  for i in 0..<RIDGED_MAX_OCTAVE:
    rm.weights[i] = pow(f, -rm.exponent)
    f *= rm.lacunarity

proc newRidgedMulti*(): RidgedMulti =
  result = new RidgedMulti
  result.frequency = DEFAULT_RIDGED_FREQUENCY
  result.lacunarity = DEFAULT_RIDGED_LACUNARITY
  result.quality = DEFAULT_RIDGED_QUALITY
  result.octaveCount = DEFAULT_RIDGED_OCTAVE_COUNT
  result.seed = DEFAULT_RIDGED_SEED
  result.exponent = DEFAULT_RIDGED_EXPONENT
  result.gain = DEFAULT_RIDGED_GAIN
  result.offset = DEFAULT_RIDGED_OFFSET
  result.base(0)
  result.updateWeights()

proc getFrequency*(rm: RidgedMulti): float = rm.frequency
proc getLacunarity*(rm: RidgedMulti): float = rm.lacunarity
proc getSeed*(rm: RidgedMulti): int = rm.seed
proc getOctaveCount*(rm: RidgedMulti): int = rm.octaveCount
proc getNoiseQuality*(rm: RidgedMulti): NoiseQuality = rm.quality
proc getExponent*(rm: RidgedMulti): float64 = rm.exponent
proc getGain*(rm: RidgedMulti): float64 = rm.gain
proc getOffset*(rm: RidgedMulti): float64 = rm.offset

proc setFrequency*(rm: RidgedMulti, frequency: float64) = rm.frequency = frequency
proc setSeed*(rm: RidgedMulti, seed: int) = rm.seed = seed
proc setNoiseQuality*(rm: RidgedMulti, quality: NoiseQuality) = rm.quality = quality
proc setExponent*(rm: RidgedMulti, exponent: float64) = rm.exponent = exponent
proc setGain*(rm: RidgedMulti, gain: float64) = rm.gain = gain
proc setOffset*(rm: RidgedMulti, offset: float64) = rm.offset = offset
proc setLacunarity*(rm: RidgedMulti, lacunarity: float64) =
  rm.lacunarity = lacunarity
  rm.updateWeights()
proc setOctaveCount*(rm: RidgedMulti, octaveCount: int) =
  assert octaveCount > 0 and octaveCount <= RIDGED_MAX_OCTAVE
  rm.octaveCount = octaveCount


method getValue*(rm: RidgedMulti, noiseX, noiseY, noiseZ: float64): float64 =
  result = 0.0
  var
    weight = 1.0
    x = noiseX * rm.frequency
    y = noiseY * rm.frequency
    z = noiseZ * rm.frequency
    nx, ny, nz: float64
    seed: int
    signal: float64

  for i in 0..<rm.octaveCount:
    nx = makeInt32Range(x)
    ny = makeInt32Range(y)
    nz = makeInt32Range(z)
    seed = (rm.seed + i) and 0x7fffffff
    signal = gradientCoherentNoise3D(nx, ny, nz, seed, rm.quality)
    signal = rm.offset - abs(signal)
    signal *= signal
    signal *= weight
    weight = signal * rm.gain
    weight = clamp(weight, 0.0, 1.0)
    result += signal * rm.weights[i]
    x *= rm.lacunarity
    y *= rm.lacunarity
    z *= rm.lacunarity
  result = (result * 1.25) - 1.0
