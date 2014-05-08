use "PartialIStream.eh"

type PartialIStream {
  buf: [Byte],
  count: Int,
  pos: Int,
  mark: Int,
  dummyByteCount: Int = 0
}

def PartialIStream.new(buf: [Byte], offset: Int, len: Int) {
  this.buf = buf
  this.pos = offset
  this.count = if (offset + len < buf.len) offset + len else buf.len
  this.mark = offset
}

def PartialIStream.available(): Int {
  return this.count - this.pos + this.dummyByteCount
}

def PartialIStream.setLength(length: Int) {
  this.count = this.pos + length
  if (this.count > this.buf.len)
    this.count = this.buf.len
}

def PartialIStream.read(): Int {
  if (this.pos == this.count) {
    if (this.dummyByteCount > 0) {
      this.dummyByteCount = 0
      this.pos += 1
      return 0
    } else {
      return -1
    }
  } else {
    var pos = this.pos
    this.pos = pos + 1
    return this.buf[pos] & 0xff
  }
}

def PartialIStream.readArray(b: [Byte], off: Int, len: Int): Int {
  if (b == null) {
    throw(ERR_NULL)
  } else if ((off < 0) || (off > b.len) || (len < 0) || ((off + len) > b.len) || ((off + len) < 0)) {
    throw(ERR_RANGE)
  }

  var numBytes = len
  if (this.pos >= this.count) {
    numBytes = -1
  } else {
    if (this.pos + len > this.count) {
      numBytes = this.count - this.pos
    }
    if (numBytes > 0) {
      acopy(this.buf, this.pos, b, off, numBytes)
      this.pos += numBytes
    }
  }

  if (this.dummyByteCount > 0 && numBytes < len) {
    this.dummyByteCount = 0
    if (this.pos < this.count) {
      b[off + numBytes] = this.buf[this.pos]
      numBytes += 1
      this.pos += 1
    } else {
      if (numBytes == -1)
        numBytes = 1
      b[off] = 0
      this.pos += 1
    }
  }

  return numBytes
}

def PartialIStream.skip(n: Int): Int {
  if (this.pos + n > this.count) {
    n = this.count - this.pos
  }
  if (n < 0) {
    return 0
  } else {
    this.pos += n
    return n
  }
}

def PartialIStream.seek(newpos: Int) {
  this.pos = newpos
}

def PartialIStream.readFully(buf: [Byte], off: Int = 0, len: Int = -1) {
  if (len < 0) len = buf.len
  if (this.readArray(buf, off, len) != len)
    throw(ERR_IO, "End of stream")
}

def PartialIStream.readLeShort(): Int {
  var b0 = this.read()
  var b1 = this.read()
  if (b1 == -1)
    throw(ERR_IO, "End of stream")
  return (b0 & 0xff) | (b1 & 0xff) << 8
}

def PartialIStream.readLeInt(): Int {
  var b0 = this.read()
  var b1 = this.read()
  var b2 = this.read()
  var b3 = this.read()
  if (b3 == -1)
    throw(ERR_IO, "End of stream")
  return ((b0 & 0xff) | (b1 & 0xff) << 8) | ((b2 & 0xff) | (b3 & 0xff) << 8) << 16
}

def PartialIStream.readString(length: Int): String {
  if (length > this.count - this.pos)
    throw(ERR_IO, "End of stream")
  if (length < 0)
    throw(ERR_ILL_ARG)
  if (length == 0) {
    return ""
  }
  var b = new [Byte](length)
  this.readFully(b, 0, length)
  return ba2utf(b)
}

def PartialIStream.addDummyByte() {
  this.dummyByteCount = 1
}
