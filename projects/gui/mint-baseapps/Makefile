ALL=mint-updatedb mint-open
FLAGS=-ldesktop -lmint -g

all: ${ALL}

mint-updatedb: mint-updatedb.e
 ex $< -o $@ ${FLAGS}

mint-open: mint-open.e
 ex $< -o $@ ${FLAGS}

clean:
 rm -f ${ALL}

install:
 install ${ALL} ${DESTDIR}/bin
