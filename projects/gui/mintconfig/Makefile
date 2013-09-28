mintconfig: mintconfig.e
 ex mintconfig.e -o mintconfig -lui -lmint -g

run: mintconfig
 ./mintconfig

clean:
 rm -f mintconfig

install: mintconfig
 install mintconfig ${DESTDIR}/bin
 install mintconfig.desktop ${DESTDIR}/res/apps/