use "libsyms.eh"

const E_NULL = '0'
const E_INT  = 'i'
const E_LONG = 'l'
const E_FLOAT = 'f'
const E_DOUBLE = 'd'
const E_STRING = 'S'
const E_UNDEF = 'U'
const E_EXTERN = 'E'
const E_PROC = 'P'

type Entry {
  kind: Int,
  value: Any
}

def Entry.eq(other: Entry): Bool;

type NullEntry < Entry { }
type IntEntry < Entry { }
type LongEntry < Entry { }
type FloatEntry < Entry { }
type DoubleEntry < Entry { }
type StringEntry < Entry { }
type UndefEntry < Entry { }

type ExternEntry < Entry {
  info: LibInfo
}

type ProcEntry < Entry {
 stack: Int,
 locals: Int,
 flags: Int,
 code: [Byte],
 relocs: [Int],
 reloffset: Int,
 lnumtable: [Char],
 errtable: [Char]
}

def NullEntry.new(): NullEntry;
def IntEntry.new(i: Int): IntEntry;
def LongEntry.new(l: Long): LongEntry;
def FloatEntry.new(f: Float): FloatEntry;
def DoubleEntry.new(d: Double): DoubleEntry;
def StringEntry.new(str: String): StringEntry;
def UndefEntry.new(symbol: String): UndefEntry;
def ExternEntry.new(symbol: String, info: LibInfo): ExternEntry;
def ProcEntry.new(symbol: String): ProcEntry;
