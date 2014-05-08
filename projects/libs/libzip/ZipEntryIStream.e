use "ZipEntryImpl.eh"

def ZipEntryIStream.read(): Int {
  if (this.infin != null)
    return this.infin.read()
  else
    return this.pin.read()
}

def ZipEntryIStream.readArray(b: [Byte], off: Int, len: Int): Int {
  if (this.infin != null)
    return this.infin.readArray(b, off, len)
  else
    return this.pin.readArray(b, off, len)
}

def ZipEntryIStream.skip(n: Long): Long {
  if (this.infin != null)
    return this.infin.skip(n)
  else
    return this.pin.skip(n)
}

def ZipEntryIStream.close() {
  if (this.infin != null) this.infin.close()
}
