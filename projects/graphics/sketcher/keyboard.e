/*
 * SKETCHER
 * Keyboard
 */

use "ui"
use "keyboard.eh"

def Keyboard.new() {
  this.keys = new [Byte](256)
  this.menu = false
  this.menu_string = "" }

def Keyboard.read_key() {
  var event = ui_read_event()
  if (event != null) {
    if (event.kind == EV_KEY) {
      this.keys[event.value.cast(Int)+128] = 1 }
    if (event.kind == EV_KEY_HOLD) {
      this.keys[event.value.cast(Int)+128] = 2 }
    else if (event.kind == EV_KEY_RELEASE) {
      this.keys[event.value.cast(Int)+128] = 0 }
    else if (event.kind == EV_MENU) {
      this.menu = true
      this.menu_string = event.value.cast(Menu).text } } }

def Keyboard.pressed_absolute(key: Int): Bool {
  switch (this.keys[key]) {
    2: {
      true }
    0: {
      false }
    1: {
      this.keys[key] = 0
      true } } }
      
def Keyboard.pressed(key: Int, alternative: Int = -1): Bool {
  key += 128
  if (alternative == -1) {
    switch (this.keys[key]) {
      2: {
        true }
      0: {
        false }
      1: {
        this.keys[key] = 0
        true } } }
  else {
    this.pressed_absolute(key) || this.pressed_absolute(key) } }

def Keyboard.menu_pressed(): Bool {
  var result = this.menu
  this.menu = false
  result}
  
def Keyboard.long_pressed(key: Int): Bool {
  if (this.keys[key+128] == 2) true else false }

def Keyboard.release(key: Int) {
  this.keys[key+128] = 0 }