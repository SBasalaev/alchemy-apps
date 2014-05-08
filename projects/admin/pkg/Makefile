
pkg: pkg.e
 ex pkg.e -o pkg -g -lpkg

run: pkg
 ./pkg ${CMDARGS}

clean:
 rm -f pkg

install:
 install pkg ${DESTDIR}/bin
