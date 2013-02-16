base64: base64.e
 ex base64.e -o base64

clean:
 rm -f base64

install: base64
 install base64 /bin

package: base64
 mkdir bin
 install base64 bin
 cat base64.package > PACKAGE
 arh c base64.pkg PACKAGE bin
 rm -r PACKAGE bin