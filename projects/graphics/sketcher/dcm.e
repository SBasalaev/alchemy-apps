/*
 * SKETCHER
 * DCM types and constants
 */

 
use "list.eh"
use "dcm.eh"
use "image.eh"
use "graphics.eh"
use "dataio.eh"
use "dialog.eh"
use "string.eh"

def Iterator.new(data: List) {
  this.data = data
  this.index = 0 }

def Iterator.read(): Int {
  this.index += 1
  this.data[this.index-1].cast(Int) }
  
def Iterator.can_read(): Bool {
  this.index < this.data.len() }

def DCMLayer.new(title: String, x: Int = 0, y: Int = 0, rotation: Int = 0, scaling: Int = 1) {
  this.title = title
  this.x_offset = x
  this.y_offset = y
  this.rotation = rotation
  this.scaling = scaling
  this.commands = new List() }

def DCMLayer.add_command(command: [Any]) {
  for (var i=0, i<command.len, i+=1) this.commands.add(command[i].cast(Int)) }

def DCMLayer.get_size(): [Int] {
  var x_size = 1
  var y_size = 1
  var commands = new Iterator(this.commands)
  var command = 0
  var x_arg = 0
  var y_arg = 0
  while (commands.can_read()) {
    command = commands.read()
    switch (command) {
      DCM_POINT: {
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg }
      DCM_LINE: {
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg }
      DCM_TRIANGLE: {
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg 
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg 
        x_arg = commands.read()
        y_arg = commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg }
      DCM_RECTANGLE: {
        x_arg = commands.read()
        y_arg = commands.read()
        x_arg += commands.read()
        y_arg += commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg }
      DCM_OVAL: {
        x_arg = commands.read()
        y_arg = commands.read()
        x_arg += commands.read()
        y_arg += commands.read()
        if (x_size<x_arg) x_size=x_arg
        if (y_size<y_arg) y_size=y_arg
        x_arg = commands.read()
        y_arg = commands.read() }
      DCM_SET_OUTLINE_COLOR, DCM_SET_FILL_COLOR: x_size = commands.read() } }
  var ret = new [Int](2)
  ret[0] = x_size
  ret[1] = y_size
  ret }

def DCMImage.new(title: String, author: String, date: String) {
  this.title = title
  this.author = author
  this.date = date
  this.layers = new List() 
  this.width = null
  this.height = null}

def DCMImage.add_layer(layer: DCMLayer) {
  this.layers.add(layer) }
  
def DCMImage.delete_layer(index: Int) {
  this.layers.remove(index) }
  
def DCMImage.add_command(layer: Int, command: [Any]) {
  this.layers[layer].cast(DCMLayer).add_command(command) }
  
/*def DCMImage.layer_width(layer: Int): Int {
  this.layers[layer].cast(DCMLayer).width }
  
def DCMImage.layer_height(layer: Int): Int {
  this.layers[layer].cast(DCMLayer).height }
*/  
def DCMImage.get_layer(index: Int): DCMLayer {
  this.layers[index].cast(DCMLayer) }

def DCMImage.get_layer_title(index: Int): String {
  var layer = this.get_layer(index)
  layer.title }

def DCMImage.move_up(index: Int) {
  var temp = this.get_layer(index-1)
  this.layers[index-1] = this.layers[index]
  this.layers[index] = temp }
  
def DCMImage.move_down(index: Int) {
  var temp = this.get_layer(index+1)
  this.layers[index+1] = this.layers[index]
  this.layers[index] = temp }
  
