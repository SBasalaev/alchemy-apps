
imgview: imgview.e
 ex imgview.e -o imgview -lui

clean:
 rm -f imgview

package: imgview
 mkdir bin
 install imgview bin
 cp imgview.package PACKAGE
 arh c imgview.pkg PACKAGE bin
 rm -r PACKAGE bin