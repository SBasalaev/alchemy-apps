use "etypes.eh"

def Entry.eq(other: Entry): Bool {
  if (other == null) {
    false
  } else {
    this.kind == other.kind && this.value == other.value
  }
}

def NullEntry.new(): NullEntry {
  new NullEntry {
    kind = E_NULL
  }
}

def IntEntry.new(i: Int): IntEntry {
  new IntEntry {
    kind = E_INT,
    value = i
  }
}

def LongEntry.new(l: Long): LongEntry {
  new LongEntry {
    kind = E_LONG,
    value = l
  }
}

def FloatEntry.new(f: Float): FloatEntry {
  new FloatEntry {
    kind = E_FLOAT,
    value = f
  }
}

def DoubleEntry.new(d: Double): DoubleEntry {
  new DoubleEntry {
    kind = E_DOUBLE,
    value = d
  }
}

def StringEntry.new(str: String): StringEntry {
  new StringEntry {
    kind = E_STRING,
    value = str
  }
}

def UndefEntry.new(symbol: String): UndefEntry {
  new UndefEntry {
    kind = E_UNDEF,
    value = symbol
  }
}

def ExternEntry.new(symbol: String, info: LibInfo): ExternEntry {
  new ExternEntry {
    kind = E_EXTERN,
    value = symbol,
    info = info
  }
}

def ProcEntry.new(symbol: String): ProcEntry {
  new ProcEntry {
    kind = E_PROC,
    value = symbol
  }
}
