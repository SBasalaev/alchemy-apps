use "pkgfile.eh"
use "pkg_private.eh"
use "cfgreader.eh"
use "dataio.eh"
use "bufferio.eh"
use "list.eh"

def pkgExtractSpec(file: String): Package {
  var input = fread(file)
  input.readUTF()
  input.skip(8)
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

def pkgInstallFile(name: String, file: String) {
  // read existing file list
  var listName = PKG_FILELIST_DIR + name + ".files"
  var oldFileList = new List()
  if (exists(listName)) {
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
}

def pkgRemovePackage(name: String): Bool {
  // reading file list
  var filelistFile = PKG_FILELIST_DIR + name + ".files"
  if (!exists(filelistFile)) return false
  var input = fread(filelistFile)
  var buf = input.readFully()
  input.close()
  var list = ba2utf(buf).split('\n', true)
  // removing files
  for (var i = list.len-1, i>=0, i-=1) {
    var file = "/" + list[i]
    if (exists(file) && (!isDir(file) || flist(file).len == 0)) {
      fremove(file)
    }
  }
  // removing database entry
  fremove(filelistFile)
  return true
}
