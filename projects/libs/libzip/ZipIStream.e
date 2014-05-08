use "ZipConstants.eh"
use "ZipEntryImpl.eh"

use "zlib/crc32.eh"
use "zlib/inflaterstream.eh"

type ZipIStream < InflaterStream {
  crc: CRC32,
  entry: ZipEntry,
  csize: Int,
  size: Int,
  method: Int,
  flags: Int,
  avail: Int,
  entryAtEOF: Bool
}

def ZipIStream.new(inp: IStream) {
  super(inp, new Inflater(true), 4096)
  this.crc = new CRC32()
}

def ZipIStream.fillBuf() {
  this.len = this.input.readArray(this.buf, 0, this.buf.len)
  this.avail = this.len
}


def ZipIStream.closeEntry() {
  if (this.crc == null)
    throw(ERR_IO, "Stream closed.")
  if (this.entry != null) {
    var quit = false
    if (this.method == ZIP_DEFLATED) {
      if ((this.flags & 8) != 0) {
        /* We don't know how much we must skip, read until end. */
        var tmp = new [Byte](2048)
        while (this.readArray(tmp, 0, 2048) > 0) { }

        /* read will close this entry */
        quit = true
      } else {
        this.csize -= this.inf.getBytesRead()
        this.avail = this.inf.getRemaining()
      }
    }

    if (!quit) {
      if (this.avail > this.csize && this.csize >= 0) {
        this.avail -= this.csize
      } else {
        this.csize -= this.avail
        this.avail = 0
        while (this.csize != 0) {
          var skipped = this.input.skip(this.csize & 0xffffffffL)
          if (skipped <= 0)
            throw(ERR_IO, "zip archive ends early.")
          this.csize -= skipped
        }
      }

      this.size = 0
      this.crc.reset()
      if (this.method == ZIP_DEFLATED)
        this.inf.reset()
      this.entry = null
      this.entryAtEOF = true;
    }
  }
}

def ZipIStream.readBuf(out: [Byte], offset: Int, length: Int): Int {
  if (this.avail <= 0) {
    this.fillBuf()
  }
  if (this.avail <= 0) {
    return -1
  }
  if (length > this.avail)
    length = this.avail
  acopy(this.buf, this.len - this.avail, out, offset, length)
  this.avail -= length
  return length
}

def ZipIStream.readFully(out: [Byte]) {
  var off = 0
  var len = out.len
  while (len > 0) {
    var count = this.readBuf(out, off, len)
    if (count == -1)
      throw(ERR_IO, "End of stream")
    off += count
    len -= count
  }
}

def ZipIStream.readLeByte(): Int {
  if (this.avail <= 0) {
    this.fillBuf()
    if (this.avail <= 0)
      throw(ERR_IO, "EOF in header")
  }
  var avail = this.avail
  this.avail = avail-1
  return this.buf[this.len - avail] & 0xff
}

def ZipIStream.readLeShort(): Int {
  return this.readLeByte() | (this.readLeByte() << 8)
}

def ZipIStream.readLeInt(): Int {
  return this.readLeShort() | (this.readLeShort() << 16)
}

