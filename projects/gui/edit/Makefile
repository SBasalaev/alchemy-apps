edit: edit.e
 ex edit.e -o edit -lui

clean:
 rm -f edit

install: edit
 install edit /bin

package: edit
 mkdir bin
 install edit bin
 cp edit.package PACKAGE
 arh c edit.pkg PACKAGE bin
 rm -r PACKAGE bin