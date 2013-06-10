/*
 * SKETCHER
 * User interface header
 */

use "ui.eh"
use "ui_edit.eh"
use "form.eh"
use "dcm_editor.eh"
use "dcm.eh"
use "easy_menu_event.eh"
use "stdscreens.eh"
use "dialog.eh"
use "string.eh"
use "easy_menu_event.eh"
use "keyboard.eh"
use "canvas.eh"

def show_new_image(): DCMImage {
  var frmNewImage = new Form()
  frmNewImage.title = "New Image"
  var txtTitle = new EditItem("Image name:", "New", EDIT_ANY, 100)
  frmNewImage.add(txtTitle)
  var txtAuthor = new EditItem("Author:", "Me", EDIT_ANY, 100)
  frmNewImage.add(txtAuthor)
  var txtDate = new EditItem("Date:", "None", EDIT_ANY, 50)
  frmNewImage.add(txtDate)
  frmNewImage.add_menu(new Menu("Okay", 0, MT_OK))
  frmNewImage.add_menu(new Menu("Cancel", 1, MT_CANCEL))
  ui_set_screen(frmNewImage)
  var response = wait_menu()
  if (response == "Okay") new DCMImage(txtTitle.text, txtAuthor.text, txtDate.text) else null }

def show_add_new_layer(image: DCMImage, layer_list: ListBox) {
  var frmNewLayer = new Form()
  frmNewLayer.title = "New layer"
  var txtLayerTitle = new EditItem("Layer title:", "Layer", EDIT_ANY, 30)
  frmNewLayer.add(txtLayerTitle)
  frmNewLayer.add_menu(new Menu("Okay", 0))
  frmNewLayer.add_menu(new Menu("Cancel", 1))
  ui_set_screen(frmNewLayer)
  var response = wait_menu()
  if (response == "Okay") {
    var created_layer = new DCMLayer(txtLayerTitle.text)
    image.add_layer(created_layer)
    layer_list.add(image.get_layer_title(image.layers.len()-1), render_layer_to_image(image, image.layers.len()-1, 64, 64)) } }
  
def delete_layer(image: DCMImage, layer_list: ListBox) {
  if (run_yesno("Delete layer", "Are you sure you want to delete "+layer_list.get_string(layer_list.index)+"?")) {
    image.delete_layer(layer_list.index)
    layer_list.delete(layer_list.index) } }

def move_up(image: DCMImage, layer_list: ListBox) {
  if (layer_list.index > 0) {
    image.move_up(layer_list.index)
    var temp_text = layer_list.get_string(layer_list.index-1)
    var temp_image = layer_list.get_image(layer_list.index-1)
    layer_list.set(layer_list.index-1, layer_list.get_string(layer_list.index), layer_list.get_image(layer_list.index))
    layer_list.set(layer_list.index, temp_text, temp_image)
    layer_list.index = layer_list.index-1 }
  else {
    run_alert("Error", "You can't move up something that is already at the top.") } }
  
def move_down(image: DCMImage, layer_list: ListBox) {
  if (layer_list.index < (layer_list.len()-1)) {
    image.move_down(layer_list.index)
    var temp_text = layer_list.get_string(layer_list.index+1)
    var temp_image = layer_list.get_image(layer_list.index+1)
    layer_list.set(layer_list.index+1, layer_list.get_string(layer_list.index), layer_list.get_image(layer_list.index))
    layer_list.set(layer_list.index, temp_text, temp_image)
    layer_list.index = layer_list.index+1 }
  else {
    run_alert("Error", "You can't move down something that is already at the bottom.") } }

