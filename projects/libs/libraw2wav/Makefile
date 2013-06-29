NAME=raw2wav
API_VERSION=0
SOURCES=raw2wav.e
HEADERS=raw2wav.eh

LIBRARY=lib${NAME}.${API_VERSION}.so
LINK=lib${NAME}.so

all: ${LIBRARY} ${LINK}

${LIBRARY}: ${SOURCES}
 ex ${SOURCES} -o ${LIBRARY} -s${LIBRARY}

${LINK}:
 echo '#=${LIBRARY}' > ${LINK}

clean:
 rm -f ${LIBRARY} ${LINK}

install: all
 install ${LIBRARY} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc
