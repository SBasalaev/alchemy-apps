/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "hash.eh"

const SOURCELIST = "/cfg/pkg/sources"

type IStream;
type OStream;

def pkg_addr_escape(name: String): String;
def pkg_read_sourcelist(): Array;
def pkg_init_lists(): Array;
def pkg_copyall(in: IStream, out: OStream);
def pkg_cmp_versions(v1: String, v2: String): Int;
def pkg_read_addr(addr: String): IStream;

type PkgManager {
  lists: Array
}

type PkgSpec;

def pkgspec_parse(text: String): PkgSpec;
def pkgspec_get(spec: PkgSpec, key: String): String;
def pkgspec_set(spec: PkgSpec, key: String, value: String);
def pkgspec_write(spec: PkgSpec, out: OStream);

type PkgList {
 url: String,
 dist: String,
 specs: Hashtable
}

def pkglist_get(list: PkgList, name: String): PkgSpec;
def pkglist_put(list: PkgList, spec: PkgSpec);
def pkglist_remove(list: PkgList, package: String);
def pkglist_read(addr: String, distr: String): PkgList;
def pkglist_write(list: PkgList);

def pkg_arh_extract_spec(file: String): PkgSpec;

def pkg_query(pm: PkgManager, name: String, version: String): PkgSpec;
def pkg_query_installed(pm: PkgManager, name: String): PkgSpec;
def pkg_list_installed(pm: PkgManager): Array;
