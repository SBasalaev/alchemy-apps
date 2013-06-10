/*
 * SKETCHER
 * Keyboard
 */

use "ui"

type Keyboard {
  keys: [Byte],
  menu: Bool,
  menu_string: String }

def Keyboard.new();
def Keyboard.read_key();
def Keyboard.pressed(key: Int, alternative: Int = -1): Bool;
def Keyboard.menu_pressed(): Bool;
def Keyboard.release(key: Int);
def Keyboard.long_pressed(key: Int): Bool;