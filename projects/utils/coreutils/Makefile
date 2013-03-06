ALL=cat chmod cp date echo env install ls mkdir mv rm touch

all: ${ALL}

cat: cat.e
 ex cat.e -o cat

chmod: chmod.e
 ex chmod.e -o chmod

cp: cp.e
 ex cp.e -o cp

date: date.e
 ex date.e -o date

echo: echo.e
 ex echo.e -o echo

env: env.e
 ex env.e -o env

install: install.e
 ex install.e -o install

ls: ls.e
 ex ls.e -o ls

mkdir: mkdir.e
 ex mkdir.e -o mkdir

mv: mv.e
 ex mv.e -o mv

rm: rm.e
 ex rm.e -o rm

touch: touch.e
 ex touch.e -o touch

clean-all: rm
 ./rm -f ${ALL}

install-all: all
 ./install ${ALL} /bin

package: all
 ./mkdir -p bin
 ./install ${ALL} ./bin
 ./cat coreutils.package > PACKAGE
 arh c coreutils.pkg PACKAGE bin
 ./rm -r PACKAGE bin