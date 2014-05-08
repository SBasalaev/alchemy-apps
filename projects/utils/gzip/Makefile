BUILDFLAGS=-lz -Wall -g

all: gzip gunzip zcat

gzip: gzip.e
 ex gzip.e -o gzip ${BUILDFLAGS}

gunzip: gunzip.e
 ex gunzip.e -o gunzip ${BUILDFLAGS}

zcat: zcat.e
 ex zcat.e -o zcat ${BUILDFLAGS}

clean:
 rm -f gzip gunzip zcat

install: all
 install gzip gunzip zcat ${DESTDIR}/bin
