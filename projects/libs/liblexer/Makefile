NAME=lexer
API=1
SOURCES=lexer.e
HEADERS=lexer.eh

LIB=lib${NAME}.${API}.so
LINK=lib${NAME}.so

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB}

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install:
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc
