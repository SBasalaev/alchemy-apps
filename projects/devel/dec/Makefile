SOURCES=eobj.e dec.e

dec: ${SOURCES}
 ex ${SOURCES} -o dec

clean:
 rm -f dec

install: dec
 install dec /bin

package: dec
 mkdir -p bin
 install dec bin
 cat dec.package > PACKAGE
 arh c dec.pkg PACKAGE bin
 rm -r PACKAGE bin