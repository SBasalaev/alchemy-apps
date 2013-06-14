ALL=cat chmod cp date echo env install ls mkdir mv rm touch

all: bin/cat bin/chmod bin/cp bin/date bin/echo bin/env bin/install bin/ls bin/mkdir bin/mv bin/rm bin/touch

bin:
 mkdir -p bin

bin/cat: bin cat.e
 ex cat.e -o bin/cat

bin/chmod: bin chmod.e
 ex chmod.e -o bin/chmod

bin/cp: bin cp.e
 ex cp.e -o bin/cp

bin/date: bin date.e
 ex date.e -o bin/date

bin/echo: bin echo.e
 ex echo.e -o bin/echo

bin/env: bin env.e
 ex env.e -o bin/env

bin/install: bin install.e
 ex install.e -o bin/install

bin/ls: bin ls.e
 ex ls.e -o bin/ls

bin/mkdir: bin mkdir.e
 ex mkdir.e -o bin/mkdir

bin/mv: bin mv.e
 ex mv.e -o bin/mv

bin/rm: bin rm.e
 ex rm.e -o bin/rm

bin/touch: bin touch.e
 ex touch.e -o bin/touch

clean: bin/rm
 bin/rm -rf bin

install: all
 bin/install bin ${DESTDIR}
