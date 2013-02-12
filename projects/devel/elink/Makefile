SOURCES=libsyms.e etypes.e main.e

all: elink

elink: ${SOURCES}
 ex ${SOURCES} -o elink

clean:
 rm -f elink

install: all
 install elink /bin

package: all
 mkdir -p bin
 install elink bin
 arh c elink.pkg PACKAGE bin
 rm -r bin