fifteen: fifteen.e
 ex fifteen.e -o fifteen -lui

clean:
 rm -f fifteen

install: fifteen
 install fifteen /bin

package: fifteen
 mkdir -p bin res/apps res/icons
 install fifteen bin
 install fifteen.desktop res/apps
 install fifteen.png res/icons
 cp fifteen.package PACKAGE
 arh c fifteen.pkg PACKAGE bin res
 rm -r PACKAGE bin res