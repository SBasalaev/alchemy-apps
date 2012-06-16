/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "io.eh"
use "net.eh"
use "string.eh"
use "sys.eh"
use "vector.eh"

def pkg_addr_escape(name: String): String {
  var sb = new_sb()
  for (var i=0, i<strlen(name), i=i+1) {
    var ch = strchr(name, i)
    if ( (ch >= 'a' && ch <= 'z')
      || (ch >= 'A' && ch <= 'Z')
      || (ch >= '0' && ch <= '9')
      || ch == '.' || ch == '-' || ch == '_') {
      sb_addch(sb,  ch)
    } else {
      sb_addch(sb, '#')
      sb_append(sb, ch)
    }
  }
  to_str(sb)
}

def pkg_read_sourcelist(): Array {
  var buf = new BArray(fsize(SOURCELIST))
  var in = fopen_r(SOURCELIST)
  freadarray(in, buf, 0, buf.len)
  fclose(in)
  var lines = strsplit(ba2utf(buf), '\n')
  var v = new_vector()
  for (var i=0, i<lines.len, i=i+1) {
    var line = strtrim(cast(String)lines[i])
    if (strlen(line) > 0 && strchr(line, 0) != '#') {
      if (strindex(line, ':') > 0 && strindex(line, ' ') > strindex(line, ':')) {
        v_add(v, line)
      } else {
        println("[pkg warning]\n Bad source line "+line)
      }
    }
  }
  v_toarray(v)
}

def pkg_init_lists(): Array {
  var sources = pkg_read_sourcelist()
  var lists = new_vector()
  v_add(lists, pkglist_read("installed", ""))
  for (var i=0, i<sources.len, i=i+1) {
    var source = cast (String) sources[i]
    var sp = strindex(source, ' ')
    var url = substr(source, 0, sp)
    var dist = strtrim(substr(source, sp+1, strlen(source)))
    var file = "/cfg/pkg/db/sources/"+pkg_addr_escape(url+dist)
    if (exists(file)) v_add(lists, pkglist_read(url, dist))
  }
  v_toarray(lists)
}

def pkg_copyall(in: IStream, out: OStream) {
  var buf = new BArray(4096)
  var len = freadarray(in, buf, 0, 4096)
  while (len > 0) {
    fwritearray(out, buf, 0, len)
    len = freadarray(in, buf, 0, 4096)
  }
  fflush(out)
}

def _cmp_str(s1: String, s2: String): Int {
  var ofs = 0
  var ret = 0
  var len1 = strlen(s1)
  var len2 = strlen(s2)
  while (ret == 0 && ofs < len1 && ofs < len2) {
    var ch1 = strchr(s1, ofs)
    var ch2 = strchr(s2, ofs)
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
      ret = if (strchr(s1, ofs) == '~') -1 else 1
    } else if (len2 > ofs) {
      ret = if (strchr(s2, ofs) == '~') 1 else -1
    }
  }
  ret
}

def _cmp_num(s1: String, s2: String): Int {
  var l = parsel(s1)-parsel(s2)
  if (l > 0) 1
  else if (l < 0) -1
  else 0
}

def pkg_cmp_versions(v1: String, v2: String): Int {
  var ret = 0
  var ofs1 = 0
  var ofs2 = 0
  var len1 = strlen(v1)
  var len2 = strlen(v2)
  while (ret == 0 && ofs1 < len1 && ofs2 < len2) {
    var end1 = ofs1
    var end2 = ofs2
    /* number parts */
    var ch = strchr(v1, end1)
    while (ch >= '0' && ch <= '9') {
      end1 = end1+1
      ch = if (end1 < len1) strchr(v1, end1) else -1
    }
    ch = strchr(v2, end2)
    while (ch >= '0' && ch <= '9') {
      end2 = end2+1
      ch = if (end2 < len2) strchr(v2, end2) else -1
    }
    ret = _cmp_num(substr(v1, ofs1, end1), substr(v2, ofs2, end2))
    ofs1 = end1
    ofs2 = end2
    /* text parts */
    if (ret == 0) {
      ch = if (ofs1 < len1) strchr(v1, ofs1) else -1
      while (ch > 0 && (ch < '0' || ch > '9')) {
        end1 = end1+1
        ch = if (end1 < len1) strchr(v1, end1) else -1
      }
      ch = if (ofs2 < len2) strchr(v2, ofs2) else -1
      while (ch > 0 && (ch < '0' || ch > '9')) {
        end2 = end2+1
        ch = if (end2 < len2) strchr(v2, end2) else -1
      }
      ret = _cmp_str(substr(v1, ofs1, end1), substr(v2, ofs2, end2))
      ofs1 = end1
      ofs2 = end2
    }
  }
  ret
}

def pkg_read_addr(addr: String): IStream {
  var cl = strindex(addr, ':')
  var protocol = substr(addr, 0, cl)
  var path = substr(addr, cl+1, strlen(addr))
  if (protocol == "http" || protocol == "https") {
    netread(addr)
  } else if (protocol == "file") {
    fopen_r(path)
  } else if (protocol == "res") {
    readresource(path)
  } else {
    println("Unknown source protocol: "+protocol)
    cast (IStream) null
  }
}
