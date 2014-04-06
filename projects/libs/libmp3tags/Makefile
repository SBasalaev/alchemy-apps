NAME=mp3tags
API=1

LIB=lib${NAME}.${API}.so
LINK=lib${NAME}.so

SOURCES=main.e
HEADERS=inc/mp3tags.eh

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB} -g -Wall

${LINK}:
 echo '#=${LIB}' > ${LINK}
 chmod +x ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install:
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc
