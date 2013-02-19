fileinfo: fileinfo.e
 ex fileinfo.e -o fileinfo -lui -lfiletype

clean:
 rm -f fileinfo

install: fileinfo
 install fileinfo /bin

package: fileinfo
 mkdir bin
 install fileinfo bin
 cp fileinfo.package PACKAGE
 arh c fileinfo.pkg PACKAGE bin
 rm -r PACKAGE bin