SOURCES=pkglint.e cfgreader.e checks.e check_spec.e check_dirs.e check_libs.e

pkglint: ${SOURCES}
 ex ${SOURCES} -o pkglint -Xtry -Wall

clean:
 rm -f pkglint

install:
 install pkglint /bin

package: pkglint
 mkdir -p bin
 install pkglint bin
 cat pkglint.package > PACKAGE
 arh c pkglint.pkg PACKAGE bin
 rm -r PACKAGE bin