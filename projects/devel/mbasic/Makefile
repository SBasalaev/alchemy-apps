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

install:
 mkdir -p ${DESTDIR}/lib/mbasic ${DESTDIR}/bin ${DESTDIR}/inc
 install mbasic ${DESTDIR}/bin
 install modules/ui.so ${DESTDIR}/lib/mbasic
 install libmb.0.so libmb.so ${DESTDIR}/lib
 install mbasic.eh ${DESTDIR}/inc
