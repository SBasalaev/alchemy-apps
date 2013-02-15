
all: pkg pkg-arh

pkg:
 ex pkg.e -o pkg -lpkg.1

pkg-arh:
 ex pkg-arh.e -o pkg-arh -lpkg.1

clean:
 rm -f pkg pkg-arh

install: all
 install pkg /bin
 install pkg-arh /bin

package: all
 mkdir bin
 install pkg bin
 cat pkg.package > PACKAGE
 arh c pkg.pkg PACKAGE bin
 rm bin/pkg
 install pkg-arh bin
 cat pkg-arh.package > PACKAGE
 arh c pkg-arh.pkg PACKAGE bin
 rm -r PACKAGE bin