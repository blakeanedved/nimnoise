# Package

version       = "0.1.1"
author        = "blakeanedved"
description   = "A port of libnoise into pure nim, heavily inspired by Libnoise.Unity, but true to the original Libnoise"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.0.0"

# Tasks

task "test", "Run the Nimble tester":
  withdir "tests":
    exec "nim c -r tester"
