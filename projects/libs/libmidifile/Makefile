# Makefile for package building
# Added by Sergey Basalaev

LIB=libmidifile.0.so
LINK=libmidifile.so
SOURCES=midifile.e
HEADERS=midifile.eh

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB}

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install: all
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc
