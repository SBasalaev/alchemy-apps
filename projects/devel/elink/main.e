/* Ether linker written in Ether.
 * Copyright (C) 2013-2014, Sergey Basalaev <sbasalaev@gmail.com>
 * Licensed under GPL v3
 */

use "libsyms.eh"
use "etypes.eh"
use "dataio.eh"
use "error.eh"
use "string.eh"
use "sys.eh"
use "dict.eh"

def List.findentry(obj: Entry): Int {
  for (var i = 0, i < this.len(), i += 1) {
    var lobj = this[i].cast(Entry)
    // operator == is overriden
    if (obj == lobj) return i
  }
  return -1
}

def main(args: [String]): Int {
  //parsing arguments
  var outname = "a.out"
  var soname: String = null
  var infiles = new List()
  var linklibs = new List()
  linklibs.add("libcoree.so") //always link with libcoree
  linklibs.add("libcore.so")  //always link with libcore
  var wait_outname = false
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-o") {
      wait_outname = true
    } else if (arg.len() >= 2 && arg[0] == '-') {
      switch (arg[1]) {
        'l':
          if (arg.indexof('/') < 0) {
            linklibs.add("lib" + arg[2:] + ".so")
          } else {
            linklibs.add(arg[2:])
          }
        'L':
          setenv("LIBPATH", arg[2:]+':'+getenv("LIBPATH"))
        's':
          soname = arg[2:]
        else: {
          stderr().println("Unknown argument: "+arg)
          return FAIL
        }
      }
    } else if (wait_outname) {
      outname = arg
      wait_outname = false
    } else {
      infiles.add(arg)
    }
  }
  if (infiles.len() == 0) {
    stderr().println("No files to process")
    return FAIL
  }
  try {
    //loading symbols from libraries
    var symbols = new Dict()
    var libinfos = new List()
    for (var li=0, li < linklibs.len(), li+=1) {
      var libname = linklibs[li].tostr()
      var info = loadLibInfo(libname)
      libinfos.add(info)
      for (var si in 0 .. info.symbols.len()-1) {
        symbols[info.symbols[si]] = info
      }
    }
    //processing objects
    var pool = new List()
    var reloctable = new [Char](128)
    var count = 0
    for (var fi in 0 .. infiles.len()-1) {
      var offset = count
      var infile = infiles[fi].cast(String)
      var data = fread(infile)
      if (data.readUShort() != 0xC0DE)
        throw(ERR_LINKER, "Not an Ether object: " + infile)
      if (data.readUShort() > SUPPORTED)
        throw(ERR_LINKER, "Unsupported object format in " + infile)
      var lflags = data.readUByte()
      if (lflags != 0)
        throw(ERR_LINKER, "Object is linked already: " + infile)
      var poolsize = data.readUShort()
      for (var oi in 0 .. poolsize-1) {
        var kind = data.readUByte()
        var obj: Entry
        switch (kind) {
          E_NULL:
            obj = new NullEntry()
          E_INT:
            obj = new IntEntry(data.readInt())
          E_LONG:
            obj = new LongEntry(data.readLong())
          E_FLOAT:
            obj = new FloatEntry(data.readFloat())
          E_DOUBLE:
            obj = new DoubleEntry(data.readDouble())
          E_STRING:
            obj = new StringEntry(data.readUTF())
          E_UNDEF:
            obj = new UndefEntry(data.readUTF())
          E_PROC: {
            var entry = new ProcEntry(data.readUTF())
            entry.flags = data.readUByte()
            entry.stack = data.readUByte()
            entry.locals = data.readUByte()
            entry.code = new [Byte](data.readUShort())
            data.readArray(entry.code)
            entry.relocs = new [Int](data.readUShort())
            for (var i in 0 .. entry.relocs.len-1) {
              entry.relocs[i] = data.readUShort()
            }
            entry.reloffset = offset;
            if ((entry.flags & FFLAG_LNUM) != 0) {
              entry.lnumtable = new [Char](data.readUShort())
              for (var j in 0 .. entry.lnumtable.len-1) {
                entry.lnumtable[j] = data.readUShort()
              }
            }
            if ((entry.flags & FFLAG_ERRTBL) != 0) {
              entry.errtable = new [Char](data.readUShort())
              for (var j in 0 .. entry.errtable.len-1) {
                entry.errtable[j] = data.readUShort()
              }
            }
            obj = entry
          }
          else: {
            throw(ERR_LINKER, "Unknown object type " + kind)
          }
        }
        // putting object in pool
        var objindex = pool.findentry(obj)
        if (obj.kind == E_UNDEF && objindex < 0) {
          objindex = pool.findentry(new ProcEntry(obj.value.tostr()))
        } else if (obj.kind == E_PROC) {
          var f1 = obj.cast(ProcEntry)
          // make sure there is no two public functions with the same name
          if (objindex >= 0) {
            var f2 = pool[objindex].cast(ProcEntry)
            if ((f1.flags & FFLAG_SHARED) != 0 && (f2.flags & FFLAG_SHARED) != 0)
              throw(ERR_LINKER, "Multiple definitions of function " + obj.value)
            objindex = -1
          }
          // if shared, replace undef
          if ((f1.flags & FFLAG_SHARED) != 0) {
            objindex = pool.findentry(new UndefEntry(f1.value.tostr()))
            if (objindex >= 0)
              pool[objindex] = obj
          }
        }
        if (objindex < 0) {
          objindex = pool.len()
          pool.add(obj)
        }
        // adding relocation index
        if (reloctable.len == count) {
          var newrelocs = new [Char](count << 1)
          acopy(reloctable, 0, newrelocs, 0, count)
          reloctable = newrelocs
        }
        reloctable[count] = objindex
        count += 1
      }
      data.close()
    }
    // linking and relocating
    for (var pi in 0 .. pool.len()-1) {
      var obj = pool[pi].cast(Entry)
      if (obj.kind == E_UNDEF) {
        var info = symbols[obj.value].cast(LibInfo)
        if (info != null) {
          pool[pi] = new ExternEntry(obj.value.tostr(), info)
          info.used = true
        } else {
          throw(ERR_LINKER, "Function not found: " + obj.value)
        }
      } else if (obj.kind == E_PROC) {
        // relocating code
        var f = obj.cast(ProcEntry)
        for (var ri in 0 .. f.relocs.len-1) {
          var r = f.relocs[ri]; // address in code with number to fix
          var oldaddr = ((f.code[r] & 0xff) << 8) | (f.code[r+1] & 0xff)
          var newaddr = reloctable[oldaddr+f.reloffset]
          f.code[r] = newaddr >> 8
          f.code[r+1] = newaddr
        }
        // relocating source string
        if (f.lnumtable != null)
        f.lnumtable[0] = reloctable[f.lnumtable[0] + f.reloffset]
      }
    }
    //indexing libraries, throwing out unused
    var li = 0
    while (li < libinfos.len()) {
      var info = libinfos[li].cast(LibInfo)
      if (info.used) {
        info.index = li
        li += 1
      } else {
        libinfos.remove(li)
      }
    }
    //writing output
    var out = fwrite(outname)
    out.writeShort(0xC0DE)
    out.writeShort(SUPPORTED)
    if (soname != null) {
      out.writeByte(LFLAG_SONAME | LFLAG_DEPS)
      out.writeUTF(soname)
    } else {
      out.writeByte(LFLAG_DEPS)
    }
    out.writeShort(libinfos.len())
    for (var i=0, i < libinfos.len(), i+=1) {
      out.writeUTF(libinfos[i].cast(LibInfo).soname)
    }
    out.writeShort(pool.len())
    for (var oi=0, oi < pool.len(), oi+=1) {
      var obj = pool[oi].cast(Entry)
      out.writeByte(obj.kind)
      switch (obj.kind) {
        '0':
          { }
        'i':
          out.writeInt(obj.value.cast(Int))
        'l':
          out.writeLong(obj.value.cast(Long))
        'f':
          out.writeFloat(obj.value.cast(Float))
        'd':
          out.writeDouble(obj.value.cast(Double))
        'S':
          out.writeUTF(obj.value.cast(String))
        'E': {
          out.writeShort(obj.cast(ExternEntry).info.index)
          out.writeUTF(obj.value.cast(String))
        }
        'P': {
          var f = obj.cast(ProcEntry)
          out.writeUTF(f.value.cast(String))
          out.writeByte(f.flags & ~FFLAG_RELOCS)
          out.writeByte(f.stack)
          out.writeByte(f.locals)
          out.writeShort(f.code.len)
          out.writeArray(f.code, 0, f.code.len)
          if ((f.flags & FFLAG_LNUM) != 0) {
            out.writeShort(f.lnumtable.len)
            for (var j=0, j < f.lnumtable.len, j+=1) {
              out.writeShort(f.lnumtable[j])
            }
          }
          if ((f.flags & FFLAG_ERRTBL) != 0) {
            out.writeShort(f.errtable.len)
            for (var j=0, j < f.errtable.len, j+=1) {
              out.writeShort(f.errtable[j])
            }
          }
        }
      }
    }
    out.close()
    setExec(outname, true)
    return SUCCESS
  } catch (var e) {
    if (e.code() == ERR_LINKER)
      stderr().println("Error: "+e.msg())
    else
      stderr().println(e)
    return e.code()
  }
}
