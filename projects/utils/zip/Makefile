
all: zip unzip

zip: zip.e
 ex zip.e -o zip -lzip -g

unzip: unzip.e
 ex unzip.e -o unzip -lzip -g

install: all
 install zip unzip ${DESTDIR}/bin

clean:
 rm -f zip unzip
