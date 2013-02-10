
all: lines
lines: lines.e
 ex lines.e -o lines -lui

install: lines
 install lines /bin

pack: lines
 install lines bin
 arh c lines.pkg PACKAGE bin/

clean:
 rm lines

test: lines.pkg
 pkg-arh show lines.pkg
 arh t lines.pkg
