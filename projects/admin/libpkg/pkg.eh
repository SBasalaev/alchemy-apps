/* High-level interface to pkg. */

type PkgManager;
type PkgSpec < Any;

/* Reads database and creates package manager. */
def pkg_init(): PkgManager;

/* Refreshes source lists. */
def pkg_refresh(pm: PkgManager);

/* Installs most recent versions of packages with dependencies. */
def pkg_install(pm: PkgManager, names: Array): Bool;

/* Removes packages if nothing depends on them. */
def pkg_remove(pm: PkgManager, names: Array);

/* Returns spec for given version of package. If version is null
 * then most recent version of package is returned.
 */
def pkg_query(pm: PkgManager, name: String, version: String): PkgSpec;

/* Returns spec for installed version of package. */
def pkg_query_installed(pm: PkgManager, name: String): PkgSpec;

/* Returns names of all installed packages. */
def pkg_list_installed(pm: PkgManager): Array;

/* Returns names of all available packages. */
def pkg_list_all(pm: PkgManager): Array;

/* Reads specified key from the spec. */
def PkgSpec.get(key: String): String;

/* Extracts spec from package archive. */
def pkg_arh_extract_spec(file: String): PkgSpec;

/* Installs package archive with dependencies. */
def pkg_arh_install(pm: PkgManager, file: String): Bool;
