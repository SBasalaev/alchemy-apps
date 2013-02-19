
urlget: urlget.e
 ex urlget.e -o urlget

install: urlget
 install urlget /bin

clean:
 rm -f urlget

package: urlget
 mkdir -p bin
 install urlget bin
 cat urlget.package > PACKAGE
 arh c urlget.pkg PACKAGE bin
 rm -r PACKAGE bin