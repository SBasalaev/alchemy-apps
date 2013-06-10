/*
 * SKETCHER
 * DCM types and constants
 */

use "list.eh"
use "image.eh"

const DCM_VERSION = "DCM 5.1"

type Iterator {
  data: List = null,
  index: Int = 0 }

def Iterator.new(data: List);
def Iterator.read(): Int;
def Iterator.can_read(): Bool;
  
type DCMLayer {
  title: String = null,
  x_offset: Int = null,
  y_offset: Int = null,
  rotation: Int = null,
  scaling: Double = null,
  commands: List = null}

def DCMLayer.new(title: String, x: Int = 0, y: Int = 0, rotation: Int = 0, scaling: Int = 1);
def DCMLayer.add_command(command: [Any]);

type DCMImage {
  title: String = null,
  author: String = null,
  date: String = null,
  layers: List = null,
  width: Int = null,
  height: Int = null}

def DCMImage.new(title: String, author: String, date: String);
def DCMImage.add_layer(layer: DCMLayer);
def DCMImage.delete_layer(index: Int);
def DCMImage.add_command(layer: Int, command: [Any]);
def DCMImage.get_layer(index: Int): DCMLayer;
def DCMImage.get_layer_title(index: Int): String;
def open_dcm_file(file_path: String): DCMImage;
def DCMImage.move_up(index: Int);
def DCMImage.move_down(index: Int);
def DCMImage.save_to_file(path: String);
def render_layer_to_image(image: DCMImage, layer_index: Int, width: Int, height: Int): Image;
def DCMImage.render_layer(index: Int, rendered_image_graphics: Graphics, width: Int, height: Int, use_layer_offsets: Bool = false);

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
