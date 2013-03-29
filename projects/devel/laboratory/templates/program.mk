
all: ${TARGET}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} ${CFLAGS} ${LFLAGS}

run: all
 ./${TARGET} ${CMDARGS}

clean:
 rm -f ${TARGET}

package: all
 mkdir -p bin
 install ${TARGET} bin
 arh c ${TARGET}.pkg PACKAGE bin
 rm -r bin