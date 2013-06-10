/*
 * SKETCHER
 * DCM editor header
 */

use "ui.eh"
use "canvas.eh"
use "graphics.eh"
use "image.eh"
use "sys.eh"
use "dialog.eh"
use "dcm.eh"
use "keyboard.eh"
use "user_interface.eh"

def xyxy_to_xywh(x1: Int, y1: Int, x2: Int, y2: Int): [Int] {
  var result: [Int]
  if (x1 < x2) {
    if (y1 < y2) {
      result = [x1, y1, x2-x1, y2-y1] }
    else {
      result = [x1, y2, x2-y1, y1-y2] } }
  else {
    if (y1 < y2) {
      result = [x2, y1, x1-x2, y2-y1] }
    else {
      result = [x2, y2, x1-x2, y1-y2] } }
  result }  

def show_edit_layer(image: DCMImage, layer: Int) {
  var new_commands = new List()
  new_commands.addall([DCM_SET_OUTLINE_COLOR, 0, DCM_SET_FILL_COLOR, 0xFFFFFF, DCM_SET_FILLED, DCM_SET_LINE_SOLID, DCM_SET_FILL_SOLID])
  var diagonal_cursor = image_from_file("/res/sketcher/diagonal_cursor.png")
  var cursor = image_from_file("/res/sketcher/cursor.png")
  var screen = new Canvas(true)
  screen.add_menu(new Menu("Set line color", 0))
  var mnuSetFillColor = new Menu("Set fill color", 1)
  screen.add_menu(new Menu("Set shape", 2))
  var mnuFilledOn = new Menu("Filled: ON", 3)
  var mnuFilledOff = new Menu("Filled: OFF", 3)
  var mnuSolidLineOff = new Menu("Solid line: OFF", 4)
  var mnuSolidLineOn = new Menu("Solid line: ON", 4)
  screen.add_menu(mnuSolidLineOn)
  var mnuSolidFillOff = new Menu("Solid fill: OFF", 5)
  var mnuSolidFillOn = new Menu("Solid fill: ON", 5)
  var mnuPolarModeOn = new Menu("Polar mode: ON", 6)
  var mnuPolarModeOff = new Menu("Polar mode: OFF", 6)
  screen.add_menu(mnuPolarModeOff)
  screen.add_menu(new Menu("Save layer", 7))
  screen.add_menu(new Menu("Cancel", 8))
  ui_set_screen(screen)
  var screen_width = screen.width
  var screen_height = screen.height
  var screen_graphics = screen.graphics()
  screen_graphics.color = 0x6464FF
  screen_graphics.stroke = DOTTED
  var prerendered_layer = new Image(screen_width, screen_height)
  var prerendered_layer_graphics = prerendered_layer.graphics()
  // fill the image with grids to show transparency
  prerendered_layer_graphics.color = 0xFFFFFF
  prerendered_layer_graphics.fill_rect(0, 0, screen_width, screen_height)
  prerendered_layer_graphics.color = 0x888888
  for (var y = 0, y<screen_height, y+=20) prerendered_layer_graphics.draw_line(0, y, screen_width, y)
  for (var x = 0, x<screen_width, x+=20)  prerendered_layer_graphics.draw_line(x, 0, x, screen_height)
  image.render_layer(layer, prerendered_layer_graphics, screen_width, screen_height)
  prerendered_layer_graphics.color = 0
  screen_graphics.draw_image(prerendered_layer, 0, 0)
  var cursor_x = screen_width / 2
  var cursor_y = screen_height / 2
  var arc_w = 10
  var arc_h  = 10
  var line_color = 0
  var fill_color = 0xFFFFFF
  var filled = true
  var solid_line = true
  var solid_fill = true
  var continue = true
  var keyboard = new Keyboard()
  var current_point = 0
  var current_draw_mode = DCM_LINE
  var former_draw_mode = DCM_LINE
  var temp_points = new [Int](6)
  var move_temp_point_to_cursor = true
  var xywh: [Int]
  var diagonal_movement = true
  while (continue) {
    keyboard.read_key()
    if (keyboard.pressed(KEY_2, UP)) cursor_y -= 1
    if (keyboard.pressed(KEY_4, LEFT)) cursor_x -= 1
    if (keyboard.pressed(KEY_6, RIGHT)) cursor_x += 1
    if (keyboard.pressed(KEY_8, DOWN)) cursor_y += 1
    if (keyboard.pressed(KEY_1)) if (diagonal_movement) {cursor_x-=1 cursor_y-=1} else arc_w -= 1
    if (keyboard.pressed(KEY_3)) if (diagonal_movement) {cursor_x+=1 cursor_y-=1} else arc_w += 1
    if (keyboard.pressed(KEY_7)) if (diagonal_movement) {cursor_x-=1 cursor_y+=1} else arc_h -= 1
    if (keyboard.pressed(KEY_9)) if (diagonal_movement) {cursor_x+=1 cursor_y+=1} else arc_h += 1
    if (keyboard.pressed(KEY_0)) diagonal_movement = !diagonal_movement
    if (keyboard.pressed(KEY_5)) {
      keyboard.release(KEY_5)
      switch (current_draw_mode) {
        DCM_POINT: {
          prerendered_layer_graphics.stroke = SOLID
          prerendered_layer_graphics.color = line_color
          new_commands.addall([DCM_POINT, cursor_x, cursor_y])
          prerendered_layer_graphics.draw_line(cursor_x, cursor_y, cursor_x, cursor_y) }
        DCM_LINE: {
          switch (current_point) {
            0: {
              temp_points[0] = cursor_x
              temp_points[1] = cursor_y
              current_point = 1 }
            1: {
              prerendered_layer_graphics.stroke = (if (solid_line) SOLID else DOTTED)
              prerendered_layer_graphics.color = line_color
              new_commands.addall([DCM_LINE, temp_points[0], temp_points[1], cursor_x, cursor_y])
              prerendered_layer_graphics.draw_line(temp_points[0], temp_points[1], cursor_x, cursor_y)
              if (move_temp_point_to_cursor) {
                temp_points[0] = cursor_x
                temp_points[1] = cursor_y
                current_point = 0 } } } }
        DCM_TRIANGLE: {
          switch (current_point) {
            0: {
              temp_points[0] = cursor_x
              temp_points[1] = cursor_y
              current_point = 1 }
            1: {
              temp_points[2] = cursor_x
              temp_points[3] = cursor_y
              current_point = 2 }
            2: {
              prerendered_layer_graphics.stroke = (if (solid_line) SOLID else DOTTED)
              prerendered_layer_graphics.color = line_color
              new_commands.addall([DCM_TRIANGLE, temp_points[0], temp_points[1], temp_points[2], temp_points[3], cursor_x, cursor_y])
              prerendered_layer_graphics.draw_line(temp_points[0], temp_points[1], temp_points[2], temp_points[3])
              prerendered_layer_graphics.draw_line(temp_points[2], temp_points[3], cursor_x, cursor_y)
              prerendered_layer_graphics.draw_line(cursor_x, cursor_y, temp_points[0], temp_points[1])
              current_point = 0 } } }
        DCM_RECTANGLE: {
          switch (current_point) {
            0: {
              temp_points[0] = cursor_x
              temp_points[1] = cursor_y
              current_point = 1 }
            1: {
              xywh = xyxy_to_xywh(temp_points[0], temp_points[1], cursor_x, cursor_y)
              new_commands.addall([DCM_RECTANGLE, xywh[0], xywh[1], xywh[2], xywh[3]])
              if (filled) {
                prerendered_layer_graphics.color = fill_color
                prerendered_layer_graphics.fill_rect(xywh[0], xywh[1], xywh[2], xywh[3]) }
              prerendered_layer_graphics.stroke = (if (solid_line) SOLID else DOTTED)
              prerendered_layer_graphics.color = line_color
              prerendered_layer_graphics.draw_rect(xywh[0], xywh[1], xywh[2], xywh[3])
/* OUTDATED INEFFICIENT ROUTINE for Rectangles
              prerendered_layer_graphics.draw_line(temp_points[0], temp_points[1], temp_points[0], cursor_y)
              prerendered_layer_graphics.draw_line(temp_points[0], cursor_y, cursor_x, cursor_y)
              prerendered_layer_graphics.draw_line(cursor_x, cursor_y, temp_points[0], cursor_y)
              prerendered_layer_graphics.draw_line(temp_points[0], cursor_y, temp_points[0], temp_points[1]) */
              current_point = 0 } } }
        DCM_OVAL: {
          switch (current_point) {
            0: {
              temp_points[0] = cursor_x
              temp_points[1] = cursor_y
              current_point = 1 }
            1: {
              xywh = xyxy_to_xywh(temp_points[0], temp_points[1], cursor_x, cursor_y)
              new_commands.addall([DCM_OVAL, xywh[0], xywh[1], xywh[2], xywh[3], arc_w, arc_h])
              if (filled) {
                prerendered_layer_graphics.color = fill_color
                prerendered_layer_graphics.fill_roundrect(xywh[0], xywh[1], xywh[2], xywh[3], arc_w, arc_h) }
              prerendered_layer_graphics.stroke = (if (solid_line) SOLID else DOTTED)
              prerendered_layer_graphics.color = line_color
              prerendered_layer_graphics.draw_roundrect(xywh[0], xywh[1], xywh[2], xywh[3], arc_w, arc_h)
              current_point = 0 } } } } }
    if (keyboard.menu_pressed()) {
      if (keyboard.menu_string == "Set line color") {
        line_color = run_colorchooser("Line color", line_color)
        new_commands.addall([DCM_SET_OUTLINE_COLOR, line_color]) }
      else if (keyboard.menu_string == "Set fill color") {
        fill_color = run_colorchooser("Fill color", fill_color)
        new_commands.addall([DCM_SET_FILL_COLOR, fill_color]) }
      else if (keyboard.menu_string == "Set shape") {
        former_draw_mode = current_draw_mode
        current_draw_mode = show_shape_selector(current_draw_mode)
        ui_set_screen(screen)
        current_point = 0
        if (former_draw_mode != DCM_LINE && current_draw_mode == DCM_LINE) {
          // changed draw_mode to line
          screen.remove_menu(mnuSetFillColor)
          if (filled) screen.remove_menu(mnuFilledOn) else screen.remove_menu(mnuFilledOff)
          if (solid_fill) screen.remove_menu(mnuSolidFillOn) else screen.remove_menu(mnuSolidFillOff)
          if (move_temp_point_to_cursor) screen.add_menu(mnuPolarModeOff) else screen.add_menu(mnuPolarModeOn) }
        else if (former_draw_mode == DCM_LINE && current_draw_mode != DCM_LINE) {
          // left line draw_mode
          screen.add_menu(mnuSetFillColor)
          if (filled) screen.add_menu(mnuFilledOn) else screen.add_menu(mnuFilledOn)
          if (solid_fill) screen.add_menu(mnuSolidFillOn) else screen.add_menu(mnuSolidFillOff)
          if (move_temp_point_to_cursor) screen.remove_menu(mnuPolarModeOff) else screen.remove_menu(mnuPolarModeOn) } }
      else if (keyboard.menu_string == "Filled: OFF") {
        screen.remove_menu(mnuFilledOff)
        screen.add_menu(mnuFilledOn)
        filled = true
        new_commands.addall([DCM_SET_FILLED]) }
      else if (keyboard.menu_string == "Filled: ON") {
        screen.remove_menu(mnuFilledOn)
        screen.add_menu(mnuFilledOff)
        filled = false
        new_commands.addall([DCM_SET_HOLLOW]) }
      else if (keyboard.menu_string == "Solid line: OFF") {
        screen.remove_menu(mnuSolidLineOff)
        screen.add_menu(mnuSolidLineOn)
        solid_line = true
        new_commands.addall([DCM_SET_LINE_SOLID]) }
      else if (keyboard.menu_string == "Solid line: ON") {
        screen.remove_menu(mnuSolidLineOn)
        screen.add_menu(mnuSolidLineOff)
        solid_line = false
        new_commands.addall([DCM_SET_LINE_DOTTED]) }
      else if (keyboard.menu_string == "Solid fill: ON") {
        screen.remove_menu(mnuSolidFillOn)
        screen.add_menu(mnuSolidFillOff)
        solid_fill = false
        new_commands.addall([DCM_SET_FILL_DOTTED]) }
      else if (keyboard.menu_string == "Solid fill: OFF") {
        screen.remove_menu(mnuSolidFillOff)
        screen.remove_menu(mnuSolidFillOn)
        solid_fill = true
        new_commands.addall([DCM_SET_FILL_SOLID]) }
      else if (keyboard.menu_string == "Polar mode: OFF") {
        screen.remove_menu(mnuPolarModeOff)
        screen.add_menu(mnuPolarModeOn)
        move_temp_point_to_cursor = false }
      else if (keyboard.menu_string == "Polar mode: ON") {
        screen.remove_menu(mnuPolarModeOn)
        screen.add_menu(mnuPolarModeOff)
        move_temp_point_to_cursor = true }
      else if (keyboard.menu_string == "Save layer") {
        image.add_command(layer, new_commands.toarray())
        continue = false }
      else if (keyboard.menu_string == "Cancel") continue = false }
    screen_graphics.draw_image(prerendered_layer, 0, 0)
    // draw cursor
    if (diagonal_movement) {
      screen_graphics.draw_image(diagonal_cursor, cursor_x-4, cursor_y-4) }
    else {
      screen_graphics.draw_image(cursor, cursor_x-4, cursor_y-4) }
    // draw preview
    switch (current_point) {
      1: {
        switch (current_draw_mode) {
          DCM_LINE, DCM_TRIANGLE: {
            screen_graphics.draw_line(temp_points[0], temp_points[1], cursor_x, cursor_y) }
          DCM_RECTANGLE: {
            xywh = xyxy_to_xywh(temp_points[0], temp_points[1], cursor_x, cursor_y)
            screen_graphics.draw_rect(xywh[0], xywh[1], xywh[2], xywh[3]) }
          DCM_OVAL: {
            xywh = xyxy_to_xywh(temp_points[0], temp_points[1], cursor_x, cursor_y)
            screen_graphics.draw_roundrect(xywh[0], xywh[1], xywh[2], xywh[3], arc_w, arc_h) } } }
      2: {
        screen_graphics.draw_line(temp_points[0], temp_points[1], temp_points[2], temp_points[3])
        screen_graphics.draw_line(temp_points[2], temp_points[3], cursor_x, cursor_y)
        screen_graphics.draw_line(cursor_x, cursor_y, temp_points[0], temp_points[1]) } }
    screen.refresh()
    sleep(10)} }