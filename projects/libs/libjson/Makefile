NAME=json
API=1
HEADERS=json.eh
SOURCES=json.e jsonparse.e

LIB=lib${NAME}.${API}.so
LINK=lib${NAME}.so

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB} -llexer -g

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install: all
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc