NAME=pkg
VERSION=2
SOURCES=cfgreader.e pkg_common.e pkg_install.e pkg_refresh.e pkg_remove.e pkgfile.e pkgutil.e
HEADERS=cfgreader.eh pkg.eh pkgfile.eh pkgutil.eh

LIB=lib${NAME}.${VERSION}.so
LINK=lib${NAME}.so

all: ${LIB} ${LINK}

${LIB}: ${SOURCES}
 ex ${SOURCES} -o ${LIB} -s${LIB} -g

${LINK}:
 echo '#=${LIB}' > ${LINK}

clean:
 rm -f ${LIB} ${LINK}

install:
 install ${LIB} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc/pkg
