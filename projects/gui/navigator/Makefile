ICONS=audio.png up.png lib.png dir.png text.png image.png unknown.png exec.png video.png web.png archive.png

navigator: navigator.e
 ex navigator.e -o navigator -lui -lfiletype

clean:
 rm -f navigator

install: navigator
 install navigator /bin
 install navigator.desktop /res/apps
 install ${ICONS} /res/navigator/

package: navigator
 mkdir -p bin res/apps res/navigator
 install navigator bin/
 install navigator.desktop res/apps/
 install ${ICONS} res/navigator/
 cat navigator.package > PACKAGE
 arh c navigator.pkg PACKAGE bin res
 rm -r PACKAGE bin res
