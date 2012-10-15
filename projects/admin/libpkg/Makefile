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
 rm ${TARGET} libpkg.so pkg.o pkg_installremove.o pkg_list.o pkg_shared.o pkg_spec.o