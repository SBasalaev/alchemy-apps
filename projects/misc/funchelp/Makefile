SOURCES=abt.e adm.e cmpr.e funchelp.e open.e rd.e rmitm.e set.e srch.e

all: funchelp

funchelp: ${SOURCES}
 ex funchelp.e -o funchelp -lui

clean:
 rm -f funchelp

install:
 install funchelp /bin

package: all
 mkdir -p bin res/apps res/icons
 install funchelp bin
 install func_help.desktop res/apps
 install srch.png res/icons
 arh c funchelp.pkg PACKAGE bin res
 rm -r bin res