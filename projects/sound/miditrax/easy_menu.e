// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Easy usage of Menus
 **/

use "ui.eh"
 
def wait_menu(): String {
    var e: UIEvent
    do {
        e = ui_wait_event() }
    while (e.kind != EV_MENU)
    e.value.cast(Menu).text }
    
def wait_menu_or_press(): [Any] {
    var result = new [Any](2)
    var e: UIEvent
    do {
        e = ui_wait_event() }
    while ((e.kind != EV_MENU) && (e.kind != EV_KEY))
    if (e.kind == EV_MENU) {
        result[0] = 0
        result[1] = e.value.cast(Menu).text }
    else {
        result[0] = 1
        result[1] = e.value }
    result }