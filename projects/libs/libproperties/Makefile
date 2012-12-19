libs:
 ex -g -Xtry -slibproperties.1.so -o lib/libproperties.1.so properties.e
 echo '#=libproperties.1.so' > lib/libproperties.so

test:
 ex -g -Xtry -lproperties -lreader -o propread propread.e

run: properties
 ./propread

install:
 install lib/ /
 install inc/ /

pack:
 arh c libproperties-0.84.pkg package inc lib