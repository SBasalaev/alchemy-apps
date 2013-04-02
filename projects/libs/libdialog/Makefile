SOURCES=dialog.e colorchooser.e dirchooser.e filechooser.e
HEADERS=dialog.eh
TARGET=libdialog.1.so
LINK=libdialog.so
SONAME=${TARGET}

all: ${TARGET} ${LINK}

${LINK}:
 echo '#=${TARGET}' > ${LINK}

${TARGET}: ${SOURCES} ${HEADERS}
 ex ${SOURCES} -o ${TARGET} -s${SONAME} -Wall -lui

install: all
 mkdir -p ${DESTDIR}/lib ${DESTDIR}/inc/dialog
 install ${TARGET} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc/dialog

clean:
 rm -f ${TARGET} ${LINK}

package: all
 # libdialog1
 mkdir -p lib
 install ${TARGET} lib
 cp libdialog1.package PACKAGE
 arh c libdialog1.pkg PACKAGE lib
 rm -r lib PACKAGE
 # libdialog-dev
 mkdir -p lib inc
 install ${LINK} lib
 install ${HEADERS} inc
 cp libdialog-dev.package PACKAGE
 arh c libdialog-dev.pkg PACKAGE lib inc
 rm -r lib inc PACKAGE