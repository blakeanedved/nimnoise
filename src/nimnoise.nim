from math import round, sqrt, floor, pow, cos, sin, degToRad

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


from bitops import bitxor, bitand

const
  # If Noise Version 1 (TODO)
  # GeneratorNoiseX: int = 1
  # GeneratorNoiseY: int = 31337
  # GeneratorNoiseZ: int = 263
  # GeneratorSeed: int = 1013
  # GeneratorShift: int = 13
  GENERATOR_NOISE_X: int = 1619
  GENERATOR_NOISE_Y: int = 31337
  GENERATOR_NOISE_Z: int = 6971
  GENERATOR_SEED: int = 1013
  GENERATOR_SHIFT: int = 8

  SQRT3* = 1.7320508075688772935.float64

  RANDOMS: array[1024, float64] = [
    -0.763874, -0.596439, -0.246489, 0.0, 0.396055, 0.904518, -0.158073, 0.0,
    -0.499004, -0.8665, -0.0131631, 0.0, 0.468724, -0.824756, 0.316346, 0.0,
    0.829598, 0.43195, 0.353816, 0.0, -0.454473, 0.629497, -0.630228, 0.0,
    -0.162349, -0.869962, -0.465628, 0.0, 0.932805, 0.253451, 0.256198, 0.0,
    -0.345419, 0.927299, -0.144227, 0.0, -0.715026, -0.293698, -0.634413, 0.0,
    -0.245997, 0.717467, -0.651711, 0.0, -0.967409, -0.250435, -0.037451, 0.0,
    0.901729, 0.397108, -0.170852, 0.0, 0.892657, -0.0720622, -0.444938, 0.0,
    0.0260084, -0.0361701, 0.999007, 0.0, 0.949107, -0.19486, 0.247439, 0.0,
    0.471803, -0.807064, -0.355036, 0.0, 0.879737, 0.141845, 0.453809, 0.0,
    0.570747, 0.696415, 0.435033, 0.0, -0.141751, -0.988233, -0.0574584, 0.0,
    -0.58219, -0.0303005, 0.812488, 0.0, -0.60922, 0.239482, -0.755975, 0.0,
    0.299394, -0.197066, -0.933557, 0.0, -0.851615, -0.220702, -0.47544, 0.0,
    0.848886, 0.341829, -0.403169, 0.0, -0.156129, -0.687241, 0.709453, 0.0,
    -0.665651, 0.626724, 0.405124, 0.0, 0.595914, -0.674582, 0.43569, 0.0,
    0.171025, -0.509292, 0.843428, 0.0, 0.78605, 0.536414, -0.307222, 0.0,
    0.18905, -0.791613, 0.581042, 0.0, -0.294916, 0.844994, 0.446105, 0.0,
    0.342031, -0.58736, -0.7335, 0.0, 0.57155, 0.7869, 0.232635, 0.0,
    0.885026, -0.408223, 0.223791, 0.0, -0.789518, 0.571645, 0.223347, 0.0,
    0.774571, 0.31566, 0.548087, 0.0, -0.79695, -0.0433603, -0.602487, 0.0,
    -0.142425, -0.473249, -0.869339, 0.0, -0.0698838, 0.170442, 0.982886, 0.0,
    0.687815, -0.484748, 0.540306, 0.0, 0.543703, -0.534446, -0.647112, 0.0,
    0.97186, 0.184391, -0.146588, 0.0, 0.707084, 0.485713, -0.513921, 0.0,
    0.942302, 0.331945, 0.043348, 0.0, 0.499084, 0.599922, 0.625307, 0.0,
    -0.289203, 0.211107, 0.9337, 0.0, 0.412433, -0.71667, -0.56239, 0.0,
    0.87721, -0.082816, 0.47291, 0.0, -0.420685, -0.214278, 0.881538, 0.0,
    0.752558, -0.0391579, 0.657361, 0.0, 0.0765725, -0.996789, 0.0234082, 0.0,
    -0.544312, -0.309435, -0.779727, 0.0, -0.455358, -0.415572, 0.787368, 0.0,
    -0.874586, 0.483746, 0.0330131, 0.0, 0.245172, -0.0838623, 0.965846, 0.0,
    0.382293, -0.432813, 0.81641, 0.0, -0.287735, -0.905514, 0.311853, 0.0,
    -0.667704, 0.704955, -0.239186, 0.0, 0.717885, -0.464002, -0.518983, 0.0,
    0.976342, -0.214895, 0.0240053, 0.0, -0.0733096, -0.921136, 0.382276, 0.0,
    -0.986284, 0.151224, -0.0661379, 0.0, -0.899319, -0.429671, 0.0812908, 0.0,
    0.652102, -0.724625, 0.222893, 0.0, 0.203761, 0.458023, -0.865272, 0.0,
    -0.030396, 0.698724, -0.714745, 0.0, -0.460232, 0.839138, 0.289887, 0.0,
    -0.0898602, 0.837894, 0.538386, 0.0, -0.731595, 0.0793784, 0.677102, 0.0,
    -0.447236, -0.788397, 0.422386, 0.0, 0.186481, 0.645855, -0.740335, 0.0,
    -0.259006, 0.935463, 0.240467, 0.0, 0.445839, 0.819655, -0.359712, 0.0,
    0.349962, 0.755022, -0.554499, 0.0, -0.997078, -0.0359577, 0.0673977, 0.0,
    -0.431163, -0.147516, -0.890133, 0.0, 0.299648, -0.63914, 0.708316, 0.0,
    0.397043, 0.566526, -0.722084, 0.0, -0.502489, 0.438308, -0.745246, 0.0,
    0.0687235, 0.354097, 0.93268, 0.0, -0.0476651, -0.462597, 0.885286, 0.0,
    -0.221934, 0.900739, -0.373383, 0.0, -0.956107, -0.225676, 0.186893, 0.0,
    -0.187627, 0.391487, -0.900852, 0.0, -0.224209, -0.315405, 0.92209, 0.0,
    -0.730807, -0.537068, 0.421283, 0.0, -0.0353135, -0.816748, 0.575913, 0.0,
    -0.941391, 0.176991, -0.287153, 0.0, -0.154174, 0.390458, 0.90762, 0.0,
    -0.283847, 0.533842, 0.796519, 0.0, -0.482737, -0.850448, 0.209052, 0.0,
    -0.649175, 0.477748, 0.591886, 0.0, 0.885373, -0.405387, -0.227543, 0.0,
    -0.147261, 0.181623, -0.972279, 0.0, 0.0959236, -0.115847, -0.988624, 0.0,
    -0.89724, -0.191348, 0.397928, 0.0, 0.903553, -0.428461, -0.00350461, 0.0,
    0.849072, -0.295807, -0.437693, 0.0, 0.65551, 0.741754, -0.141804, 0.0,
    0.61598, -0.178669, 0.767232, 0.0, 0.0112967, 0.932256, -0.361623, 0.0,
    -0.793031, 0.258012, 0.551845, 0.0, 0.421933, 0.454311, 0.784585, 0.0,
    -0.319993, 0.0401618, -0.946568, 0.0, -0.81571, 0.551307, -0.175151, 0.0,
    -0.377644, 0.00322313, 0.925945, 0.0, 0.129759, -0.666581, -0.734052, 0.0,
    0.601901, -0.654237, -0.457919, 0.0, -0.927463, -0.0343576, -0.372334, 0.0,
    -0.438663, -0.868301, -0.231578, 0.0, -0.648845, -0.749138, -0.133387, 0.0,
    0.507393, -0.588294, 0.629653, 0.0, 0.726958, 0.623665, 0.287358, 0.0,
    0.411159, 0.367614, -0.834151, 0.0, 0.806333, 0.585117, -0.0864016, 0.0,
    0.263935, -0.880876, 0.392932, 0.0, 0.421546, -0.201336, 0.884174, 0.0,
    -0.683198, -0.569557, -0.456996, 0.0, -0.117116, -0.0406654, -0.992285, 0.0,
    -0.643679, -0.109196, -0.757465, 0.0, -0.561559, -0.62989, 0.536554, 0.0,
    0.0628422, 0.104677, -0.992519, 0.0, 0.480759, -0.2867, -0.828658, 0.0,
    -0.228559, -0.228965, -0.946222, 0.0, -0.10194, -0.65706, -0.746914, 0.0,
    0.0689193, -0.678236, 0.731605, 0.0, 0.401019, -0.754026, 0.52022, 0.0,
    -0.742141, 0.547083, -0.387203, 0.0, -0.00210603, -0.796417, -0.604745, 0.0,
    0.296725, -0.409909, -0.862513, 0.0, -0.260932, -0.798201, 0.542945, 0.0,
    -0.641628, 0.742379, 0.192838, 0.0, -0.186009, -0.101514, 0.97729, 0.0,
    0.106711, -0.962067, 0.251079, 0.0, -0.743499, 0.30988, -0.592607, 0.0,
    -0.795853, -0.605066, -0.0226607, 0.0, -0.828661, -0.419471, -0.370628, 0.0,
    0.0847218, -0.489815, -0.8677, 0.0, -0.381405, 0.788019, -0.483276, 0.0,
    0.282042, -0.953394, 0.107205, 0.0, 0.530774, 0.847413, 0.0130696, 0.0,
    0.0515397, 0.922524, 0.382484, 0.0, -0.631467, -0.709046, 0.313852, 0.0,
    0.688248, 0.517273, 0.508668, 0.0, 0.646689, -0.333782, -0.685845, 0.0,
    -0.932528, -0.247532, -0.262906, 0.0, 0.630609, 0.68757, -0.359973, 0.0,
    0.577805, -0.394189, 0.714673, 0.0, -0.887833, -0.437301, -0.14325, 0.0,
    0.690982, 0.174003, 0.701617, 0.0, -0.866701, 0.0118182, 0.498689, 0.0,
    -0.482876, 0.727143, 0.487949, 0.0, -0.577567, 0.682593, -0.447752, 0.0,
    0.373768, 0.0982991, 0.922299, 0.0, 0.170744, 0.964243, -0.202687, 0.0,
    0.993654, -0.035791, -0.106632, 0.0, 0.587065, 0.4143, -0.695493, 0.0,
    -0.396509, 0.26509, -0.878924, 0.0, -0.0866853, 0.83553, -0.542563, 0.0,
    0.923193, 0.133398, -0.360443, 0.0, 0.00379108, -0.258618, 0.965972, 0.0,
    0.239144, 0.245154, -0.939526, 0.0, 0.758731, -0.555871, 0.33961, 0.0,
    0.295355, 0.309513, 0.903862, 0.0, 0.0531222, -0.91003, -0.411124, 0.0,
    0.270452, 0.0229439, -0.96246, 0.0, 0.563634, 0.0324352, 0.825387, 0.0,
    0.156326, 0.147392, 0.976646, 0.0, -0.0410141, 0.981824, 0.185309, 0.0,
    -0.385562, -0.576343, -0.720535, 0.0, 0.388281, 0.904441, 0.176702, 0.0,
    0.945561, -0.192859, -0.262146, 0.0, 0.844504, 0.520193, 0.127325, 0.0,
    0.0330893, 0.999121, -0.0257505, 0.0, -0.592616, -0.482475, -0.644999, 0.0,
    0.539471, 0.631024, -0.557476, 0.0, 0.655851, -0.027319, -0.754396, 0.0,
    0.274465, 0.887659, 0.369772, 0.0, -0.123419, 0.975177, -0.183842, 0.0,
    -0.223429, 0.708045, 0.66989, 0.0, -0.908654, 0.196302, 0.368528, 0.0,
    -0.95759, -0.00863708, 0.288005, 0.0, 0.960535, 0.030592, 0.276472, 0.0,
    -0.413146, 0.907537, 0.0754161, 0.0, -0.847992, 0.350849, -0.397259, 0.0,
    0.614736, 0.395841, 0.68221, 0.0, -0.503504, -0.666128, -0.550234, 0.0,
    -0.268833, -0.738524, -0.618314, 0.0, 0.792737, -0.60001, -0.107502, 0.0,
    -0.637582, 0.508144, -0.579032, 0.0, 0.750105, 0.282165, -0.598101, 0.0,
    -0.351199, -0.392294, -0.850155, 0.0, 0.250126, -0.960993, -0.118025, 0.0,
    -0.732341, 0.680909, -0.0063274, 0.0, -0.760674, -0.141009, 0.633634, 0.0,
    0.222823, -0.304012, 0.926243, 0.0, 0.209178, 0.505671, 0.836984, 0.0,
    0.757914, -0.56629, -0.323857, 0.0, -0.782926, -0.339196, 0.52151, 0.0,
    -0.462952, 0.585565, 0.665424, 0.0, 0.61879, 0.194119, -0.761194, 0.0,
    0.741388, -0.276743, 0.611357, 0.0, 0.707571, 0.702621, 0.0752872, 0.0,
    0.156562, 0.819977, 0.550569, 0.0, -0.793606, 0.440216, 0.42, 0.0,
    0.234547, 0.885309, -0.401517, 0.0, 0.132598, 0.80115, -0.58359, 0.0,
    -0.377899, -0.639179, 0.669808, 0.0, -0.865993, -0.396465, 0.304748, 0.0,
    -0.624815, -0.44283, 0.643046, 0.0, -0.485705, 0.825614, -0.287146, 0.0,
    -0.971788, 0.175535, 0.157529, 0.0, -0.456027, 0.392629, 0.798675, 0.0,
    -0.0104443, 0.521623, -0.853112, 0.0, -0.660575, -0.74519, 0.091282, 0.0,
    -0.0157698, -0.307475, -0.951425, 0.0, -0.603467, -0.250192, 0.757121, 0.0,
    0.506876, 0.25006, 0.824952, 0.0, 0.255404, 0.966794, 0.00884498, 0.0,
    0.466764, -0.874228, -0.133625, 0.0, 0.475077, -0.0682351, -0.877295, 0.0,
    -0.224967, -0.938972, -0.260233, 0.0, -0.377929, -0.814757, -0.439705, 0.0,
    -0.305847, 0.542333, -0.782517, 0.0, 0.26658, -0.902905, -0.337191, 0.0,
    0.0275773, 0.322158, -0.946284, 0.0, 0.0185422, 0.716349, 0.697496, 0.0,
    -0.20483, 0.978416, 0.0273371, 0.0, -0.898276, 0.373969, 0.230752, 0.0,
    -0.00909378, 0.546594, 0.837349, 0.0, 0.6602, -0.751089, 0.000959236, 0.0,
    0.855301, -0.303056, 0.420259, 0.0, 0.797138, 0.0623013, -0.600574, 0.0,
    0.48947, -0.866813, 0.0951509, 0.0, 0.251142, 0.674531, 0.694216, 0.0,
    -0.578422, -0.737373, -0.348867, 0.0, -0.254689, -0.514807, 0.818601, 0.0,
    0.374972, 0.761612, 0.528529, 0.0, 0.640303, -0.734271, -0.225517, 0.0,
    -0.638076, 0.285527, 0.715075, 0.0, 0.772956, -0.15984, -0.613995, 0.0,
    0.798217, -0.590628, 0.118356, 0.0, -0.986276, -0.0578337, -0.154644, 0.0,
    -0.312988, -0.94549, 0.0899272, 0.0, -0.497338, 0.178325, 0.849032, 0.0,
    -0.101136, -0.981014, 0.165477, 0.0, -0.521688, 0.0553434, -0.851339, 0.0,
    -0.786182, -0.583814, 0.202678, 0.0, -0.565191, 0.821858, -0.0714658, 0.0,
    0.437895, 0.152598, -0.885981, 0.0, -0.92394, 0.353436, -0.14635, 0.0,
    0.212189, -0.815162, -0.538969, 0.0, -0.859262, 0.143405, -0.491024, 0.0,
    0.991353, 0.112814, 0.0670273, 0.0, 0.0337884, -0.979891, -0.196654, 0.0
  ]

