TARGET=pkgbuild
SOURCES=cfgreader.e pkgbuild.e main.e

all: ${TARGET}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -g

clean:
 rm ${TARGET}

install: all
 mkdir -p ${DESTDIR}/bin
 install ${TARGET} ${DESTDIR}/bin