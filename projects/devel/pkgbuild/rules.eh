use "specs"
use "dict"
use "list"

const MODE_BINARY = 'b'
const MODE_CLEAN = 'c'
const MODE_SOURCE = 's'

const BUILD_NONE = 0
const BUILD_MAKE = 1

/* Deletes PKGBUILD directory and cleans project using selected build system. */
def pkgbuild_clean(buildsys: Int): Int;

/* Builds project using selected build system. */
def pkgbuild_build(buildsys: Int): Int;

/* Installs project using selected build system. */
def pkgbuild_install(buildsys: Int, pkgdir: String): Int;

/* Installs project files into binary package directory. */
def pkgbuild_installfiles(pkg: BinaryPackage): Int;

/* Builds index of shared libraries for libdeps target. */
def pkgbuild_libindex(binaries: List): Dict;

/* Scans package for shared libs and adds them to the Shared-Libs field. */
def pkgbuild_makeshlibs(pkg: BinaryPackage): Int;

/* Generates Depends and Conflicts fields of binary package. */
def pkgbuild_gendeps(src: SourcePackage, pkg: BinaryPackage, index: Dict): Int;

/* Generates spec for binary package. */
def pkgbuild_genspec(src: SourcePackage, pkg: BinaryPackage): Int;

/* Assembles binary package. */
def pkgbuild_assemble(src: SourcePackage, pkg: BinaryPackage): Int;

/* Runs pkglint checks on binary package. */
def pkgbuild_pkglint(src: SourcePackage, pkg: BinaryPackage): Int;

/* Creates source archive. */
def pkgbuild_source(src: SourcePackage): Int;