type
  ControlPoint* = ref object of RootObj
    inputValue*, outputValue*: float64

proc ieee_remainder(x, y: float64): float64 =
  x - (y * round(x / y))

proc makeInt32Range*(value: float64): float64 =
  if value >= 1073741824.0:
    result = (2.0 * ieee_remainder(value, 1073741824.0)) - 1073741824.0
  elif value <= -1073741824.0:
    result = (2.0 * ieee_remainder(value, 1073741824.0)) + 1073741824.0
  result = value

proc mapCubicSCurve*(value: float64): float64 = value * value * (3.0 - 2.0 * value)
proc mapQuinticSCurve*(value: float64): float64 =
  let
    a3 = value * value * value
    a4 = a3 * value
    a5 = a4 * value
  (6.0 * a5) - (15.0 * a4) + (10.0 * a3)

proc fast_floor*(value: float64): int =
  if value > 0.0:
    value.int
  else:
    value.int - 1

proc gradientNoise3D*(fx, fy, fz: float64, ix, iy, iz, seed: int): float64 =
  var
    i = bitand((GENERATOR_NOISE_X * ix + GENERATOR_NOISE_Y * iy + GENERATOR_NOISE_Z *
        iz + GENERATOR_SEED * seed), 0xffffffff.int)

  i = bitxor(i shr GENERATOR_SHIFT, i)
  i = bitand(0xff, i)

  let
    xvg = RANDOMS[(i shl 2)]
    yvg = RANDOMS[(i shl 2) + 1]
    zvg = RANDOMS[(i shl 2) + 2]
    xvp = (fx - ix.float64)
    yvp = (fy - iy.float64)
    zvp = (fz - iz.float64)

  ((xvg * xvp) + (yvg * yvp) + (zvg * zvp)) * 2.12

