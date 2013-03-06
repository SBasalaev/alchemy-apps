// definitions

use "list"
use "image"
use "canvas"
use "graphics"
use "form"
use "ui"

use "color_math.eh"

var tile_size_x: Int
var tile_size_y: Int
var img_x: Int
var img_y: Int
var accuracy: Int
var ev: UIEvent

//temp vars
var l: List
var k: Color

// images
var img: Image
var img_graph: Graphics
var tile: Image

//menus
var mnuOK: Menu
var mnuAbout: Menu
var mnuExit: Menu
var mnuAdd: Menu
var mnuRemove: Menu

// UI Items
var txtFile: EditItem
var gauAcc: GaugeItem
var radSystem: RadioItem

// system palette
var sys_pal: List
var sys_pal_size: Int
var sys_pal_votes: List

// screen palette
var scr_pal: List
var scr_pal_size: Int
var scr_pal_votes: List
var zx_paper_color: Color
var zx_paper_votes: List

// tile palette
var tile_pal: List
var tile_pal_size: Int
var tile_pal_votes: List
var tile_color_votes: List

// pixel sweep
var pix_x: Int
var pix_y: Int

// tile sweep
var tile_x: Int
var tile_y: Int

// loop counters
var h: Int
var i: Int
var j: Int

// UI
var canv: Canvas
var canv_graph: Graphics
var main_menu: Form
var about_scr: Form
var txtCaption: EditItem
var chkDither: CheckItem