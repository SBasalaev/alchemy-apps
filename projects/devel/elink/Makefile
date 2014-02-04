SOURCES=libsyms.e etypes.e main.e

all: elink

elink: ${SOURCES}
 ex ${SOURCES} -o elink

clean:
 rm -f elink

install: all
 install elink ${DESTDIR}/bin