proc interpolateLinear*(a, b, pos: float64): float64 =
  ((1.0 - pos) * a) + (pos * b)

proc interpolateCubic*(a, b, c, d, pos: float64): float64 =
  let
    p = (d - c) - (a - b)
    q = (a - b) - p
    r = c - a
    s = b
  p * pos * pos * pos + q * pos * pos + r * pos + s

proc gradientCoherentNoise3D*(x, y, z: float64, seed: int,
    quality: NoiseQuality): float64 =
  let
    x0: int = fast_floor(x)
    x1: int = x0 + 1
    y0: int = fast_floor(y)
    y1: int = y0 + 1
    z0: int = fast_floor(z)
    z1: int = z0 + 1

  var
    xs: float64 = 0
    ys: float64 = 0
    zs: float64 = 0

  case quality:
    of Low:
      xs = (x - x0.float64)
      ys = (y - y0.float64)
      zs = (z - z0.float64)
    of Medium:
      xs = mapCubicSCurve(x - x0.float64)
      ys = mapCubicSCurve(y - y0.float64)
      zs = mapCubicSCurve(z - z0.float64)
    of High:
      xs = mapQuinticSCurve(x - x0.float64)
      ys = mapQuinticSCurve(y - y0.float64)
      zs = mapQuinticSCurve(z - z0.float64)

  var
    n0 = gradientNoise3D(x, y, z, x0, y0, z0, seed)
    n1 = gradientNoise3D(x, y, z, x1, y0, z0, seed)
    ix0 = interpolateLinear(n0, n1, xs)
    ix1: float64
    iy0: float64
    iy1: float64

  n0 = gradientNoise3D(x, y, z, x0, y1, z0, seed)
  n1 = gradientNoise3D(x, y, z, x1, y1, z0, seed)
  ix1 = interpolateLinear(n0, n1, xs)
  iy0 = interpolateLinear(ix0, ix1, ys)
  n0 = gradientNoise3D(x, y, z, x0, y0, z1, seed)
  n1 = gradientNoise3D(x, y, z, x1, y0, z1, seed)
  ix0 = interpolateLinear(n0, n1, xs)
  n0 = gradientNoise3D(x, y, z, x0, y1, z1, seed)
  n1 = gradientNoise3D(x, y, z, x1, y1, z1, seed)
  ix1 = interpolateLinear(n0, n1, xs)
  iy1 = interpolateLinear(ix0, ix1, ys)
  interpolateLinear(iy0, iy1, zs)

