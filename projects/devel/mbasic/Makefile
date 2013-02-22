SOURCES=basicvm.e parser.e tokenizer.e exprtree.e cmdlist.e stdfuncs.e

all: mbasic libmb.0.so libmb.so mbmodules

mbmodules: libmb.0.so
 make -C modules

mbasic: main.e libmb.0.so
 ex main.e -o mbasic -Wall -lmb.0 -L.

libmb.0.so: ${SOURCES}
 ex ${SOURCES} -o libmb.0.so -slibmb.0.so -Xtry -Wall

libmb.so:
 echo '#=libmb.0.so' > libmb.so

run: all
 env LIBPATH=/lib:. ./mbasic

clean:
 rm -f mbasic libmb.0.so libmb.so
 make -C modules clean

package: all
 # mbasic
 mkdir -p bin lib/mbasic
 install mbasic bin
 install modules/ui.so lib/mbasic
 cat mbasic.package > PACKAGE
 arh c mbasic.pkg PACKAGE bin lib
 rm -r bin lib
 # libmb0
 mkdir -p lib
 install libmb.0.so lib
 cat libmb0.package > PACKAGE
 arh c libmb.pkg PACKAGE lib
 rm -r lib
 # libmb-dev
 mkdir -p lib inc
 install libmb.so lib
 install mbasic.eh inc
 cat libmb-dev.package > PACKAGE
 arh c libmb-dev.pkg PACKAGE lib inc
 rm -r PACKAGE lib inc