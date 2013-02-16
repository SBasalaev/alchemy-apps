hello: hello.e
 ex hello.e -o hello

clean:
 rm hello

install: hello
 install hello /bin

package: hello
 mkdir bin
 install hello bin
 cat hello.package > PACKAGE
 arh c hello.pkg PACKAGE bin
 rm -r PACKAGE bin