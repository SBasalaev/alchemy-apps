TARGET=libz.2.so
LINK=libz.so
SONAME=${TARGET}
SOURCES=adler32.e crc32.e deflater.e deflaterconstants.e deflaterengine.e deflaterhuffman.e deflaterstream.e gzistream.e gzostream.e inflater.e inflaterdynheader.e inflaterhuffmantree.e inflaterstream.e maxmin.e outputwindow.e pendingbuffer.e streammanipulator.e
HEADERS=adler32.eh crc32.eh deflater.eh deflaterstream.eh gzistream.eh gzostream.eh inflater.eh inflaterstream.eh

all: ${TARGET} ${LINK}

${LINK}:
 echo '#=${TARGET}' > ${LINK}

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -s${SONAME} -Wall

clean:
 rm -f ${TARGET} ${LINK}

install: all
 install ${TARGET} ${LINK} /lib
 mkdir -p /inc/zlib
 install ${HEADERS} /inc/zlib
 
package: all
 mkdir -p lib
 install ${TARGET} lib
 cat libz2.package > PACKAGE
 arh c libz2.pkg PACKAGE lib
 rm -r lib
 mkdir -p lib inc/zlib
 install ${LINK} lib
 install ${HEADERS} inc/zlib
 cat zlib-dev.package > PACKAGE
 arh c zlib-dev.pkg PACKAGE lib inc
 rm -r PACKAGE lib inc