def show_move_layer(image: DCMImage, index: Int) {
  var original_x = image.get_layer(index).x_offset
  var original_y = image.get_layer(index).y_offset
  var current_x = original_x
  var current_y = original_y
  var current_movement = 0
  var canvas = new Canvas(true)
  ui_set_screen(canvas)
  var canvas_graphics = canvas.graphics()
  canvas.add_menu(new Menu("Okay", 0))
  canvas.add_menu(new Menu("Cancel", 1))
  var width = canvas.width
  var height = canvas.height
  var prerendered_image = new Image(width, height)
  var prerendered_image_graphics = prerendered_image.graphics()
  var continue = true
  var movement_text = "Fast"
  var kb = new Keyboard()
  do {
    kb.read_key()
    if (kb.pressed(KEY_2)) {
      switch (current_movement) {
        0: current_y -= 10
        1: current_y -= 5
        2: current_y -= 1 } }
    else if (kb.pressed(KEY_4)) {
      switch (current_movement) {
        0: current_x -= 10
        1: current_x -= 5
        2: current_x -= 1 } }
    else if  (kb.pressed(KEY_6)) {
      switch (current_movement) {
        0: current_x += 10
        1: current_x += 5
        2: current_x += 1 } }
    else if  (kb.pressed(KEY_8)) {
      switch (current_movement) {
        0: current_y += 10
        1: current_y += 5
        2: current_y += 1 } }
    else if (kb.pressed(KEY_0)) {
      current_movement += 1
      if (current_movement == 3) current_movement = 0
      switch (current_movement) {
        0: {
          movement_text = "Fast" }
        1: {
          movement_text = "Normal" }
        2: {
          movement_text = "Precise" } } }
    if (kb.menu_pressed()) {
      if (kb.menu_string == "Okay") continue = false
      else if (kb.menu_string == "Cancel") {
        image.get_layer(index).x_offset = original_x
        image.get_layer(index).y_offset = original_y } }
    image.get_layer(index).x_offset = current_x
    image.get_layer(index).y_offset = current_y    
    // clear & fill the image with grids to show transparency
    prerendered_image_graphics.color = 0xFFFFFF
    prerendered_image_graphics.fill_rect(0, 0, width, height)
    prerendered_image_graphics.color = 0x888888
    for (var y = 0, y<height, y+=20) prerendered_image_graphics.draw_line(0, y, width, y)
    for (var x = 0, x<width, x+=20)  prerendered_image_graphics.draw_line(x, 0, x, height)
    for (var i = image.layers.len()-1, i >= 0, i-=1) {
      image.render_layer(i, prerendered_image_graphics, width, height, true) }
    // draw movement speed
    prerendered_image_graphics.color = 0
    prerendered_image_graphics.draw_string(movement_text, 0, height-20)
    // render and display
    canvas_graphics.draw_image(prerendered_image, 0, 0)
    canvas.refresh() }
  while (continue) }

def show_scale_layer(image: DCMImage, index: Int) { }  

def show_rotate_layer(image: DCMImage, index: Int) { }

def show_rename_layer(image: DCMImage, layer_list: ListBox) {
  var frmRename = new Form()
  frmRename.title = "Rename layer"
  frmRename.add(new ImageItem(layer_list.get_string(layer_list.index), layer_list.get_image(layer_list.index)))
  var txtRename = new EditItem("New title:", layer_list.get_string(layer_list.index), EDIT_ANY, 500)
  frmRename.add(txtRename)
  frmRename.add_menu(new Menu("Okay", 0))
  ui_set_screen(frmRename)
  wait_menu()
  image.get_layer(layer_list.index).title = (txtRename.text) }

def show_preview_image(image: DCMImage) {
  var result = new Canvas(true)
  result.add_menu(new Menu("Okay", 0))
  ui_set_screen(result)
  var width = result.width
  var height = result.height
  var result_graphics = result.graphics()
  result_graphics.color = 0
  result_graphics.draw_string("Drawing preview...", 0, 0)
  result_graphics.color = 0xFFFFFF
  result_graphics.fill_rect(0, 0, width, height)
  result.refresh()
  // fill the image with grids to show transparency
  result_graphics.color = 0xFFFFFF
  result_graphics.fill_rect(0, 0, width, height)
  result_graphics.color = 0x888888
  for (var y = 0, y<height, y+=20) result_graphics.draw_line(0, y, width, y)
  for (var x = 0, x<width, x+=20)  result_graphics.draw_line(x, 0, x, height)
  for (var i = image.layers.len()-1, i >= 0, i-=1) {
    image.render_layer(i, result_graphics, width, height, true) }
  result.refresh()
  wait_menu() }

def populate_layer_list(layer_list: ListBox, image: DCMImage) {
  var title = ""
  var rendered_image: Image = null
  layer_list.clear()
  for (var i = 0, i<image.layers.len(), i+=1) {
    title = image.get_layer_title(i)
    rendered_image = render_layer_to_image(image, i, 64, 64)
    layer_list.add(title, rendered_image) } }

def show_save_image(image: DCMImage) {
  var frmSave = new Form()
  frmSave.title = "Save image"
  var txtDirectory = new EditItem("Directory:", "/home", EDIT_ANY, 100)
  frmSave.add(txtDirectory)
  var txtFilename = new EditItem("Filename:", "new_image.dcm")
  frmSave.add(txtFilename)
  frmSave.add_menu(new Menu("Choose directory", 0))
  frmSave.add_menu(new Menu("Save", 1))
  frmSave.add_menu(new Menu("Cancel", 2, MT_CANCEL))
  ui_set_screen(frmSave)
  var response = wait_menu()
  if (response == "Choose directory") txtDirectory.text = run_dirchooser("Choose directory", txtDirectory.text)
  else if (response == "Save") {
    if ((txtDirectory.text.startswith("/") && (!txtDirectory.text.endswith("/"))) && (txtFilename.text.endswith(".dcm") || txtFilename.text.endswith(".DCM"))) {
      image.save_to_file(txtDirectory.text+"/"+txtFilename.text)
      run_alert("File save", "File saved successfully.") }
    else {
      run_alert("Error!", "Use absolute paths only. File should end with DCM extension") } } }
      
