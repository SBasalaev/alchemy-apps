
all: zip unzip

zip: zip.e
 ex $< -o $@ -lzip -g

unzip: unzip.e
 ex $< -o $@ -lzip -g

install: all
 install zip unzip ${DESTDIR}/bin

clean:
 rm -f zip unzip
