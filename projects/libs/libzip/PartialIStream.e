use "PartialIStream.eh"

use "error.eh"
use "string.eh"

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
  this.count - this.pos + this.dummyByteCount
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
      0
    } else {
      -1
    }
  } else {
    var pos = this.pos
    this.pos = pos + 1
    this.buf[pos] & 0xff
  }
}

def PartialIStream.readarray(b: [Byte], off: Int, len: Int): Int {
  if (b == null) {
    error(ERR_NULL)
  } else if ((off < 0) || (off > b.len) || (len < 0) || ((off + len) > b.len) || ((off + len) < 0)) {
    error(ERR_RANGE)
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

  numBytes
}

def PartialIStream.skip(n: Int): Int {
  if (this.pos + n > this.count) {
    n = this.count - this.pos
  }
  if (n < 0) {
    0
  } else {
    this.pos += n
    n
  }
}

def PartialIStream.seek(newpos: Int) {
  this.pos = newpos
}

def PartialIStream.readFully(buf: [Byte], off: Int = 0, len: Int = -1) {
  if (len < 0) len = buf.len
  if (this.readarray(buf, off, len) != len)
    error(ERR_IO, "End of stream")
}

def PartialIStream.readLeShort(): Int {
  var b0 = this.read()
  var b1 = this.read()
  if (b1 == -1)
    error(ERR_IO, "End of stream");
  (b0 & 0xff) | (b1 & 0xff) << 8
}

def PartialIStream.readLeInt(): Int {
  var b0 = this.read()
  var b1 = this.read()
  var b2 = this.read()
  var b3 = this.read()
  if (b3 == -1)
    error(ERR_IO, "End of stream");
  ((b0 & 0xff) | (b1 & 0xff) << 8) | ((b2 & 0xff) | (b3 & 0xff) << 8) << 16
}

def PartialIStream.readString(length: Int): String {
  if (length > this.count - this.pos)
    error(ERR_IO, "End of stream")
  if (length < 0)
    error(ERR_ILL_ARG)
  if (length == 0) {
    ""
  } else {
    var b = new [Byte](length)
    this.readFully(b, 0, length)
    ba2utf(b)
  }
}

def PartialIStream.addDummyByte() {
  this.dummyByteCount = 1
}
