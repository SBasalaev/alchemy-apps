
all: libexample.1.so libexample.so

libexample.1.so: example.e
 ex example.e -o libexample.1.so -slibexample.1.so

libexample.so:
 echo '#=libexample.1.so' > libexample.so

clean:
 rm -f libexample.1.so libexample.so

install: all
 install libexample.1.so libexample.so ${DESTDIR}/lib
 install example.eh ${DESTDIR}/inc