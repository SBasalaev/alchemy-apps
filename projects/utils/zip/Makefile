
all: zip unzip

zip: zip.e
 ex $< -o $@ -lzip

unzip: unzip.e
 ex $< -o $@ -lzip

install: all
 install zip unzip ${DESTDIR}/bin

clean:
 rm zip unzip

package: all
 # zip package
 mkdir bin
 install zip bin
 cp zip.package PACKAGE
 arh c zip.pkg PACKAGE bin
 rm -r bin PACKAGE
 # unzip package
 mkdir bin
 install unzip bin
 cp unzip.package PACKAGE
 arh c unzip.pkg PACKAGE bin
 rm -r bin PACKAGE