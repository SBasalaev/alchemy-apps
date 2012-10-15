/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "dict.eh"

const SOURCELIST = "/cfg/pkg/sources"

type IStream;
type OStream;

type PkgList {
 url: String,
 dist: String,
 specs: Dict
}

def pkg_addr_escape(name: String): String;
def pkg_read_sourcelist(): Array;
def pkg_init_lists(): Array;
def pkg_copyall(in: IStream, out: OStream);
def pkg_cmp_versions(v1: String, v2: String): Int;
def pkg_read_addr(addr: String): IStream;

type PkgManager {
  lists: [PkgList]
}

type PkgSpec < Any;

def pkgspec_parse(text: String): PkgSpec;
def PkgSpec.get(key: String): String;
def PkgSpec.set(key: String, value: String);
def PkgSpec.write(out: OStream);

def PkgList.get(name: String): PkgSpec;
def PkgList.put(spec: PkgSpec);
def PkgList.remove(package: String);
def pkglist_read(addr: String, distr: String): PkgList;
def PkgList.write();

def pkg_arh_extract_spec(file: String): PkgSpec;

def pkg_query(pm: PkgManager, name: String, version: String): PkgSpec;
def pkg_query_installed(pm: PkgManager, name: String): PkgSpec;
def pkg_list_installed(pm: PkgManager): Array;