def open_dcm_file(file_path: String): DCMImage {
  var event = ""
  var file = fopen_r(file_path)
  var continue = (file.readutf() == "DCM_VECTOR_5.1")
  var image_name = file.readutf()
  var image_author = file.readutf()
  var image_date = file.readutf()
  if (continue) var opened_image = new DCMImage(image_name, image_author, image_date)
  var image_width = file.readushort()
  var image_height = file.readushort()
  var command: Int = 0
  var layer_pointer = -1
  var layer_title = ""
  var layer_x = 0
  var layer_y = 0
  var layer_rotation = 0
  var layer_scaling = 1
  var error = false
  var coords = new [Int](6)
  var file_position = 0x10 + image_name.len() + 2 + image_author.len() + 2 + image_date.len() + 2
  var error_message = ""
  var history = ""
  try {
    event = "getting first command"
    command = file.readubyte()
    history += "got "+command.tohex()
    file_position += 1 }
  catch { 
    continue = false error = true }
  do {
    switch (command) {
      DCM_SET_OUTLINE_COLOR, DCM_SET_FILL_COLOR: {
//      event = switch (command) { DCM_SET_OUTLINE_COLOR: "setting line color" DCM_SET_FILL_COLOR: "setting fill color" }
        event = "getting line/fill color"
        coords[0] = file.readint()
        opened_image.add_command(layer_pointer, [command, coords[0]])
        file_position += 4
        history += ", set color ("+coords[0].tostr()+")\n" }
      DCM_POINT: {
        event = "reading point coords"
        coords[0] = file.readushort()
        coords[1] = file.readushort()
        opened_image.add_command(layer_pointer, [DCM_POINT, coords[0], coords[1]])
        file_position += 4
        history += ", drew point ("+coords[0].tostr()+","+coords[1].tostr()+")\n" }
      DCM_LINE, DCM_RECTANGLE: {
//      event = switch (command) { DCM_LINE: "getting line coords" DCM_RECTANGLE: "getting rectangle coords" }
        event = "getting line/rectangle coords"
        coords[0] = file.readushort()
        coords[1] = file.readushort()
        coords[2] = file.readushort()
        coords[3] = file.readushort()
        file_position += 8
        opened_image.add_command(layer_pointer, [command, coords[0], coords[1], coords[2], coords[3]])
        history += ", drew line ("+coords[0].tostr()+","+coords[1].tostr()+","+coords[2].tostr()+","+coords[3].tostr()+")\n" }
      DCM_TRIANGLE, DCM_OVAL: {
//      event = switch (command) { DCM_TRIANGLE: "getting triangle coords" DCM_OVAL: "getting oval coords" }
        event = "getting triangle/rectangle coords"
        coords[0] = file.readushort()
        coords[1] = file.readushort()
        coords[2] = file.readushort()
        coords[3] = file.readushort()
        coords[4] = file.readushort()
        coords[5] = file.readushort()
        file_position += 12
        opened_image.add_command(layer_pointer, [command, coords[0], coords[1], coords[2], coords[3], coords[4], coords[5]])
        history += ", drew triangle ("+coords[0].tostr()+","+coords[1].tostr()+","+coords[2].tostr()+","+coords[3].tostr()+coords[4].tostr()+","+coords[5].tostr()+")\n" }
      DCM_NEW_LAYER: {
        layer_title = file.readutf()
        layer_x = file.readshort()
        layer_y = file.readshort()
        layer_rotation = file.readshort()
        layer_scaling = file.readdouble()
        opened_image.add_layer(new DCMLayer(layer_title, layer_x, layer_y, layer_rotation, layer_scaling))
        event = "layer creation succeeded"
        layer_pointer += 1
        file_position += layer_title.len() + 2 + 0xE
        history += ", added layer ("+layer_title+","+layer_x.tostr()+","+layer_y.tostr()+","+layer_rotation.tostr()+","+layer_scaling.tostr()+")\n" }
      DCM_SET_FILLED, DCM_SET_HOLLOW, DCM_SET_LINE_DOTTED, DCM_SET_LINE_SOLID, DCM_SET_FILL_DOTTED, DCM_SET_FILL_SOLID: {
        event = "setting filled/dotted status"
        opened_image.add_command(layer_pointer, [command])
        file_position += 1
        history += ", set status\n" }
      else: {
        continue = false
        error = true } }
    try {
      command = file.readubyte() }
    catch {
      continue = false } 
    history += "got " + command.tohex() }
  while (continue)
  file.close()
  if (error) {
    error_message = "An error has been encountered while reading the file. It occured after "+event+". The file may be corrupted, or is not a valid DCMv5 file. (Command #"+command.tohex()+", file position "+file_position.tohex()+")"
    run_alert("Error", error_message) 
    println("E: "+error_message)
    println(history) }
  opened_image }

