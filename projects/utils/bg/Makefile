bg: bg.e
 ex bg.e -o bg

clean:
 rm -f bg

install: bg
 install bg /bin

package: bg
 mkdir bin
 install bg bin
 cat bg.package > PACKAGE
 arh c bg.pkg PACKAGE bin
 rm -r PACKAGE bin