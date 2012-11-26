arh: arh.e
 ex arh.e -o arh

clean:
 rm -f arh

install: arh
 install arh /bin

package: arh
 mkdir -p bin
 install arh bin
 cat arh.package > PACKAGE
 ./arh c arh.pkg PACKAGE bin
 rm -r PACKAGE bin