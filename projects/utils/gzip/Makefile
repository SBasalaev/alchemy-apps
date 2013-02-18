all: gzip gunzip zcat

gzip: gzip.e
 ex gzip.e -o gzip -lz -Wall

gunzip: gunzip.e
 ex gunzip.e -o gunzip -Wall

zcat: zcat.e
 ex zcat.e -o zcat -Wall

clean:
 rm -f gzip gunzip zcat

install: all
 install gzip gunzip zcat /bin

package: all
 mkdir -p bin
 install gzip gunzip zcat bin
 cat gzip.package > PACKAGE
 arh c gzip.pkg PACKAGE bin
 rm -r PACKAGE bin
