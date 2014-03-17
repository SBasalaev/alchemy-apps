/* Low-level pkg API. */

use "pkgutil"

/* Extracts package specification from given file. */
def pkgExtractSpec(file: String): Package;

/* Lists files contained in given package file. */
def pkgListContents(file: String): [String];

/* Installs/updates given package file as named package. */
def pkgInstallFile(name: String, file: String);

/* Uninstalls package. */
def pkgRemovePackage(name: String): Bool;