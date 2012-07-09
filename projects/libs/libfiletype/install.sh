#!/bin/sh

mkdir /res/libfiletype/
install filetypes /res/libfiletype/
install filetype.eh /inc/
install libfiletype.0.so /lib/
echo '#=libfiletype.0.so' > /lib/libfiletype.so
chmod +x /lib/libfiletype.so
