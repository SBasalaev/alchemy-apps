BINARIES=msgextract msgfmt

all: ${BINARIES}

msgextract: tokenizer.e msgextract.e
 ex $< -o $@

msgfmt: tokenizer.e msgfmt.e
 ex $< -o $@

clean:
 rm -f ${BINARIES}

install: all
 mkdir -p ${DESTDIR}/bin
 install ${BINARIES} ${DESTDIR}/bin