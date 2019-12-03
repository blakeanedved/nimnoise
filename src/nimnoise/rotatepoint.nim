import modulebase
from math import cos, sin, degToRad

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