/* High-level interface to pkg. */

type PkgManager;
type PkgSpec < Any;

def pkg_init(): PkgManager;
def pkg_refresh(pm: PkgManager);
def pkg_install(pm: PkgManager, names: [String]): Bool;
def pkg_remove(pm: PkgManager, names: [String]);
def pkg_install_seq(pm: PkgManager, names: [String]): [String];
def pkg_arh_unpack(pm: PkgManager, f: String);
def pkg_list_installed(pm: PkgManager): [String];