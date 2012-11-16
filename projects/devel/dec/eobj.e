use "eobj.eh"
use "dataio.eh"
use "error.eh"
use "opcodes.eh"

def read_eobj(in: IStream): EObj {
 var obj = new EObj{};
  if (in.readushort() != 0xC0DE) {
    error(ERR_IO, "Not an Ether object");
  }
  obj.vmversion = in.readushort();
  if (obj.vmversion > MAX_VMVERSION || obj.vmversion < MIN_VMVERSION) {
    error(ERR_IO, "Unsupported VM version");
  }
  obj.lflags = in.readubyte();
  if ((obj.lflags & LFLAG_SONAME) != 0) {
    obj.soname = in.readutf();
  }
  if ((obj.lflags & LFLAG_DEPS) != 0) {
    obj.libs = new [String](in.readushort());
    for (var i=0, i < obj.libs.len, i+=1) {
      obj.libs[i] = in.readutf();
    }
  }
  obj.cpool = new [PoolItem](in.readushort());
  for (var i=0, i<obj.cpool.len, i+=1) {
    var t = in.readubyte();
    switch (t) {
      T_NULL:
        obj.cpool[i] = new PoolItem(t, null);
      T_INT:
        obj.cpool[i] = new PoolItem(t, in.readint());
      T_FLOAT:
        obj.cpool[i] = new PoolItem(t, in.readfloat());
      T_LONG:
        obj.cpool[i] = new PoolItem(t, in.readlong());
      T_DOUBLE:
        obj.cpool[i] = new PoolItem(t, in.readdouble());
      T_STRING:
        obj.cpool[i] = new PoolItem(t, in.readutf());
      T_UNRESOLVED:
        obj.cpool[i] = new PoolItem(t, new Unresolved(in.readutf()));
      T_EXTERNAL:
        obj.cpool[i] = new PoolItem(t, new External(in.readushort(), in.readutf()));
      T_FUNCTION: {
        var f = new EFunction {};
        f.name = in.readutf();
        f.flags = in.readubyte();
        f.stacksize = in.readubyte();
        f.varcount = in.readubyte();
        f.code = new BArray(in.readushort());
        in.readarray(f.code, 0, f.code.len);
        if ((f.flags & FFLAG_RELOCS) != 0) {
          f.relocations = new CArray(in.readushort());
          for (var j=0, j < f.relocations.len, j+=1) {
            f.relocations[j] = in.readushort();
          }
        }
        if ((f.flags & FFLAG_LNUM) != 0) {
          f.lnumtable = new CArray(in.readushort());
          for (var j=0, j<f.lnumtable.len, j+=1) {
            f.lnumtable[j] = in.readushort();
          }
        }
        if ((f.flags & FFLAG_ERRTBL) != 0) {
          f.errtable = new CArray(in.readushort());
          for (var j=0, j<f.errtable.len, j+=1) {
            f.errtable[j] = in.readushort();
          }
        }
        obj.cpool[i] = new PoolItem(t, f);
      }
      else:
        error(ERR_IO, "Unknown object type: "+t);
    }
  }
  obj;
}
