time: time.e
 ex time.e -o time

clean:
 rm -f time

install: time
 install time bin

package: time
 mkdir bin
 install time bin
 cat time.package > PACKAGE
 arh c time.pkg PACKAGE bin
 rm -r PACKAGE bin