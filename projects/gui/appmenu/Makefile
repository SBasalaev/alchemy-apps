appmenu: appmenu.e
 ex appmenu.e -o appmenu -lui

clean:
 rm -f appmenu

install: appmenu
 install appmenu /bin

package: appmenu
 mkdir -p bin
 install appmenu bin
 cat appmenu.package > PACKAGE
 arh c appmenu.pkg PACKAGE bin
 rm -r PACKAGE bin