# proc valueNoise3DInt(x, y, z, seed: int): int64 =
#   result = (GENERATOR_NOISE_X * x + GENERATOR_NOISE_Y * y + GENERATOR_NOISE_Z * z + GENERATOR_SEED * seed) and 0x7fffffff
#   result = (result shr 13) xor result
#   result = ((result * (result * result * 60493 + 19990303) + 1376312589) and 0x7fffffff)
{.compile: "valueNoise3DInt.c".}
proc valueNoise3DInt(x, y, z, seed: cint): clong {.importc.}

proc valueNoise3D*(x, y, z, seed: int): float64 {.inline, noSideEffect.} =
  1.0 - (valueNoise3DInt((GENERATOR_NOISE_X * x).cint, (GENERATOR_NOISE_Y * y).cint, (GENERATOR_NOISE_Z * z).cint, (GENERATOR_SEED * seed).cint).float64 / 1073741824.0)



type
  Multiply* = ref object of ModuleBase

proc newMultiply*(): Multiply =
  result = new Multiply
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(m: Multiply, noiseX, noiseY, noiseZ: float64): float64 =
  m.sourceModules[0].getValue(noiseX, noiseY, noiseZ) * m.sourceModules[0].getValue(noiseX, noiseY, noiseZ)

type
  Abs* = ref object of ModuleBase

