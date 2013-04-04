
all: lines
lines: lines.e temp.e temp.eh
 ex lines.e temp.e -o lines -lui

install: lines
 install lines /bin

pack: lines
 install lines bin
 arh c lines.pkg PACKAGE bin/ res/

clean:
 rm lines

test: lines.pkg
 pkg-arh show lines.pkg
 arh t lines.pkg
