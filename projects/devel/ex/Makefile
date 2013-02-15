
ex: ex.o
 el ex.o -o ex

ex.o: ex.e
 ec ex.e -o ex.o

clean:
 rm -f ex.o ex

install: ex
 install ex /bin

package: ex
 mkdir -p bin
 install ex bin
 cat ex.package > PACKAGE
 arh c ex.pkg PACKAGE bin
 rm -r PACKAGE bin