#Makefile for make

make: make.e
 ex make.e -o make

clean:
 rm -f make

install: make
 install make /bin

package: make
 mkdir bin
 install make bin
 cp make.package PACKAGE
 arh c make.pkg PACKAGE bin
 rm -r PACKAGE bin