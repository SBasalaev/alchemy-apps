SOURCES=main.e dialog.e infoscreens.e
TARGET=alchemy-installer

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -g -lui -lpkg

run: ${TARGET}
 ./${TARGET}

clean:
 rm -f ${TARGET}

install:
 install ${TARGET} ${DESTDIR}/bin