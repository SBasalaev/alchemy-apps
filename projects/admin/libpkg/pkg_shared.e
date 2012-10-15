/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "io.eh"
use "strbuf.eh"
use "string.eh"
use "sys.eh"
use "list.eh"

def pkg_addr_escape(name: String): String {
  var sb = new_strbuf()
  for (var i=0, i<name.len(), i=i+1) {
    var ch = name.ch(i)
    if ( (ch >= 'a' && ch <= 'z')
      || (ch >= 'A' && ch <= 'Z')
      || (ch >= '0' && ch <= '9')
      || ch == '.' || ch == '-' || ch == '_') {
      sb.addch(ch)
    } else {
      sb.addch('#')
      sb.append(ch)
    }
  }
  sb.tostr()
}

def pkg_read_sourcelist(): Array {
  var buf = new BArray(fsize(SOURCELIST))
  var in = fopen_r(SOURCELIST)
  in.readarray(buf, 0, buf.len)
  in.close()
  var lines = ba2utf(buf).split('\n')
  var v = new_list()
  for (var i=0, i<lines.len, i=i+1) {
    var line = lines[i].trim()
    if (line.len() > 0 && line.ch(0) != '#') {
      if (line.indexof(':') > 0 && line.indexof(' ') > line.indexof(':')) {
        v.add(line)
      } else {
        println("[pkg warning]\n Bad source line "+line)
      }
    }
  }
  v.toarray()
}

def pkg_init_lists(): Array {
  var sources = pkg_read_sourcelist()
  var lists = new_list()
  lists.add(pkglist_read("installed", ""))
  for (var i=0, i<sources.len, i=i+1) {
    var source = cast (String) sources[i]
    var sp = source.indexof(' ')
    var url = source.substr(0, sp)
    var dist = source.substr(sp+1, source.len()).trim()
    var file = "/cfg/pkg/db/sources/"+pkg_addr_escape(url+dist)
    if (exists(file)) lists.add(pkglist_read(url, dist))
  }
  lists.toarray()
}

def pkg_copyall(in: IStream, out: OStream) {
  var buf = new BArray(4096)
  var len = in.readarray(buf, 0, 4096)
  while (len > 0) {
    out.writearray(buf, 0, len)
    len = in.readarray(buf, 0, 4096)
  }
  out.flush()
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

def pkg_read_addr(addr: String): IStream = readurl(addr)
