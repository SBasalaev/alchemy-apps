//# Kyle Alexander Buan
//# Magic 8-Ball in Python
//# August 8, 2012
//Ether port: Kyle Alexander Buan
//November 13, 2012

use "rnd"
use "ui"
use "form"
use "io"
use "list"

def evnt(): UIEvent {
  var event: UIEvent;
  var got_it = false;
  while (!got_it) {
    event = ui_wait_event();
    if (event.kind == EV_MENU) got_it = true;
  }
  event;
}

def main(args: [String]) {
  var answers = ["It is certain.", "It is decidedly so.", "Without a doubt.", "Yes - definitely.", "You may rely on it.", "As I see it, yes.", "Most likely.", "Outlook good.", "Yes.", "Signs point to yes.", "Reply hazy, try again.", "Ask again later.", "Better not tell you now.", "Cannot predict now.", "Concentrate and ask again.", "Don't count on it.", "My reply is no.", "My sources say no.", "Outlook not so good.", "Very doubtful."];
  var ans = answers[rnd(19)];
  if (args.len == 0) println(ans);
  else {
    var f = new_form();
    f.set_title("8ball");
    f.add(new_textitem("8ball says...", ans));
    f.add_menu(new_menu("Okay", 0));
    f.add_menu(new_menu("About...", 1));
    ui_set_screen(f);
    var ev = evnt();
    if ((cast(Menu)ev.value).get_text() == "About...") {
      var a = new_form();
      a.add(new_textitem("About 8ball:", "August 8, 2012. Kyle Alexander Buan. Ether/Alchemy port (from Python/Python for Symbian) by Kyle Alexander Buan, November 13, 2012."));
      a.add_menu(new_menu("Okay", 0));
      ui_set_screen(a);
      ev = evnt();
    }
  }
}