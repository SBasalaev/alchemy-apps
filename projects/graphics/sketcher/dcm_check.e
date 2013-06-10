// DCM5 file error diagnostics.
// This program simply checks a DCM5 image for errors, most possibly made by Sketcher when writing the file.

use "dataio.eh"
use "io.eh"
use "string.eh"

// DCM Commands constants
// Shapes
const DCM_POINT     = 0x70           // [x, y]
const DCM_LINE      = 0x71           // [x1, y1, x2, y2]
const DCM_TRIANGLE  = 0x72           // [x1, y1, x2, y2, x3, y3]
const DCM_RECTANGLE = 0x73           // [x1, y1, w, h]
const DCM_POLYGON   = 0x74
const DCM_OVAL      = 0x75           // [x1, y1, w, h, aw, ah]
const DCM_ARC       = 0x76
// attribute modifiers
const DCM_SET_OUTLINE_COLOR = 0x80   // [color]
const DCM_SET_FILL_COLOR    = 0x81   // [color]
const DCM_SET_FILLED        = 0x82   // no args
const DCM_SET_HOLLOW        = 0x83   // no args
const DCM_SET_LINE_DOTTED   = 0x84   // no args
const DCM_SET_LINE_SOLID    = 0x85   // no args
const DCM_SET_FILL_DOTTED   = 0x86   // no args
const DCM_SET_FILL_SOLID    = 0x87   // no args
// File structure commands
const DCM_NEW_LAYER         = 0x90   // [title, x_offset, y_offset, rotation, scaling, commands.............]

def main(args: [String]) {
  if (args.len > 0) {
    var command = 0
    var arg = new [Int](6)
    var file = fopen_r(args[0])
    var continue = true
    if (file.readutf() == "DCM_VECTOR_5.1") {
      println("File is verified DCMv5.") }
    else {
      println("File is not a DCMv5 file.")
      var continue = false }
    println(file.readutf())
    println(file.readutf())
    println(file.readutf())
    println(file.readushort())
    println(file.readushort())
    command = file.readubyte()
    do {
      switch (command) {
        DCM_POINT: {
          println("point")
          println(file.readushort())
          println(file.readushort()) }
        DCM_LINE, DCM_RECTANGLE: {
          if (command == DCM_LINE) println("line") else println("rectangle")
          println(file.readushort())
            println(file.readushort())
              println(file.readushort())
                println(file.readushort()) }
        DCM_TRIANGLE, DCM_OVAL: {
                  if (command == DCM_TRIANGLE) println("triangle") else println("oval")
          println(file.readushort())
          println(file.readushort())
          println(file.readushort())
          println(file.readushort())
          println(file.readushort())
          println(file.readushort()) }
        DCM_SET_OUTLINE_COLOR, DCM_SET_FILL_COLOR: {
          if (command == DCM_SET_OUTLINE_COLOR) println("line color") else println("fill color")
          println(file.readint().tohex()) }
        DCM_NEW_LAYER: {
          println("new layer")
          println(file.readutf())
          println(file.readushort())
          println(file.readushort())
          println(file.readushort())
          println(file.readdouble()) }
        else: {
          println("errorrrrr!!!") } }
      try {
        command = file.readubyte() }
      catch {
        continue = false } }
    while (continue) } }
      
