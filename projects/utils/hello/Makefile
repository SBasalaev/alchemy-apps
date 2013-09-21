all: hello translations

hello: hello.e
 ex hello.e -o hello -g

makeloc: makeloc.e
 ex makeloc.e -o makeloc -g

translations: makeloc
 ./makeloc

clean: makeloc
 ./makeloc clean
 rm -f hello makeloc

install: all
 install hello ${DESTDIR}/bin
 env DESTDIR=${DESTDIR} ./makeloc install