def show_shape_selector(current: Int): Int {
  var frmShapes = new Form()
  frmShapes.title = "Choose shape"
  var rdoShapes = new RadioItem("Shapes:", ["Point", "Line", "Triangle", "Rectangle", "Polygon", "Oval", "Arc"])
  rdoShapes.index = current - 0x70
  frmShapes.add(rdoShapes)
  frmShapes.add_menu(new Menu("Okay", 0, MT_CANCEL))
  ui_set_screen(frmShapes)
  var response = wait_menu()
  rdoShapes.index + 0x70 }

def count_commands(c: List): Int {
  var count = 0
  var com = new Iterator(c)
  var continue = com.can_read()
  var command = 0
  var dummy = 0
  if (continue) {
    do {
      command = com.read()
      switch (command) {
        DCM_SET_FILLED, DCM_SET_HOLLOW, DCM_SET_LINE_DOTTED, DCM_SET_LINE_SOLID, DCM_SET_FILL_DOTTED, DCM_SET_FILL_SOLID: {
          count += 1 }
        DCM_SET_OUTLINE_COLOR, DCM_SET_FILL_COLOR: {
          dummy = com.read()
          count += 1 }
        DCM_POINT: {
          dummy = com.read()
          dummy = com.read()
          count += 1 }
        DCM_LINE, DCM_RECTANGLE: {
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          count += 1 }
        DCM_TRIANGLE, DCM_OVAL: {
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          dummy = com.read()
          count += 1 } } }
    while (com.can_read()) }
  count }

def show_image_info(image: DCMImage) {
  var frmImageInfo = new Form()
  frmImageInfo.title = "Image properties"
  var txtTitle = new EditItem("Title:", image.title, EDIT_ANY, 100)
  frmImageInfo.add(txtTitle)
  var txtAuthor = new EditItem("Author:", image.author, EDIT_ANY, 100)
  frmImageInfo.add(txtAuthor)
  var txtDate = new EditItem("Date:", image.date, EDIT_ANY, 100)
  frmImageInfo.add(txtDate)
  frmImageInfo.add(new TextItem("Layers:", image.layers.len().tostr()))
  frmImageInfo.add_menu(new Menu("Back", 0, MT_CANCEL))
  frmImageInfo.add_menu(new Menu("Save", 1))
  ui_set_screen(frmImageInfo)
  var response = wait_menu()
  if (response == "Save") {
    image.title = txtTitle.text
    image.author = txtAuthor.text
    image.date = txtDate.text } }
    
def show_layer_info(index: Int, image: DCMImage) {
  var frmLayerInfo = new Form()
  frmLayerInfo.title = "Layer properties"
  var layer = image.get_layer(index)
  frmLayerInfo.add(new TextItem("Title:", layer.title))
  frmLayerInfo.add(new TextItem("Offset:", "("+layer.x_offset.tostr()+", "+layer.y_offset.tostr()+")"))
  frmLayerInfo.add(new TextItem("Rotation:", layer.rotation.tostr()+"deg"))
  frmLayerInfo.add(new TextItem("Scaling:", (layer.scaling * 100).tostr()+"%"))
  frmLayerInfo.add(new TextItem("Commands:", count_commands(layer.commands).tostr()))
  frmLayerInfo.add_menu(new Menu("Back", 0, MT_CANCEL))
  ui_set_screen(frmLayerInfo)
  var response = wait_menu() }
  
def show_export_image(image: DCMImage) {
  var frmSave = new Form()
  frmSave.title = "Export bitmap"
  var txtDirectory = new EditItem("Directory:", "/home", EDIT_ANY, 100)
  frmSave.add(txtDirectory)
  var txtFilename = new EditItem("Filename:", "image_export.bmp")
  frmSave.add(txtFilename)
  frmSave.add_menu(new Menu("Choose directory", 0))
  frmSave.add_menu(new Menu("Save", 1))
  frmSave.add_menu(new Menu("Cancel", 2, MT_CANCEL))
  ui_set_screen(frmSave)
  var response = wait_menu()
  if (response == "Choose directory") txtDirectory.text = run_dirchooser("Choose directory", txtDirectory.text)
  else if (response == "Save") {
    if ((txtDirectory.text.startswith("/") && (!txtDirectory.text.endswith("/"))) && (txtFilename.text.endswith(".dcm") || txtFilename.text.endswith(".DCM"))) {
      // under construction
      run_alert("File save", "File saved successfully.") }
    else {
      run_alert("Error!", "Use absolute paths only. File should end with DCM extension") } } }
  
  