def DCMImage.render_layer(index: Int, rendered_image_graphics: Graphics, width: Int, height: Int, use_layer_offsets: Bool = false) {
  var layer = this.get_layer(index)
  var layer_offset_x = layer.x_offset
  var layer_offset_y = layer.y_offset
  rendered_image_graphics.color = 0
  var commands = new Iterator(layer.commands)
  var command = 0
  var x_arg: Int = 0
  var y_arg: Int = 0
  var x2_arg: Int = 0
  var y2_arg: Int = 0
  var x3_arg: Int = 0
  var y3_arg: Int = 0
  var filled = true
  var fill_solid = true
  var line_solid = true
  var line_color = 0
  var fill_color = 0xFFFFFF
  while(commands.can_read()) {
    command = commands.read()
    switch (command) {
      DCM_LINE: {
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        if (use_layer_offsets) {
          rendered_image_graphics.draw_line(commands.read()+layer_offset_x, commands.read()+layer_offset_y, commands.read()+layer_offset_x, commands.read()+layer_offset_y) }
        else {
          rendered_image_graphics.draw_line(commands.read(), commands.read(), commands.read(), commands.read()) } }
      DCM_POINT: {
        rendered_image_graphics.stroke = SOLID
        x_arg = commands.read()
        y_arg = commands.read()
        if (use_layer_offsets) {
          rendered_image_graphics.draw_line(x_arg+layer_offset_x, y_arg+layer_offset_y, x_arg+layer_offset_x, y_arg+layer_offset_y) }
        else {
          rendered_image_graphics.draw_line(x_arg, y_arg, x_arg, y_arg) } }
      DCM_TRIANGLE: {
        x_arg = commands.read()
        y_arg = commands.read()
        x2_arg = commands.read()
        y2_arg = commands.read()
        x3_arg = commands.read()
        y3_arg = commands.read()
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        if (use_layer_offsets) {
          rendered_image_graphics.draw_line(x_arg+layer_offset_x, y_arg+layer_offset_y, x2_arg+layer_offset_x, y2_arg+layer_offset_y)
          rendered_image_graphics.draw_line(x2_arg+layer_offset_x, y2_arg+layer_offset_y, x3_arg+layer_offset_x, y3_arg+layer_offset_y)
          rendered_image_graphics.draw_line(x3_arg+layer_offset_x, y3_arg+layer_offset_y, x_arg+layer_offset_x, y_arg+layer_offset_y) }
        else {
          rendered_image_graphics.draw_line(x_arg, y_arg, x2_arg, y2_arg)
          rendered_image_graphics.draw_line(x2_arg, y2_arg, x3_arg, y3_arg)
          rendered_image_graphics.draw_line(x3_arg, y3_arg, x_arg, y_arg) } }
      DCM_OVAL: {
        x_arg = commands.read()
        y_arg = commands.read()
        x2_arg = commands.read()
        y2_arg = commands.read()
        x3_arg = commands.read()
        y3_arg = commands.read()
        if (use_layer_offsets) {
          if (filled) {
            rendered_image_graphics.color = fill_color
            rendered_image_graphics.fill_roundrect(x_arg+layer_offset_x, y_arg+layer_offset_y, x2_arg, y2_arg, x3_arg, y3_arg) }
          rendered_image_graphics.color = line_color
          rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
          rendered_image_graphics.draw_roundrect(x_arg+layer_offset_x, y_arg+layer_offset_y, x2_arg, y2_arg, x3_arg, y3_arg) }
        else {        
          if (filled) {
            rendered_image_graphics.color = fill_color
            rendered_image_graphics.fill_roundrect(x_arg, y_arg, x2_arg, y2_arg, x3_arg, y3_arg) }
          rendered_image_graphics.color = line_color
          rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
          rendered_image_graphics.draw_roundrect(x_arg, y_arg, x2_arg, y2_arg, x3_arg, y3_arg) } }
      DCM_RECTANGLE: {
        x_arg = commands.read()
        y_arg = commands.read()
        x2_arg = commands.read() 
        y2_arg = commands.read()
        if (use_layer_offsets) {
          if (filled) {
            rendered_image_graphics.color = fill_color
            rendered_image_graphics.fill_rect(x_arg+layer_offset_x, y_arg+layer_offset_y, x2_arg, y2_arg) }
          rendered_image_graphics.color = line_color
          rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
          rendered_image_graphics.draw_rect(x_arg+layer_offset_x, y_arg+layer_offset_y, x2_arg, y2_arg) }
        else {
          if (filled) {
            rendered_image_graphics.color = fill_color
            rendered_image_graphics.fill_rect(x_arg, y_arg, x2_arg, y2_arg) }
          rendered_image_graphics.color = line_color
          rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
          rendered_image_graphics.draw_rect(x_arg, y_arg, x2_arg, y2_arg) } }
      DCM_SET_OUTLINE_COLOR: { line_color = commands.read() }
      DCM_SET_FILL_COLOR:    { fill_color = commands.read() }
      DCM_SET_FILLED:        { filled = true }
      DCM_SET_HOLLOW:        { filled = false }
      DCM_SET_LINE_DOTTED:   { line_solid = false }
      DCM_SET_LINE_SOLID:    { line_solid = true }
      DCM_SET_FILL_DOTTED:   { fill_solid = false }
      DCM_SET_FILL_SOLID:    { fill_solid = true } } } }
  
