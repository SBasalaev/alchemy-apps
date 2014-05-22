TARGET=pkgbuild
SOURCES=specs.e rules.e main.e
LINKFLAGS=-lpkg -g

all: ${TARGET}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} ${LINKFLAGS}

clean:
 rm ${TARGET}

install: all
 install ${TARGET} ${DESTDIR}/bin
