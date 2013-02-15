TARGET=libpkg.1.so
SONAME=${TARGET}

all: ${TARGET} libpkg.so

${TARGET}: pkg_spec.e pkg_list.e pkg_shared.e pkg_installremove.e pkg.e
 ex pkg_spec.e pkg_list.e pkg_shared.e pkg_installremove.e pkg.e -o ${TARGET} -s${SONAME}

libpkg.so:
 echo '#=${TARGET}' > libpkg.so
 chmod +x libpkg.so

install: all
 install ${TARGET} libpkg.so /lib
 install pkg.eh /inc

clean:
 rm -f ${TARGET} libpkg.so

package: all
 mkdir lib
 install ${TARGET} lib
 cat libpkg1.package > PACKAGE
 arh c libpkg1.pkg PACKAGE lib
 rm -r lib
 mkdir lib inc
 install libpkg.so lib
 install pkg.eh inc
 cat libpkg-dev.package > PACKAGE
 arh c libpkg-dev.pkg PACKAGE lib inc
 rm -r PACKAGE lib inc