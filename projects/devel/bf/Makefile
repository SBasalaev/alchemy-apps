bf: bf.e
 ex bf.e -o bf

clean:
 rm bf

install: bf
 install bf /bin

package: bf
 mkdir bin
 install bf bin
 cp bf.package PACKAGE
 arh c bf.pkg PACKAGE bin
 rm -r PACKAGE bin