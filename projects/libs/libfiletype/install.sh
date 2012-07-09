#!/bin/sh

mkdir /res/libfiletype1/
install filetypes /res/libfiletype1/
install filetype.eh /inc/
install libfiletype.1.so /lib/
echo '#=libfiletype.1.so' > /lib/libfiletype.so
chmod +x /lib/libfiletype.so
