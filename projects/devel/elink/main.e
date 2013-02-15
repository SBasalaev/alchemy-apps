/* Ether linker written in Ether.
 * Copyright (C) 2013, Sergey Basalaev <sbasalaev@gmail.com>
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
  var i = this.len()-1
  var found = false
  while (!found && i >= 0) {
    var lobj = this[i].cast(Entry)
    if (obj == lobj) {
      found = true
    } else {
      i -= 1
    }
  }
  i
}

def main(args: [String]): Int {
  //parsing arguments
  var outname = "a.out";
  var soname: String = null;
  var infiles = new List();
  var linklibs = new List();
  linklibs.add("libcore.so"); //always link with libcore
  linklibs.add("libcoree.so"); //always link with libcoree
  var wait_outname = false;
  var quit = false;
  var exitcode = SUCCESS;
  for (var i=0, !quit && i < args.len, i += 1) {
    var arg = args[i];
    if (arg == "-h") {
      println(HELP);
      quit = true;
    } else if (arg == "-v") {
      println(VERSION);
      quit = true;
    } else if (arg == "-o") {
      wait_outname = true;
    } else if (arg.len() >= 2 && arg[0] == '-') {
      switch (arg[1]) {
        'l':
          if (arg.indexof('/') < 0) {
            linklibs.add("lib" + arg[2:] + ".so");
          } else {
            linklibs.add(arg[2:]);
          }
        'L':
          setenv("LIBPATH", getenv("LIBPATH")+':'+arg[2:]);
        's':
          soname = arg[2:];
        else: {
          stderr().println("Unknown argument: "+arg);
          quit = true;
          exitcode = FAIL;
        }
      }
    } else if (wait_outname) {
      outname = arg;
      wait_outname = false;
    } else {
      infiles.add(arg);
    }
  }
  if (!quit && infiles.len() == 0) {
    stderr().println("No files to process");
    quit = true;
    exitcode = FAIL;
  }
  if (!quit) try {
    //loading symbols from libraries
    var symbols = new Dict();
    var libinfos = new List();
    for (var li=0, li < linklibs.len(), li+=1) {
      var libname = linklibs[li].tostr();
      var info = loadLibInfo(libname);
      libinfos.add(info);
      for (var si = 0, si < info.symbols.len(), si+=1) {
        symbols[info.symbols[si]] = info;
      }
    }
    //processing objects
    var pool = new List();
    var reloctable = new [Char](128);
    var count = 0;
    for (var fi=0, fi < infiles.len(), fi+=1) {
      var offset = count;
      var infile = infiles[fi].cast(String);
      var data = fopen_r(infile);
      if (data.readushort() != 0xC0DE)
        error(ERR_LINKER, "Not an Ether object: " + infile);
      if (data.readushort() > SUPPORTED)
        error(ERR_LINKER, "Unsupported object format in " + infile);
      var lflags = data.readubyte();
      if (lflags != 0)
        error(ERR_LINKER, "Object is linked already: " + infile);
      var poolsize = data.readushort();
      for (var oi = 0, oi < poolsize, oi += 1) {
        var kind = data.readubyte();
        var obj = switch (kind) {
          E_NULL:
            new NullEntry();
          E_INT:
            new IntEntry(data.readint());
          E_LONG:
            new LongEntry(data.readlong());
          E_FLOAT:
            new FloatEntry(data.readfloat());
          E_DOUBLE:
            new DoubleEntry(data.readdouble());
          E_STRING:
            new StringEntry(data.readutf());
          E_UNDEF:
            new UndefEntry(data.readutf());
          E_PROC: {
            var entry = new ProcEntry(data.readutf());
            entry.flags = data.readubyte();
            entry.stack = data.readubyte();
            entry.locals = data.readubyte();
            entry.code = new [Byte](data.readushort());
            data.readarray(entry.code, 0, entry.code.len);
            entry.relocs = new [Int](data.readushort());
            for (var i=0, i < entry.relocs.len, i+=1) {
              entry.relocs[i] = data.readushort();
            }
            entry.reloffset = offset;
            if ((entry.flags & FFLAG_LNUM) != 0) {
              entry.lnumtable = new [Char](data.readushort());
              for (var j=0, j < entry.lnumtable.len, j+=1) {
                entry.lnumtable[j] = data.readushort();
              }
            }
            if ((entry.flags & FFLAG_ERRTBL) != 0) {
              entry.errtable = new [Char](data.readushort());
              for (var j=0, j < entry.errtable.len, j+=1) {
                entry.errtable[j] = data.readushort();
              }
            }
            entry;
          }
          else: {
            error(ERR_LINKER, "Unknown object type " + kind)
            null
          }
        }
        // putting object in pool
        var objindex = pool.findentry(obj);
        if (obj.kind == E_UNDEF && objindex < 0) {
          objindex = pool.findentry(new ProcEntry(obj.value.tostr()));
        } else if (obj.kind == E_PROC) {
          var f1 = obj.cast(ProcEntry);
          // make sure there is no two public functions with the same name
          if (objindex >= 0) {
            var f2 = pool[objindex].cast(ProcEntry);
            if ((f1.flags & FFLAG_SHARED) != 0 && (f2.flags & FFLAG_SHARED) != 0)
              error(ERR_LINKER, "Multiple definitions of function " + obj.value);
            objindex = -1;
          }
          // if shared, replace undef
          if ((f1.flags & FFLAG_SHARED) != 0) {
            objindex = pool.findentry(new UndefEntry(f1.value.tostr()));
            if (objindex >= 0)
              pool[objindex] = obj;
          }
        }
        if (objindex < 0) {
          objindex = pool.len();
          pool.add(obj);
        }
        // adding relocation index
        if (reloctable.len == count) {
          var newrelocs = new [Char](count << 1);
          acopy(reloctable, 0, newrelocs, 0, count);
          reloctable = newrelocs;
        }
        reloctable[count] = objindex;
        count += 1;
      }
      data.close();
    }
    // linking and relocating
    for (var pi=0, pi < pool.len(), pi+=1) {
      var obj = pool[pi].cast(Entry);
      if (obj.kind == E_UNDEF) {
        var info = symbols[obj.value].cast(LibInfo);
        if (info != null) {
          pool[pi] = new ExternEntry(obj.value.tostr(), info);
          info.used = true;
        } else {
          error(ERR_LINKER, "Function not found: " + obj.value)
        }
      } else if (obj.kind == E_PROC) {
        // relocating code
        var f = obj.cast(ProcEntry);
        for (var ri=f.relocs.len-1, ri >= 0, ri-=1) {
          var r = f.relocs[ri]; // address in code with number to fix
          var oldaddr = ((f.code[r] & 0xff) << 8) | (f.code[r+1] & 0xff);
          var newaddr = reloctable[oldaddr+f.reloffset];
          f.code[r] = newaddr >> 8;
          f.code[r+1] = newaddr;
        }
        // relocating source string
        if (f.lnumtable != null) f.lnumtable[0] = reloctable[f.lnumtable[0] + f.reloffset];
      }
    }
    //indexing libraries, throwing out unused
    var li = 0;
    while (li < libinfos.len()) {
      var info = libinfos[li].cast(LibInfo);
      if (info.used) {
        info.index = li;
        li += 1;
      } else {
        libinfos.remove(li);
      }
    }
    //writing output
    var out = fopen_w(outname);
    out.writeshort(0xC0DE);
    out.writeshort(SUPPORTED);
    if (soname != null) {
      out.writebyte(LFLAG_SONAME | LFLAG_DEPS);
      out.writeutf(soname);
    } else {
      out.writebyte(LFLAG_DEPS);
    }
    out.writeshort(libinfos.len());
    for (var i=0, i < libinfos.len(), i+=1) {
      out.writeutf(libinfos[i].cast(LibInfo).soname);
    }
    out.writeshort(pool.len());
    for (var oi=0, oi < pool.len(), oi+=1) {
      var obj = pool[oi].cast(Entry);
      out.writebyte(obj.kind);
      switch (obj.kind) {
        '0':
          { }
        'i':
          out.writeint(obj.value.cast(Int));
        'l':
          out.writelong(obj.value.cast(Long));
        'f':
          out.writefloat(obj.value.cast(Float));
        'd':
          out.writedouble(obj.value.cast(Double));
        'S':
          out.writeutf(obj.value.cast(String));
        'E': {
          out.writeshort(obj.cast(ExternEntry).info.index)
          out.writeutf(obj.value.cast(String))
        }
        'P': {
          var f = obj.cast(ProcEntry);
          out.writeutf(f.value.cast(String));
          out.writebyte(f.flags & ~FFLAG_RELOCS);
          out.writebyte(f.stack);
          out.writebyte(f.locals);
          out.writeshort(f.code.len);
          out.writearray(f.code, 0, f.code.len);
          if ((f.flags & FFLAG_LNUM) != 0) {
            out.writeshort(f.lnumtable.len);
            for (var j=0, j < f.lnumtable.len, j+=1) {
              out.writeshort(f.lnumtable[j]);
            }
          }
          if ((f.flags & FFLAG_ERRTBL) != 0) {
            out.writeshort(f.errtable.len);
            for (var j=0, j < f.errtable.len, j+=1) {
              out.writeshort(f.errtable[j]);
            }
          }
        }
      }
    }
    out.close();
    set_exec(outname, true);
  } catch (var e) {
    if (e.code() == ERR_LINKER)
      stderr().println("Error: "+e.msg())
    else
      stderr().println(e)
    exitcode = e.code()
  }
  exitcode
}
