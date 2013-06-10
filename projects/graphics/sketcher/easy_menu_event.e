/* Easy routine to listen for menu events */

use "ui.eh"

def wait_menu(): String {
  var not_found = true
  var event: UIEvent
  do {
    event = ui_wait_event() }
  while (event.kind != EV_MENU)
  event.value.cast(Menu).text }