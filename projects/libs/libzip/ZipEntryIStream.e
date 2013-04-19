use "ZipEntryImpl.eh"

def ZipEntryIStream.read(): Int {
  if (this.infin != null) this.infin.read()
  else this.pin.read()
}

def ZipEntryIStream.readarray(b: [Byte], off: Int, len: Int): Int {
  if (this.infin != null) this.infin.readarray(b, off, len)
  else this.pin.readarray(b, off, len)
}

def ZipEntryIStream.skip(n: Long): Long {
  if (this.infin != null) this.infin.skip(n)
  else this.pin.skip(n)
}

def ZipEntryIStream.close() {
  if (this.infin != null) this.infin.close()
}
