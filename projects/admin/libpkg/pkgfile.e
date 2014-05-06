use "pkgfile.eh"
use "pkg_private.eh"
use "cfgreader.eh"
use "dataio.eh"
use "bufferio.eh"
use "list.eh"
use "sys.eh"

def pkgExtractSpec(file: String): Package {
  var input = fread(file)
  input.readUTF()
  input.skip(9)
  var buf = new [Byte](input.readInt())
  input.readArray(buf)
  input.close()
  var cfg = new CfgReader(utfreader(new BufferIStream(buf)), file)
  var dict = cfg.nextSection()
  cfg.close()
  return new Package(dict)
}

def pkgListContents(file: String): [String] {
  var input = fread(file)
  // skipping PACKAGE entry
  input.readUTF()
  input.skip(9)
  input.skip(input.readInt())
  // reading file names
  var names = new List()
  while (var f = try input.readUTF() catch null, f != null) {
    input.skip(8)
    var attrs = input.readUByte()
    if ((attrs & 16) != 0) {
      if (!f.endsWith("/")) f = f + "/"
      names.add(f)
    } else {
      names.add(f)
      input.skip(input.readInt())
    }
  }
  input.close()
  var ret = new [String](names.len())
  names.copyInto(0, ret)
  return ret
}

//attribute flags
const A_DIR = 16
const A_READ = 4
const A_WRITE = 2
const A_EXEC = 1

const BUF_SIZE = 1024

def pkgInstallFile(pkg: Package, file: String) {
  // read existing file list
  var listName = PKG_FILELIST_DIR + pkg.name + ".files"
  var oldFileList = new List()
  var update = false
  if (exists(listName)) {
    update = true
    var r = utfreader(fread(listName))
    while (var line = r.readLine(), line != null) {
      oldFileList.add(line)
    }
    r.close()
  }
  // skip package entry
  var input = fread(file)
  input.readUTF()
  input.skip(9)
  input.skip(input.readInt())
  // install package files
  var newFileList = new List()
  var buf = new [Byte](BUF_SIZE)
  while (var f = try input.readUTF() catch null, f != null) {
    newFileList.add(f)
    var idx = oldFileList.indexof(f)
    if (idx >= 0) oldFileList.remove(idx)
    f = "/" + f
    input.skip(8)
    var attrs = input.readUByte()
    if ((attrs & A_DIR) != 0) {
      if (!exists(f)) mkdir(f)
    } else {
      var output = fwrite(f)
      var len = input.readInt()
      while (len > 0) {
          var n = input.readArray(buf, 0, if (len < BUF_SIZE) len else BUF_SIZE)
          output.writeArray(buf, 0, n)
          len -= n
      }
      output.flush()
      output.close()
    }
    setExec(f, (attrs & A_EXEC) != 0)
  }
  input.close()
  // remove old files
  for (var i=oldFileList.len()-1, i >= 0, i -= 1) {
    var oldfile = "/" + oldFileList[i]
    fremove(oldfile)
  }
  // write new filelist
  var output = fwrite(listName)
  for (var i in 0 .. newFileList.len()-1) {
    output.println(newFileList[i])
  }
  output.flush()
  output.close()
  // install scripts if defined
  if (pkg.sharedLibs != null) {
    var out = fwrite(PKG_FILELIST_DIR + pkg.name + ".shlibs")
    out.println(pkg.sharedLibs.trim())
    out.close()
  }
  if (pkg.onInstall != null) {
    var out = fwrite(PKG_FILELIST_DIR + pkg.name + ".install")
    out.print(pkg.onInstall.trim())
    out.close()
  }
  if (pkg.onUpdate != null) {
    var out = fwrite(PKG_FILELIST_DIR + pkg.name + ".update")
    out.print(pkg.onUpdate.trim())
    out.close()
  }
  if (pkg.onRemove != null) {
    var out = fwrite(PKG_FILELIST_DIR + pkg.name + ".remove")
    out.print(pkg.onRemove.trim())
    out.close()
  }
  // call on-install or on-update
  if (update) {
    var script = PKG_FILELIST_DIR + pkg.name + ".update"
    if (exists(script)) {
      if (execWait(script, []) != SUCCESS) throw(FAIL, "On-Update action failed")
    }
  } else {
    var script = PKG_FILELIST_DIR + pkg.name + ".install"
    if (exists(script)) {
      if (execWait(script, []) != SUCCESS) throw(FAIL, "On-Install action failed")
    }
  }
}

def pkgRemovePackage(name: String) {
  // calling on-remove
  var onremoveFile = PKG_FILELIST_DIR + ".remove"
  if (exists(onremoveFile)) {
    if (execWait(onremoveFile, []) != 0) throw(FAIL, "On-Remove action failed")
  }
  // removing files read from filelist
  var filelistFile = PKG_FILELIST_DIR + name + ".files"
  if (exists(filelistFile)) {
    var input = fread(filelistFile)
    var buf = input.readFully()
    input.close()
    var list = ba2utf(buf).split('\n', true)
    for (var i = list.len-1, i>=0, i-=1) {
      var file = "/" + list[i]
      if (exists(file) && (!isDir(file) || flist(file).len == 0)) {
        fremove(file)
      }
    }
  }
  // removing database entries
  for (var ext in [".files", ".shlibs", ".install", ".update", ".remove"]) {
    var file = PKG_FILELIST_DIR + name + ext
    if (exists(file)) fremove(file)
  }
}