def DCMImage.save_to_file(path: String) {
  var file = fopen_w(path)
  file.writeutf("DCM_VECTOR_5.1")
  file.writeutf(this.title)
  file.writeutf(this.author)
  file.writeutf(this.date)
  var image_width = 300
  var image_height = 300
  file.writeshort(image_width)
  file.writeshort(image_height)
  var command: Int = 0
  var commands: Iterator
  for (var i=0, i<this.layers.len(), i+=1) {
    file.writebyte(DCM_NEW_LAYER)
    file.writeutf(this.get_layer_title(i))
    file.writeshort(this.layers[i].cast(DCMLayer).x_offset)
    file.writeshort(this.layers[i].cast(DCMLayer).y_offset)
    file.writeshort(this.layers[i].cast(DCMLayer).rotation)
    file.writedouble(this.layers[i].cast(DCMLayer).scaling)
    commands = new Iterator(this.layers[i].cast(DCMLayer).commands)
    while (commands.can_read()) {
    command = commands.read()
      file.writebyte(command)
      switch (command) {
        DCM_SET_OUTLINE_COLOR, DCM_SET_FILL_COLOR: {
          file.writeint(commands.read()) }
        DCM_POINT: {
          file.writeshort(commands.read())
          file.writeshort(commands.read()) }
        DCM_LINE, DCM_RECTANGLE: {
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read()) }
        DCM_TRIANGLE, DCM_OVAL: {
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read())
          file.writeshort(commands.read()) } } } }
  file.flush()
  file.close()}

