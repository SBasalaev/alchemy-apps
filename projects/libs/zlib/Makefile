TARGET=libz.3.so
LINK=libz.so
SONAME=${TARGET}
SOURCES=adler32.e crc32.e deflater.e deflaterconstants.e deflaterengine.e deflaterhuffman.e deflaterstream.e gzistream.e gzostream.e inflater.e inflaterdynheader.e inflaterhuffmantree.e inflaterstream.e maxmin.e outputwindow.e pendingbuffer.e streammanipulator.e
HEADERS=adler32.eh crc32.eh deflater.eh deflaterstream.eh gzistream.eh gzostream.eh inflater.eh inflaterstream.eh

all: ${TARGET} ${LINK}

${LINK}:
 echo '#=${TARGET}' > ${LINK}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -s${SONAME} -Wall -g

clean:
 rm -f ${TARGET} ${LINK}

install: all
 install ${TARGET} ${LINK} ${DESTDIR}/lib
 install ${HEADERS} ${DESTDIR}/inc/zlib
