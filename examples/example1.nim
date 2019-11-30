import ../src/nimnoise
import imageman

var img = initImage[ColorRGBAU](500, 500)
var color: ColorRGBAU
var
  p = newPerlin()
  c = newClamp()

c.setSourceModule(0, p)

color.a = 255

var
  val: uint8

for y in 0..499:
  for x in 0..499:
    val = (((c.getValue(x.float64 / 100.0, y.float64 / 100.0, 0.00001) +
        1.0) / 2.0) * 255.0).uint8
    color.r = val
    color.g = val
    color.b = val
    img.data[y * img.width + x] = color

img.savePNG("image.png")
