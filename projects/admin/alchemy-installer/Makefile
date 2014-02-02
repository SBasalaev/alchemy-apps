SOURCES=main.e dialog.e infoscreens.e
TARGET=alchemy-installer

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -g -lui -lpkg

run: ${TARGET}
 ./${TARGET}

clean:
 rm -f ${TARGET}

install:
 # install base dirs
 mkdir -p ${DESTDIR}/bin
 mkdir -p ${DESTDIR}/cfg
 mkdir -p ${DESTDIR}/dev
 mkdir -p ${DESTDIR}/home
 mkdir -p ${DESTDIR}/lib
 mkdir -p ${DESTDIR}/res
 mkdir -p ${DESTDIR}/tmp
 # install pkg dirs
 mkdir -p ${DESTDIR}/cfg/pkg/db/sources/
 mkdir -p ${DESTDIR}/cfg/pkg/db/lists/
 # installing alchemy-installer
 install ${TARGET} ${DESTDIR}/bin
 echo "/bin/${TARGET}" > ${DESTDIR}/cfg/init
