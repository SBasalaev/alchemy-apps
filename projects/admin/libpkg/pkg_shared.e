/* Pkg library.
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "io.eh"
use "strbuf.eh"
use "string.eh"
use "sys.eh"
use "list.eh"

def pkg_addr_escape(name: String): String {
  var sb = new StrBuf()
  for (var i=0, i<name.len(), i+=1) {
    var ch = name[i]
    if ( (ch >= 'a' && ch <= 'z')
      || (ch >= 'A' && ch <= 'Z')
      || (ch >= '0' && ch <= '9')
      || ch == '.' || ch == '-' || ch == '_') {
      sb.addch(ch)
    } else {
      sb.addch('_')
    }
  }
  sb.tostr()
}

def pkg_read_sourcelist(): [String] {
  var in = fopen_r(SOURCELIST)
  var buf = in.readfully()
  in.close()
  var lines = ba2utf(buf).split('\n')
  var v = new List()
  for (var i=0, i<lines.len, i+=1) {
    var line = lines[i].trim()
    if (line.len() > 0 && line.ch(0) != '#') {
      if (line.indexof(':') > 0 && line.indexof(' ') > line.indexof(':')) {
        v.add(line)
      } else {
        println("[pkg warning]\n Bad source line "+line)
      }
    }
  }
  var sources = new [String](v.len())
  v.copyinto(0, sources, 0, sources.len)
  sources
}

def pkg_init_lists(): [PkgList] {
  var sources = pkg_read_sourcelist()
  var lists = new List()
  lists.add(pkglist_read("installed", ""))
  for (var i=0, i<sources.len, i+=1) {
    var source = sources[i]
    var sp = source.indexof(' ')
    var url = source[:sp]
    var dist = source[sp+1:].trim()
    var file = "/cfg/pkg/db/sources/"+pkg_addr_escape(url+dist)
    if (exists(file)) lists.add(pkglist_read(url, dist))
  }
  var ret = new [PkgList](lists.len())
  lists.copyinto(0, ret, 0, ret.len)
  ret
}

def _cmp_str(s1: String, s2: String): Int {
  var ofs = 0
  var ret = 0
  var len1 = s1.len()
  var len2 = s2.len()
  while (ret == 0 && ofs < len1 && ofs < len2) {
    var ch1 = s1.ch(ofs)
    var ch2 = s2.ch(ofs)
    if (ch1 != ch2) {
      if (ch1 == '~') ret = -1
      else if (ch2 == '~') ret = 1
      else if (ch1 < ch2) ret = -1
      else ret = 1
    }
    ofs = ofs+1
  }
  if (ret == 0) {
    if (len1 > ofs) {
      ret = if (s1.ch(ofs) == '~') -1 else 1
    } else if (len2 > ofs) {
      ret = if (s2.ch(ofs) == '~') 1 else -1
    }
  }
  ret
}

def _cmp_num(s1: String, s2: String): Int {
  var l = s1.tolong()-s2.tolong()
  if (l > 0) 1
  else if (l < 0) -1
  else 0
}

def pkg_cmp_versions(v1: String, v2: String): Int {
  var ret = 0
  var ofs1 = 0
  var ofs2 = 0
  var len1 = v1.len()
  var len2 = v2.len()
  while (ret == 0 && ofs1 < len1 && ofs2 < len2) {
    var end1 = ofs1
    var end2 = ofs2
    /* number parts */
    var ch = v1.ch(end1)
    while (ch >= '0' && ch <= '9') {
      end1 = end1+1
      ch = if (end1 < len1) v1.ch(end1) else -1
    }
    ch = v2.ch(end2)
    while (ch >= '0' && ch <= '9') {
      end2 = end2+1
      ch = if (end2 < len2) v2.ch(end2) else -1
    }
    ret = _cmp_num(v1.substr(ofs1, end1), v2.substr(ofs2, end2))
    ofs1 = end1
    ofs2 = end2
    /* text parts */
    if (ret == 0) {
      ch = if (ofs1 < len1) v1.ch(ofs1) else -1
      while (ch > 0 && (ch < '0' || ch > '9')) {
        end1 = end1+1
        ch = if (end1 < len1) v1.ch(end1) else -1
      }
      ch = if (ofs2 < len2) v2.ch(ofs2) else -1
      while (ch > 0 && (ch < '0' || ch > '9')) {
        end2 = end2+1
        ch = if (end2 < len2) v2.ch(end2) else -1
      }
      ret = _cmp_str(v1.substr(ofs1, end1), v2.substr(ofs2, end2))
      ofs1 = end1
      ofs2 = end2
    }
  }
  ret
}