proc newAbs*(): Abs =
  result = new Abs
  result.sourceModuleCount = 1
  result.base(1)

method getValue*(a: Abs, noiseX, noiseY, noiseZ: float64): float64 =
  abs(a.sourceModules[0].getValue(noiseX, noiseY, noiseZ))



const
  DEFAULT_CYLINDERS_FREQUENCY = 1.0.float64

type
  Cylinders* = ref object of ModuleBase
    frequency: float64

proc newCylinders*(): Cylinders =
  result = new Cylinders
  result.frequency = DEFAULT_CYLINDERS_FREQUENCY
  result.base(0)

proc getFrequency*(c: Cylinders): float64 = c.frequency

proc setFrequency*(c: Cylinders, frequency: float64) = c.frequency = frequency

method getValue*(c: Cylinders, noiseX, noiseY, noiseZ: float64): float64 =
  let
    x = noiseX * c.frequency
    z = noiseZ * c.frequency
    dfc = sqrt(x * x + z * z)
    dfss = dfc - floor(dfc)
    dfls = 1.0 - dfss
    nd = min(dfss, dfls)
  1.0 - (nd * 4.0)



const
  DEFAULT_SPHERES_FREQUENCY = 1.0.float64

type
  Spheres* = ref object of ModuleBase
    frequency: float64

proc newSpheres*(): Spheres =
  result = new Spheres
  result.frequency = DEFAULT_SPHERES_FREQUENCY
  result.base(0)

proc getSpheres*(s: Spheres): float64 = s.frequency

proc setSpheres*(s: Spheres, frequency: float64) = s.frequency = frequency

method getValue*(s: Spheres, noiseX, noiseY, noiseZ: float64): float64 =
  let
    x = noiseX * s.frequency
    y = noiseY * s.frequency
    z = noiseZ * s.frequency
    dfc = sqrt(x * x + y * y + z * z)
    dfss = dfc - floor(dfc)
    dfls = 1.0 - dfss
    nd = min(dfss, dfls)
  1.0 - (nd * 4.0)



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


type
  Power* = ref object of ModuleBase

proc newPower*(): Power =
  result = new Power
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(p: Power, noiseX, noiseY, noiseZ: float64): float64 =
  pow(p.sourceModules[0].getValue(noiseX, noiseY, noiseZ), p.sourceModules[0].getValue(noiseX, noiseY, noiseZ))


const
  DEFAULT_EXPONENT = 1.0.float64

type
  Exponent* = ref object of ModuleBase
    exponent: float64

proc newExponent*(): Exponent =
  result = new Exponent
  result.exponent = DEFAULT_EXPONENT
  result.sourceModuleCount = 1
  result.base(1)

proc getExponent*(e: Exponent): float64 = e.exponent

proc setExponent*(e: Exponent, ex: float64) = e.exponent = ex

method getValue*(e: Exponent, noiseX, noiseY, noiseZ: float64): float64 =
  let val = e.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
  pow(((val + 1.0) / 2.0), e.exponent) * 2.0 - 1.0

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



const
  DEFAULT_ROTATE_X = 0.0.float64
  DEFAULT_ROTATE_Y = 0.0.float64
  DEFAULT_ROTATE_Z = 0.0.float64

type
  RotatePoint* = ref object of ModuleBase
    x1Matrix, x2Matrix, x3Matrix: float64
    y1Matrix, y2Matrix, y3Matrix: float64
    z1Matrix, z2Matrix, z3Matrix: float64
    xAngle, yAngle, zAngle: float64

proc setAngles*(rp: RotatePoint, x, y, z: float64) =
  let
    xc = cos(degToRad(x))
    yc = cos(degToRad(y))
    zc = cos(degToRad(z))
    xs = sin(degToRad(x))
    ys = sin(degToRad(y))
    zs = sin(degToRad(z))
  rp.x1Matrix = ys * xs * zs + yc * zc
  rp.y1Matrix = xc * zs
  rp.z1Matrix = ys * zc - yc * xs * zs
  rp.x2Matrix = ys * xs * zc - yc * zs
  rp.y2Matrix = xc * zc
  rp.z2Matrix = -yc * xs * zc - ys * zs
  rp.x3Matrix = -ys * xc
  rp.y3Matrix = xs
  rp.z3Matrix = yc * xc
  rp.xAngle = x
  rp.yAngle = y
  rp.zAngle = z

proc newRotatePoint*(): RotatePoint =
  result = new RotatePoint
  result.setAngles(DEFAULT_ROTATE_X, DEFAULT_ROTATE_Y, DEFAULT_ROTATE_Z)
  result.sourceModuleCount = 1
  result.base(1)

