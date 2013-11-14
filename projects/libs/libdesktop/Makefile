NAME=desktop
API=1
SOURCES=desktop.e
HEADERS=desktop.eh

LIB=lib${NAME}.${API}.so
LINK=lib${NAME}.so

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB} -g

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install:
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc
 install filetypes ${DESTDIR}/res
