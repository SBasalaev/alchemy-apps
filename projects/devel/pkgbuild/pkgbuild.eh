use "specs.eh"
use "dict.eh"

const MODE_BINARY = 'b'
const MODE_CLEAN = 'c'
const MODE_SOURCE = 's'

def pkgbuild_clean(buildsys: String): Int;
def pkgbuild_build(buildsys: String): Int;
def pkgbuild_install(buildsys: String, pkgdir: String): Int;
def pkgbuild_installfiles(pkg: Binary): Int;
def pkgbuild_genspec(src: Source, pkg: Binary): Int;
def pkgbuild_assemble(src: Source, pkg: Binary): Int;
def pkgbuild_pkglint(src: Source, pkg: Binary): Int;
def pkgbuild_libindex(binaries: List): Dict;
def pkgbuild_libdeps(pkg: Binary, index: Dict): Int;
def pkgbuild_source(src: Source): Int;