proc getXAngle*(rp: RotatePoint): float64 = rp.xAngle
proc getYAngle*(rp: RotatePoint): float64 = rp.yAngle
proc getZAngle*(rp: RotatePoint): float64 = rp.zAngle

proc setXAngle*(rp: RotatePoint, angle: float64) = rp.setAngles(angle, rp.yAngle, rp.zAngle)
proc setYAngle*(rp: RotatePoint, angle: float64) = rp.setAngles(rp.xAngle, angle, rp.zAngle)
proc setZAngle*(rp: RotatePoint, angle: float64) = rp.setAngles(rp.xAngle, rp.yAngle, angle)

method getValue*(rp: RotatePoint, noiseX, noiseY, noiseZ: float64): float64 =
  let
    nx = (rp.x1Matrix * noiseX) + (rp.y1Matrix * noiseY) + (rp.z1Matrix * noiseZ)
    ny = (rp.x2Matrix * noiseX) + (rp.y2Matrix * noiseY) + (rp.z2Matrix * noiseZ)
    nz = (rp.x3Matrix * noiseX) + (rp.y3Matrix * noiseY) + (rp.z3Matrix * noiseZ)
  rp.sourceModules[0].getValue(nx, ny, nz)

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


type
  Add* = ref object of ModuleBase

proc newAdd*(): Add =
  result = new Add
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(a: Add, noiseX, noiseY, noiseZ: float64): float64 =
  a.sourceModules[0].getValue(noiseX, noiseY, noiseZ) + a.sourceModules[1].getValue(noiseX, noiseY, noiseZ)

type
  Min* = ref object of ModuleBase

proc newMin*(): Min =
  result = new Min
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(m: Min, noiseX, noiseY, noiseZ: float64): float64 =
  min(m.sourceModules[0].getValue(noiseX, noiseY, noiseZ), m.sourceModules[0].getValue(noiseX, noiseY, noiseZ))


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

const
  DEFAULT_BIAS = 0.0.float64
  DEFAULT_SCALE = 1.0.float64

type
  ScaleBias* = ref object of ModuleBase
    scale, bias: float64

proc newScaleBias*(): ScaleBias =
  result = new ScaleBias
  result.bias = DEFAULT_BIAS
  result.scale = DEFAULT_SCALE
  result.sourceModuleCount = 1
  result.base(1)

proc getBias*(sb: ScaleBias): float64 = sb.bias
proc getScale*(sb: ScaleBias): float64 = sb.scale

proc setBias*(sb: ScaleBias, bias: float64): float64 = sb.bias = bias
proc setScale*(sb: ScaleBias, scale: float64): float64 = sb.scale = scale

method getValue*(sb: ScaleBias, noiseX, noiseY, noiseZ: float64): float64 =
  sb.sourceModules[0].getValue(noiseX, noiseY, noiseZ) * sb.scale + sb.bias


const
  DEFAULT_SELECT_EDGE_FALLOFF = 0.0.float64
  DEFAULT_SELECT_LOWER_BOUND = -1.0.float64
  DEFAULT_SELECT_UPPER_BOUND = 1.0.float64

type
  Select* = ref object of ModuleBase
    edgeFalloff, lowerBound, upperBound: float64

proc newSelect*(): Select =
  result = new Select
  result.edgeFalloff = DEFAULT_SELECT_EDGE_FALLOFF
  result.lowerBound = DEFAULT_SELECT_LOWER_BOUND
  result.upperBound = DEFAULT_SELECT_UPPER_BOUND
  result.sourceModuleCount = 3
  result.base(3)

proc getControlModule*(s: Select): ModuleBase = s.sourceModules[2]
proc getEdgeFalloff*(s: Select): float64 = s.edgeFalloff
proc getLowerBound*(s: Select): float64 = s.lowerBound
proc getUpperBound*(s: Select): float64 = s.upperBound

proc setControlModule*(s: Select, mb: ModuleBase) = s.sourceModules[2] = mb
proc setEdgeFalloff*(s: Select, edgeFalloff: float64) = s.edgeFalloff = edgeFalloff
proc setLowerBound*(s: Select, lowerBound: float64) = s.lowerBound = lowerBound
proc setUpperBound*(s: Select, upperBound: float64) = s.upperBound = upperBound
proc setBounds*(s: Select, lowerBound, upperBound: float64) =
  s.lowerBound = lowerBound
  s.upperBound = upperBound

method getValue*(s: Select, noiseX, noiseY, noiseZ: float64): float64 =
  let cv = s.sourceModules[2].getValue(noiseX, noiseY, noiseZ)
  if s.edgeFalloff > 0.0:
    var a: float64
    if cv < (s.lowerBound - s.edgeFalloff):
      return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)

    if cv < (s.lowerBound + s.edgeFalloff):
      let
        lc = s.lowerBound - s.edgeFalloff
        uc = s.lowerBound + s.edgeFalloff
      a = mapCubicSCurve((cv - lc) / (uc - lc))
      return interpolateLinear(s.sourceModules[0].getValue(noiseX, noiseY, noiseZ), s.sourceModules[1].getValue(noiseX, noiseY, noiseZ), a)
    
    if cv < (s.upperBound - s.edgeFalloff):
      return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    
    if cv < (s.upperBound + s.edgeFalloff):
      let
        lc = s.upperBound - s.edgeFalloff
        uc = s.upperBound + s.edgeFalloff
      a = mapCubicSCurve((cv - lc) / (uc - lc))
      return interpolateLinear(s.sourceModules[1].getValue(noiseX, noiseY, noiseZ), s.sourceModules[0].getValue(noiseX, noiseY, noiseZ), a)
    
    return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)

  if cv < s.lowerBound or cv > s.upperBound:
    return s.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    
  return s.sourceModules[1].getValue(noiseX, noiseY, noiseZ)

    

