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

install: all
 install ${TARGET} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc/zip
