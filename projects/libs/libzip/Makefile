SOURCES=ZipEntry.e ZipEntryIStream.e PartialIStream.e ZipArchive.e ZipIStream.e ZipOStream.e
HEADERS=ZipConstants.eh ZipEntry.eh ZipArchive.eh ZipIStream.eh ZipOStream.eh
TARGET=libzip.1.so
SONAME=${TARGET}
LINK=libzip.so

all: ${TARGET} ${LINK}

${TARGET}: ${SOURCES}
 ex $< -o $@ -s${SONAME} -lz

${LINK}:
 echo '#=${TARGET}' > ${LINK}

clean:
 rm -f ${TARGET} ${LINK}

package: all
 # libzip1
 mkdir lib
 install ${TARGET} lib
 cp libzip1.package PACKAGE
 arh c libzip1.pkg PACKAGE lib
 rm -r lib
 # libzip-dev
 mkdir -p lib inc/zip
 install ${LINK} lib
 install ${HEADERS} inc/zip
 cp libzip-dev.package PACKAGE
 arh c libzip-dev.pkg PACKAGE lib inc
 rm -r PACKAGE lib inc