# Makefile for pkgbuild
# Added by Sergey Basalaev

TARGET=miditrax
SOURCES=easy_menu.e mod_editor.e mod_file.e mod_renderer.e module.e pattern_editor.e tracker.e

${TARGET}: ${SOURCES}
 ex ${SOURCES} -o ${TARGET} -lui -lmedia -ldialog -lmidifile

clean:
 rm -f ${TARGET}

install: ${TARGET}
 install ${TARGET} ${DESTDIR}/bin
 install res ${DESTDIR}/