def ZipIStream.getNextEntry(): ZipEntry {
  if (this.crc == null)
    throw(ERR_IO, "Stream closed.")
  if (this.entry != null)
    this.closeEntry()

  var header = this.readLeInt()
  if (header == CENSIG) {
    /* Central Header reached. */
    this.close()
    return null
  }
  if (header != LOCSIG)
    throw(ERR_IO, "Wrong Local header signature: " + header.tohex())
  /* skip version */
  this.readLeShort()
  this.flags = this.readLeShort()
  this.method = this.readLeShort()
  var dostime = this.readLeInt()
  var crc = this.readLeInt()
  this.csize = this.readLeInt()
  this.size = this.readLeInt()
  var nameLen = this.readLeShort()
  var extraLen = this.readLeShort()

  if (this.method == ZIP_STORED && this.csize != this.size)
    throw(ERR_IO, "Stored, but compressed != uncompressed")

  var buffer = new [Byte](nameLen)
  this.readFully(buffer)
  var name = ba2utf(buffer)

  this.entry = new ZipEntry(name)
  this.entryAtEOF = false
  this.entry.setMethod(this.method)
  if ((this.flags & 8) == 0) {
    this.entry.setCRC(crc)
    this.entry.setSize(this.size)
    this.entry.setCompressedSize(this.csize)
  }
  this.entry.setDOSTime(dostime)
  if (extraLen > 0) {
    var extra = new [Byte](extraLen)
    this.readFully(extra)
    this.entry.setExtra(extra)
  }

  if (this.method == ZIP_DEFLATED && this.avail > 0) {
    acopy(this.buf, this.len - this.avail, this.buf, 0, this.avail)
    this.len = this.avail
    this.avail = 0
    this.inf.setInput(this.buf, 0, this.len)
  }
  return this.entry
}

def ZipIStream.readDataDescr() {
  if (this.readLeInt() != EXTSIG)
    throw(ERR_IO, "Data descriptor signature not found")
  this.entry.setCRC(this.readLeInt())
  this.csize = this.readLeInt()
  this.size = this.readLeInt()
  this.entry.setSize(this.size)
  this.entry.setCompressedSize(this.csize)
}

def ZipIStream.available(): Int {
  return if (this.entryAtEOF) 0 else 1
}

def ZipIStream.readArray(b: [Byte], off: Int, len: Int): Int {
  if (len == 0) {
    return 0
  }
  if (this.crc == null)
    throw(ERR_IO, "Stream closed.")
  if (this.entry == null) {
    return -1
  }
  var finished = false
  switch (this.method) {
    ZIP_DEFLATED: {
      len = super.readArray(b, off, len)
      if (len < 0) {
        if (!this.inf.finished())
          throw(ERR_IO, "Inflater not finished!?")
        this.avail = this.inf.getRemaining()
        if ((this.flags & 8) != 0)
          this.readDataDescr()
         if (this.inf.bytesRead != this.csize
            || this.inf.bytesWritten != this.size)
          throw(ERR_IO, "size mismatch: "+this.csize+";"+this.size+" <-> "+this.inf.bytesRead+";"+this.inf.bytesWritten)
        this.inf.reset()
        finished = true
      }
    }
    ZIP_STORED: {
      if (len > this.csize && this.csize >= 0)
        len = this.csize

      len = this.readBuf(b, off, len)
      if (len > 0) {
        this.csize -= len
        this.size -= len
      }

      if (this.csize == 0)
        finished = true
      else if (len < 0)
        throw(ERR_IO, "EOF in stored block")
    }
  }

  if (len > 0)
    this.crc.updateArray(b, off, len)

  if (finished) {
    if ((this.crc.value) != this.entry.getCRC())
      throw(ERR_IO, "CRC mismatch")
    this.crc.reset()
    this.entry = null
    this.entryAtEOF = true
  }
  return len
}

def ZipIStream.read(): Int {
  var b = new [Byte](1)
  if (this.readArray(b, 0, 1) <= 0) {
    return -1
  } else {
    return b[0] & 0xff
  }
}

def ZipIStream.close() {
  super.close()
  this.crc = null
  this.entry = null
  this.entryAtEOF = true
}

def ZipIStream.skip(n: Long): Long {
  var remaining = n

  if (n <= 0) {
    return 0L
  } else {
    var size = if (remaining < 1024) remaining.cast(Int) else 1024
    var skipBuffer = new [Byte](size)
    var count = 0
    while (count >= 0 && remaining > 0) {
      count = this.readArray(skipBuffer, 0, if (size < remaining) size else remaining)
      if (count > 0) {
        remaining -= count;
      }
    }
    return n - remaining
  }
}
