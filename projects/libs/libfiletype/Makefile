TARGET=libfiletype.1.so

all: ${TARGET} libfiletype.so

${TARGET}: filetype.e
 ex filetype.e -o ${TARGET} -s${TARGET}

libfiletype.so:
 echo '#=${TARGET}' > libfiletype.so
 chmod +x libfiletype.so

clean:
 rm -f ${TARGET} libfiletype.so

install: all
 install ${TARGET} libfiletype.so /lib
 install filetype.eh /inc
 install filetypes /res/libfiletype1

package: all
 # package libfiletype1
 mkdir -p lib res/libfiletype1
 install ${TARGET} lib
 install filetypes res/libfiletype1
 cat libfiletype1.package > PACKAGE
 arh c libfiletype1.pkg PACKAGE lib res
 rm -r lib res
 # package libfiletype-dev
 mkdir -p lib inc
 install libfiletype.so lib
 install filetype.eh inc
 cat libfiletype-dev.package > PACKAGE
 arh c libfiletype-dev.pkg PACKAGE lib inc
 rm -r PACKAGE lib inc