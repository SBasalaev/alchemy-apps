
all: pkg pkg-arh

pkg:
 ex pkg.e -o pkg -lpkg.1

pkg-arh:
 ex pkg-arh.e -o pkg-arh -lpkg.1

clean:
 rm pkg.o pkg
 rm pkg-arh.o pkg-arh

install: all
 install pkg /bin
 install pkg-arh /bin