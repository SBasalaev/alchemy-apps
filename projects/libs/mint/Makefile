NAME=mint
SOVERSION=1
SOURCES=config.e themeicon.e dialog.e fontdialog.e colordialog.e filedialogs.e eventloop.e actionlist.e
HEADERS=config.eh themeicon.eh dialog.eh eventloop.eh actionlist.eh

LIB=lib${NAME}.${SOVERSION}.so
LINK=lib${NAME}.so

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex $< -o $@ -s$@ -lui -g

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install: all
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc/mint