type
  Invert* = ref object of ModuleBase

proc newInvert*(): Invert =
  result = new Invert
  result.sourceModuleCount = 1
  result.base(1)

method getValue*(i: Invert, noiseX, noiseY, noiseZ: float64): float64 =
  -i.sourceModules[0].getValue(noiseX, noiseY, noiseZ)


type
  Curve* = ref object of ModuleBase
    controlPoints: seq[ControlPoint]

proc newCurve*(): Curve =
  result = new Curve
  result.sourceModuleCount = 1
  result.base(1)

proc addControlPoint*(c: Curve, inputValue, outputValue: float64) =
  var index: int
  for i in c.controlPoints:
    assert inputValue != i.inputValue
    if inputValue < i.inputValue: break
    index += 1
  c.controlPoints.insert(ControlPoint(inputValue: inputValue, outputValue: outputValue), index)

proc clearAllControlPoints*(c: Curve) = c.controlPoints = @[]

proc getControlPointArray*(c: Curve): seq[ControlPoint] = c.controlPoints

proc getControlPointCount*(c: Curve): int = c.controlPoints.len

method getValue*(c: Curve, noiseX, noiseY, noiseZ: float64): float64 =
  assert c.controlPoints.len >= 4
  let cpa = c.controlPoints.len
  var
    smv = c.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    ip: int

  for cp in c.controlPoints:
    if smv < cp.inputValue: break
    ip += 1
  
  let
    i0 = clamp(ip - 2, 0, cpa - 1)
    i1 = clamp(ip - 1, 0, cpa - 1)
    i2 = clamp(ip    , 0, cpa - 1)
    i3 = clamp(ip + 1, 0, cpa - 1)
  if i1 == i2:
    result = c.controlPoints[i1].outputValue
  else:
    let
      ip0 = c.controlPoints[i1].inputValue
      ip1 = c.controlPoints[i2].inputValue
      a = (smv - ip0) / (ip1 - ip0)
    result = interpolateCubic(c.controlPoints[i0].outputValue, c.controlPoints[i1].outputValue, c.controlPoints[i2].outputValue, c.controlPoints[i3].outputValue, a)
  


type
  Blend* = ref object of ModuleBase

proc newBlend*(): Blend =
  result = new Blend
  result.sourceModuleCount = 3
  result.base(3)

proc getControlModule*(b: Blend): ModuleBase = b.sourceModules[2]

proc setControlModule*(b: Blend, mb: ModuleBase) = b.sourceModules[2] = mb

method getValue*(b: Blend, noiseX, noiseY, noiseZ: float64): float64 =
  let
    h = b.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    j = b.sourceModules[1].getValue(noiseX, noiseY, noiseZ)
    k = b.sourceModules[2].getValue(noiseX, noiseY, noiseZ)
  interpolateLinear(h, j, (k + 1.0) / 2.0)

type
  Max* = ref object of ModuleBase

proc newMax*(): Max =
  result = new Max
  result.sourceModuleCount = 2
  result.base(2)

method getValue*(m: Max, noiseX, noiseY, noiseZ: float64): float64 =
  max(m.sourceModules[0].getValue(noiseX, noiseY, noiseZ), m.sourceModules[0].getValue(noiseX, noiseY, noiseZ))


type
  Terrace* = ref object of ModuleBase
    controlPoints: seq[float64]
    invertTerraces: bool

proc newTerrace*(): Terrace =
  result = new Terrace
  result.invertTerraces = false
  result.sourceModuleCount = 1
  result.base(1)

proc addControlPoint*(t: Terrace, value: float64) =
  assert not t.controlPoints.contains(value)
  var index: int
  for i in t.controlPoints:
    if value < i: break
    index += 1
  t.controlPoints.insert(value, index)

proc clearAllControlPoints*(t: Terrace) = t.controlPoints = @[]

proc getControlPointArray*(t: Terrace): seq[float64] = t.controlPoints

proc getControlPointCount*(t: Terrace): int = t.controlPoints.len

proc makeControlPoints*(t: Terrace, controlPointCount: int) =
  assert controlPointCount >= 2
  t.clearAllControlPoints()
  let
    ts = 2.0 / (controlPointCount - 1).float64
  var cv = -1.0
  for i in 0..<controlPointCount:
    t.controlPoints.add(cv)
    cv += ts

proc invertTerraces*(t: Terrace, invert: bool = true) = t.invertTerraces = invert

proc isTerracesInverted*(t: Terrace): bool = t.invertTerraces

method getValue*(t: Terrace, noiseX, noiseY, noiseZ: float64): float64 =
  assert t.controlPoints.len >= 2
  var
    smv = t.sourceModules[0].getValue(noiseX, noiseY, noiseZ)
    ip: int
  
  for i in t.controlPoints:
    if smv < i: break
    ip += 1

  let
    i0 = clamp(ip - 1, 0, t.controlPoints.len - 1)
    i1 = clamp(ip, 0, t.controlPoints.len - 1)
  
  if i0 == i1:
    return t.controlPoints[i1]
  
  var
    v0 = t.controlPoints[i0]
    v1 = t.controlPoints[i1]
    a = (smv - v0) / (v1 - v0)
  
  if t.invertTerraces:
    a = 1.0 - a
    let t = v0
    v0 = v1
    v1 = t

  a *= a

  interpolateLinear(v0, v1, a)

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

const
  DEFAULT_SCALE_POINT_X = 0.0.float64
  DEFAULT_SCALE_POINT_Y = 0.0.float64
  DEFAULT_SCALE_POINT_Z = 0.0.float64

type
  ScalePoint* = ref object of ModuleBase
    xScale, yScale, zScale: float64

proc newScalePoint*(): ScalePoint =
  result = new ScalePoint
  result.xScale = DEFAULT_SCALE_POINT_X
  result.yScale = DEFAULT_SCALE_POINT_Y
  result.zScale = DEFAULT_SCALE_POINT_Z
  result.sourceModuleCount = 1
  result.base(1)

proc getXScale*(sp: ScalePoint): float64 = sp.xScale
proc getYScale*(sp: ScalePoint): float64 = sp.yScale
proc getZScale*(sp: ScalePoint): float64 = sp.zScale

proc setXScale*(sp: ScalePoint, xScale: float64) = sp.xScale = xScale
proc setXScale*(sp: ScalePoint, yScale: float64) = sp.yScale = yScale
proc setXScale*(sp: ScalePoint, zScale: float64) = sp.zScale = zScale

proc setScale*(sp: ScalePoint, scale: float64) =
  sp.xScale = scale
  sp.yScale = scale
  sp.zScale = scale

proc setScale*(sp: ScalePoint, xScale, yScale, zScale: float64) =
  sp.xScale = xScale
  sp.yScale = yScale
  sp.zScale = zScale

method getValue*(sp: ScalePoint, noiseX, noiseY, noiseZ: float64): float64 =
  sp.sourceModules[0].getValue(noiseX * sp.xScale, noiseY * sp.yScale, noiseZ * sp.zScale)



const
  DEFAULT_VORONOI_DISPLACEMENT = 1.0.float64
  DEFAULT_VORONOI_FREQUENCY = 1.0.float64
  DEFAULT_VORONOI_SEED = 0.int

type
  Voronoi* = ref object of ModuleBase
    displacement: float64
    frequency: float64
    seed: int
    distance: bool

proc newVoronoi*(): Voronoi =
  result = new Voronoi
  result.displacement = DEFAULT_VORONOI_DISPLACEMENT
  result.frequency = DEFAULT_VORONOI_FREQUENCY
  result.seed = DEFAULT_VORONOI_SEED
  result.distance = false
  result.base(0)

proc getDisplacement*(v: Voronoi): float64 = v.displacement
proc getFrequency*(v: Voronoi): float64 = v.frequency
proc getSeed*(v: Voronoi): int = v.seed
proc isDistanceEnabled*(v: Voronoi): bool = v.distance

proc setDisplacement*(v: Voronoi, displacement: float64) = v.displacement = displacement
proc setFrequency*(v: Voronoi, frequency: float64) = v.frequency = frequency
proc setSeed*(v: Voronoi, seed: int) = v.seed = seed
proc enableDistance*(v: Voronoi, distance: bool = true) = v.distance = distance
proc disableDistance*(v: Voronoi) = v.distance = false

method getValue*(v: Voronoi, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = noiseX * v.frequency
    y = noiseY * v.frequency
    z = noiseZ * v.frequency
    xi = fast_floor(x)
    yi = fast_floor(y)
    zi = fast_floor(z)
    md = 2147483647.0.float64
    xc = 0.float64
    yc = 0.float64
    zc = 0.float64
    xp, yp, zp, xd, yd, zd, d: float64

  for zcu in zi-2..zi+2:
    for ycu in yi-2..yi+2:
      for xcu in xi-2..xi+2:
        xp = xcu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed)
        yp = ycu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed + 1)
        zp = zcu.float64 + valueNoise3D(xcu, ycu, zcu, v.seed + 2)
        xd = xp - x
        yd = yp - y
        zd = zp - z
        d = xd * xd + yd * yd + zd * zd
        if d < md:
          md = d
          xc = xp
          yc = yp
          zc = zp

  var val: float64
  if v.distance:
    xd = xc - x
    yd = yc - y
    zd = zc - z
    val = sqrt(xd * xd + yd * yd + zd * zd) * SQRT3 - 1.0
  else:
    val = 0.0

  val + (v.displacement * valueNoise3D(fast_floor(xc), fast_floor(yc), fast_floor(zc), 0))



type
  Checkerboard* = ref object of ModuleBase

proc newCheckerboard*(): Checkerboard =
  result = new Checkerboard
  result.base(0)

method getValue*(cb: Checkerboard, noiseX, noiseY, noiseZ: float64): float64 =
  var
    x = fast_floor(makeInt32Range(noiseX))
    y = fast_floor(makeInt32Range(noiseY))
    z = fast_floor(makeInt32Range(noiseZ))
  result = if ((x and 1) xor (y and 1) xor (z and 1)) != 0:
      -1.0
    else:
      1.0

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