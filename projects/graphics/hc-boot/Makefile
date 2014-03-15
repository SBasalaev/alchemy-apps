include project.lab


all: ${TARGET}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} ${CFLAGS} ${LFLAGS}
 ex install.e -o hcbinstall
 chmod +x ${TARGET}
 chmod +x hcbinstall

run: all
 ./${TARGET} ${CMDARGS}

clean:
 rm -f ${TARGET}
 rm -f hcbinstall

install: all
 #mkdir -p ${DESTDIR}/bin
 install ${TARGET} ${DESTDIR}/bin
 install hcbinstall ${DESTDIR}/bin
 mkdir -p ${DESTDIR}/res/hc-boot
 install logo.png ${DESTDIR}/res/hc-boot