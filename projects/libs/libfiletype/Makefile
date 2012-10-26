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