def render_layer_to_image(image: DCMImage, layer_index: Int, width: Int, height: Int): Image {
  var layer = image.get_layer(layer_index)
  var layer_size = layer.size
  var rendered_image = new Image(width, height)
  width -= 2
  height -= 2
  var x_factor: Double = (layer_size[0].cast(Double)) / (width.cast(Double))
  var y_factor: Double = (layer_size[1].cast(Double)) / (height.cast(Double))
  var rendered_image_graphics = rendered_image.graphics()
  rendered_image_graphics.color = 0
  var commands = new Iterator(layer.commands)
  var command = 0
  var x_arg: Double = 0
  var y_arg: Double = 0
  var x2_arg: Double = 0
  var y2_arg: Double = 0
  var x3_arg: Double = 0
  var y3_arg: Double = 0
  var filled = true
  var fill_solid = true
  var line_solid = true
  var line_color = 0
  var fill_color = 0xFFFFFF
  while(commands.can_read()) {
    command = commands.read()
    switch (command) {
      DCM_LINE: {
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        rendered_image_graphics.draw_line(commands.read().cast(Double)/x_factor, commands.read().cast(Double)/y_factor, commands.read().cast(Double)/x_factor, commands.read().cast(Double)/y_factor) }
      DCM_POINT: {
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = SOLID
        x_arg = commands.read().cast(Double)/x_factor
        y_arg = commands.read().cast(Double)/y_factor
        rendered_image_graphics.draw_line(x_arg, y_arg, x_arg, y_arg) }
      DCM_TRIANGLE: {
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        x_arg = commands.read().cast(Double)/x_factor
        y_arg = commands.read().cast(Double)/y_factor
        x2_arg = commands.read().cast(Double)/x_factor
        y2_arg = commands.read().cast(Double)/y_factor
        x3_arg = commands.read().cast(Double)/x_factor
        y3_arg = commands.read().cast(Double)/y_factor
        rendered_image_graphics.draw_line(x_arg, y_arg, x2_arg, y2_arg)
        rendered_image_graphics.draw_line(x2_arg, y2_arg, x3_arg, y3_arg)
        rendered_image_graphics.draw_line(x3_arg, y3_arg, x_arg, y_arg) }
      DCM_OVAL: {
        x_arg = commands.read().cast(Double)/x_factor
        y_arg = commands.read().cast(Double)/y_factor
        x2_arg = (x_arg+commands.read())/x_factor
        y2_arg = (y_arg+commands.read())/y_factor
        x3_arg = commands.read().cast(Double)/x_factor
        y3_arg = commands.read().cast(Double)/y_factor
        if (filled) {
          rendered_image_graphics.color = fill_color
          rendered_image_graphics.fill_roundrect(x_arg, y_arg, x2_arg, y2_arg, x3_arg, y3_arg) }
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        rendered_image_graphics.draw_roundrect(x_arg, y_arg, x2_arg, y2_arg, x3_arg, y3_arg) }
      DCM_RECTANGLE: {
        x_arg = commands.read().cast(Double)/x_factor
        y_arg = commands.read().cast(Double)/y_factor
        x2_arg = commands.read().cast(Double)/x_factor 
        y2_arg = commands.read().cast(Double)/y_factor
        if (filled) {
          rendered_image_graphics.color = fill_color
          rendered_image_graphics.fill_rect(x_arg, y_arg, x2_arg, y2_arg) }
        rendered_image_graphics.color = line_color
        rendered_image_graphics.stroke = (if (line_solid) SOLID else DOTTED)
        rendered_image_graphics.draw_rect(x_arg, y_arg, x2_arg, y2_arg) }
      DCM_SET_OUTLINE_COLOR: { line_color = commands.read() }
      DCM_SET_FILL_COLOR:    { fill_color = commands.read() }
      DCM_SET_FILLED:        { filled = true }
      DCM_SET_HOLLOW:        { filled = false }
      DCM_SET_LINE_DOTTED:   { line_solid = false }
      DCM_SET_LINE_SOLID:    { line_solid = true }
      DCM_SET_FILL_DOTTED:   { fill_solid = false }
      DCM_SET_FILL_SOLID:    { fill_solid = true } } }
  rendered_image }