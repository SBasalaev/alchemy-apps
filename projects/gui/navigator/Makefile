navigator: navigator.e
 ex navigator.e -o navigator -lui -lfiletype -ldialog -g

run: navigator
 ./navigator

clean:
 rm -f navigator

install: navigator
 install navigator ${DESTDIR}/bin
 install navigator.desktop ${DESTDIR}/res/apps
 install icons ${DESTDIR}/res/navigator
