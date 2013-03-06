use "etypes.eh"

def Entry.new(kind: Int, value: Any) {
  this.kind = kind
  this.value = value
}

def Entry.eq(other: Entry): Bool {
  if (other == null) {
    false
  } else {
    this.kind == other.kind && this.value == other.value
  }
}

def NullEntry.new() {
  super(E_NULL, null)
}

def IntEntry.new(i: Int) {
  super(E_INT, i)
}

def LongEntry.new(l: Long) {
  super(E_LONG, l)
}

def FloatEntry.new(f: Float) {
  super(E_FLOAT, f)
}

def DoubleEntry.new(d: Double) {
  super(E_DOUBLE, d)
}

def StringEntry.new(str: String) {
  super(E_STRING, str)
}

def UndefEntry.new(symbol: String) {
  super(E_UNDEF, symbol)
}

def ExternEntry.new(symbol: String, info: LibInfo) {
  super(E_EXTERN, symbol)
  this.info = info
}

def ProcEntry.new(symbol: String) {
  super(E_PROC, symbol)
}
