SOURCES=pkglint.e cfgreader.e checks.e check_spec.e check_dirs.e check_libs.e check_desktop.e check_files.e

pkglint: ${SOURCES}
 ex ${SOURCES} -o pkglint

clean:
 rm -f pkglint

install:
 install pkglint ${DESTDIR}/bin
