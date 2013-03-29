
all: ${TARGET}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} ${CFLAGS} ${LFLAGS}

run: all
 ./${TARGET} ${CMDARGS}

clean:
 rm -f ${TARGET}

install: all
 mkdir -p ${DESTDIR}/bin
 install ${TARGET} ${DESTDIR}/bin