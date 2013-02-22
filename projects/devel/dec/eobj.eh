
const MAX_VMVERSION = 0x0201
const MIN_VMVERSION = 0x0200

const T_NULL = '0'
const T_INT = 'i'
const T_FLOAT = 'f'
const T_LONG = 'l'
const T_DOUBLE = 'd'
const T_STRING = 'S'
const T_UNRESOLVED = 'U'
const T_EXTERNAL = 'E'
const T_FUNCTION = 'P'

type PoolItem {
  t: Int,
  value: Any
}

type Unresolved {
  name: String
}

type External {
  libref: Int,
  name: String
}

type EFunction {
 flags: Int,
 name: String,
 stacksize: Int,
 varcount: Int,
 code: [Byte],
 relocations: [Char],
 lnumtable: [Char],
 errtable: [Char]
}

type EObj {
 vmversion: Int,
 lflags: Int,
 soname: String,
 libs: [String],
 cpool: [PoolItem]
}

type IStream;
def read_eobj(in: IStream): EObj;