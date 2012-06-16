#!/bin/sh

install libpkg.0.so /lib
echo '#=libpkg.0.so' > /lib/libpkg.so
chmod +x /lib/libpkg.so
install pkg.eh /inc
