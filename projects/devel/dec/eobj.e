/* Ether decompiler.
 * Copyright (c) 2012 Sergey Basalaev
 * Licensed under GPL-3
 */

use "eobj.eh"
use "dataio.eh"
use "opcodes.eh"

def read_eobj(inp: IStream): EObj {
 var obj = new EObj{};
  if (inp.readUShort() != 0xC0DE) {
    throw(ERR_IO, "Not an Ether object");
  }
  obj.vmversion = inp.readUShort();
  if (obj.vmversion > MAX_VMVERSION || obj.vmversion < MIN_VMVERSION) {
    throw(ERR_IO, "Unsupported VM version");
  }
  obj.lflags = inp.readUByte();
  if ((obj.lflags & LFLAG_SONAME) != 0) {
    obj.soname = inp.readUTF();
  }
  if ((obj.lflags & LFLAG_DEPS) != 0) {
    obj.libs = new [String](inp.readUShort());
    for (var i=0, i < obj.libs.len, i+=1) {
      obj.libs[i] = inp.readUTF();
    }
  }
  obj.cpool = new [PoolItem](inp.readUShort());
  for (var i=0, i<obj.cpool.len, i+=1) {
    var t = inp.readUByte();
    switch (t) {
      T_NULL:
        obj.cpool[i] = new PoolItem(t, null);
      T_INT:
        obj.cpool[i] = new PoolItem(t, inp.readInt());
      T_FLOAT:
        obj.cpool[i] = new PoolItem(t, inp.readFloat());
      T_LONG:
        obj.cpool[i] = new PoolItem(t, inp.readLong());
      T_DOUBLE:
        obj.cpool[i] = new PoolItem(t, inp.readDouble());
      T_STRING:
        obj.cpool[i] = new PoolItem(t, inp.readUTF());
      T_UNRESOLVED:
        obj.cpool[i] = new PoolItem(t, new Unresolved(inp.readUTF()));
      T_EXTERNAL:
        obj.cpool[i] = new PoolItem(t, new External(inp.readUShort(), inp.readUTF()));
      T_FUNCTION: {
        var f = new EFunction {};
        f.name = inp.readUTF();
        f.flags = inp.readUByte();
        f.stacksize = inp.readUByte();
        f.varcount = inp.readUByte();
        f.code = new [Byte](inp.readUShort());
        inp.readArray(f.code, 0, f.code.len);
        if ((f.flags & FFLAG_RELOCS) != 0) {
          f.relocations = new [Char](inp.readUShort());
          for (var j=0, j < f.relocations.len, j+=1) {
            f.relocations[j] = inp.readUShort();
          }
        }
        if ((f.flags & FFLAG_LNUM) != 0) {
          f.lnumtable = new [Char](inp.readUShort());
          for (var j=0, j<f.lnumtable.len, j+=1) {
            f.lnumtable[j] = inp.readUShort();
          }
        }
        if ((f.flags & FFLAG_ERRTBL) != 0) {
          f.errtable = new [Char](inp.readUShort());
          for (var j=0, j<f.errtable.len, j+=1) {
            f.errtable[j] = inp.readUShort();
          }
        }
        obj.cpool[i] = new PoolItem(t, f);
      }
      else:
        throw(ERR_IO, "Unknown object type: "+t);
    }
  }
  return obj;
}
