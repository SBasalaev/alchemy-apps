This is libmidifile0.
Author: Kyle Alexander Buan
Date submitted: August 22, 2013
Contact: tar.shoduze@gmail.com

libmidifile is a library (duh...) for writing MIDI files. After you create a MIDI variable, you may add "MIDI events" using easy-to-use functions, then save the variable to a file.
Actually, I plan to add MIDI file reading functions, but it will be added to libmidifile1.

So far, I just want to warn you: NEVER use the text-writing events. Any event that includes a String parameter. NEVER. It will produce an invalid file.

So, there. Have fun.