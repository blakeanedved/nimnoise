import unittest
import ../src/nimnoise

test "Source module count":
  var perlin = newPerlin()
  assert perlin.sourceModuleCount == 0

test "Perlin octave count":
  var perlin = newPerlin()
  assert perlin.getOctaveCount() == 6

test "Perlin persistence":
  var perlin = newPerlin()
  assert perlin.getPersistence() == 0.5

test "Perlin frequency":
  var perlin = newPerlin()
  assert perlin.getFrequency() == 1.0

test "Perlin lacunarity":
  var perlin = newPerlin()
  assert perlin.getLacunarity() == 2.0