def show_edit_layers(image: DCMImage) {
  var mnuEdit = new Menu("Edit", 0)
  var layer_list = new ListBox([], [], mnuEdit)
  layer_list.title = "Layers"
  layer_list.add_menu(mnuEdit)
  layer_list.add_menu(new Menu("New layer", 1))
  var mnuDeleteLayer = new Menu("Delete layer", 2)
  var mnuMoveUp = new Menu("Move up", 3)
  var mnuMoveDown = new Menu("Move down", 4)
  var mnuMoveLayer = new Menu("Move layer", 5)
//var mnuScaleLayer = new Menu("Scale layer", 6)
//var mnuRotateLayer = new Menu("Rotate layer", 7)
  var mnuRenameLayer = new Menu("Rename layer", 8)
  var mnuPreviewImage = new Menu("Preview image", 9)
  var mnuSaveImage = new Menu("Save image", 10)
  var mnuSaveBMP = new Menu("Export image", 11)
  var mnuLayerInfo = new Menu("Layer properties", 12)
  var mnuImageInfo = new Menu("Image properties", 13)
  layer_list.add_menu(mnuDeleteLayer)
  layer_list.add_menu(mnuMoveUp)
  layer_list.add_menu(mnuMoveDown)
  layer_list.add_menu(mnuMoveLayer)
//layer_list.add_menu(mnuScaleLayer)
//layer_list.add_menu(mnuRotateLayer)
  layer_list.add_menu(mnuRenameLayer)
  layer_list.add_menu(mnuPreviewImage)
  layer_list.add_menu(mnuSaveImage)
//layer_list.add_menu(mnuSaveBMP)
  layer_list.add_menu(mnuLayerInfo)
  layer_list.add_menu(mnuImageInfo)
  layer_list.add_menu(new Menu("Close", 13))
  var prompt_save = false
  populate_layer_list(layer_list, image)
  var response = ""
  var continue = true
  ui_set_screen(layer_list)
  do {
    response = wait_menu()
    if (response == "Edit") {
      if (layer_list.len()>0) {
        show_edit_layer(image, layer_list.index)
        populate_layer_list(layer_list, image)
        ui_set_screen(layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "You need to create a layer first before you can edit it!") } }
    else if (response == "New layer") {
      show_add_new_layer(image, layer_list)
      ui_set_screen(layer_list)
      prompt_save = true }
    else if (response == "Delete layer") {
      if (layer_list.len()>0) {
        delete_layer(image, layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "You can't delete nothing!") } }
    else if (response == "Move up") {
      if (layer_list.len() > 0) {
        if (layer_list.index > 0) {
          move_up(image, layer_list)
          prompt_save = true }
        else {
          run_alert("Error", "That can't be moved up.") } }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Move down") {
      if (layer_list.len() > 0) {
        if (layer_list.index == (layer_list.len()-1)) {
          move_down(image, layer_list)
          prompt_save = true }
        else {
          run_alert("Error", "That can't be moved down.") } }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Move layer") {
      if (layer_list.len() > 0) {
        show_move_layer(image, layer_list.index)
        ui_set_screen(layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Scale layer") {
      if (layer_list.len() > 0) {
        show_scale_layer(image, layer_list.index)
        ui_set_screen(layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Rotate layer") {
      if (layer_list.len() > 0) {
        show_rotate_layer(image, layer_list.index)
        ui_set_screen(layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Rename layer") {
      if (layer_list.len() > 0) {
        show_rename_layer(image, layer_list)
        ui_set_screen(layer_list)
        prompt_save = true }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Preview image") {
      show_preview_image(image)
      populate_layer_list(layer_list, image)
      ui_set_screen(layer_list) }
    else if (response == "Save image") {
      show_save_image(image)
      ui_set_screen(layer_list)
      prompt_save = false }
    else if (response == "Export image") {
      show_export_image(image)
      ui_set_screen(layer_list) }
    else if (response == "Layer properties") {
      if (layer_list.len() > 0) {
        show_layer_info(layer_list.index, image)
        ui_set_screen(layer_list) }
      else {
        run_alert("Error", "There are no layers.") } }
    else if (response == "Image properties") {
      show_image_info(image)
      ui_set_screen(layer_list) }
    else if (response == "Close") {
      if (prompt_save) {
        continue = !run_yesno("Warning", "Changes to image is not saved yet. Are you sure you want to exit without saving the changes first?") }
      else {
        continue = false } } }
  while (continue) }
  

