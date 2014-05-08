use "ZipConstants.eh"
use "ZipArchive.eh"
use "ZipEntryImpl.eh"
use "PartialIStream.eh"

use "dict.eh"
use "bufferio.eh"

type ZipArchive {
  // Byte array from which zip entries are read.
  buf: [Byte],
  // The index into the buffer to start reading bytes from.
  off: Int,
  // The number of bytes to read from the buffer.
  len: Int,
  // The entries of this zip archive when initialized and not yet closed.
  entries: Dict
}

def ZipArchive.checkZipArchive() {
  if (this.len < 4) {
    throw(ERR_IO, "Not a valid zip archive")
  }
  var sig = this.buf[this.off] & 0xFF
            | ((this.buf[this.off + 1] & 0xFF) << 8)
            | ((this.buf[this.off + 2] & 0xFF) << 16)
            | ((this.buf[this.off + 3] & 0xFF) << 24)
  if (sig != LOCSIG) {
    throw(ERR_IO, "Not a valid zip archive");
  }
}

def ZipArchive.new(inp: IStream) {
  var out = new BufferOStream()
  out.writeAll(inp)
  this.buf = out.getBytes()
  this.off = 0
  this.len = this.buf.len
  this.checkZipArchive()
}

def ZipArchive.readEntries() {
  /* Search for the End Of Central Directory.  When a zip comment is 
   * present the directory may start earlier.
   * Note that a comment has a maximum length of 64K, so that is the
   * maximum we search backwards.
   */
  var inp = new PartialIStream(this.buf, this.off, this.len)
  var pos = this.len - ENDHDR
  var top = pos - 65536
  if (top < 0) top = 0
  do {
    if (pos < top)
      throw(ERR_IO, "central directory not found, probably not a zip archive")
    inp.seek(this.off + pos)
    pos -= 1
  } while (inp.readLeInt() != ENDSIG)
    
  if (inp.skip(ENDTOT - ENDNRD) != ENDTOT - ENDNRD)
    throw(ERR_IO, "End of stream")
  var count = inp.readLeShort()
  if (inp.skip(ENDOFF - ENDSIZ) != ENDOFF - ENDSIZ)
    throw(ERR_IO, "End of stream")
  var centralOffset = inp.readLeInt()

  this.entries = new Dict()
  inp.seek(this.off + centralOffset)
    
  for (var i=0, i < count, i+=1) {
    if (inp.readLeInt() != CENSIG)
      throw(ERR_IO, "Wrong Central Directory signature")

    inp.skip(6)
    var method = inp.readLeShort()
    var dostime = inp.readLeInt()
    var crc = inp.readLeInt()
    var csize = inp.readLeInt()
    var size = inp.readLeInt()
    var nameLen = inp.readLeShort()
    var extraLen = inp.readLeShort()
    var commentLen = inp.readLeShort()
    inp.skip(8)
    var offset = inp.readLeInt()
    var name = inp.readString(nameLen)

    var entry = new ZipEntry(name)
    entry.setMethod(method)
    entry.setCRC(crc)
    entry.setSize(size)
    entry.setCompressedSize(csize)
    entry.setDOSTime(dostime)
    if (extraLen > 0) {
      var extra = new [Byte](extraLen)
      inp.readFully(extra)
      entry.setExtra(extra)
    }
    if (commentLen > 0) {
      entry.setComment(inp.readString(commentLen))
    }
    entry.offset = offset
    this.entries[name] = entry
  }
}

def ZipArchive.getEntries(): Dict {
  if (this.entries == null)
    this.readEntries()

  return this.entries
}

def ZipArchive.entries(): [ZipEntry] {
  var d = try this.getEntries() catch new Dict()
  
  var keys = d.keys()
  var result = new [ZipEntry](keys.len)
  
  for (var i=0, i<keys.len, i+=1) {
    result[i] = d[keys[i]].cast(ZipEntry)
  }
  
  return result
}

def ZipArchive.getEntry(name: String): ZipEntry {
  try {
    var entries = this.getEntries()
    var entry = entries[name].cast(ZipEntry)
    // If we didn't find it, maybe it's a directory.
    if (entry == null && !name.endsWith("/"))
      entry = entries[name + '/'].cast(ZipEntry)
    if (entry != null) {
      var z = entry.clone()
      z.name = name
      return z
    }
    else return null
  } catch {
    return null
  }
}

def ZipArchive.getIStream(entry: ZipEntry): ZipEntryIStream {
  var entries = this.getEntries()
  var name = entry.getName()
  var zipEntry = entries[name].cast(ZipEntry)
  if (zipEntry == null) {
    throw(ERR_IO, "No such entry: " + name)
  }
  var inp = new PartialIStream(this.buf, this.off, this.len)
  inp.seek(this.off + zipEntry.offset)

  if (inp.readLeInt() != LOCSIG)
    throw(ERR_IO, "Wrong Local header signature: " + name)

  inp.skip(4)

  if (zipEntry.getMethod() != inp.readLeShort())
    throw(ERR_IO, "Compression method mismatch: " + name)

  inp.skip(16)

  var nameLen = inp.readLeShort()
  var extraLen = inp.readLeShort()
  inp.skip(nameLen + extraLen)

  inp.setLength(zipEntry.getCompressedSize())

  var method = zipEntry.getMethod()
  switch (method) {
    ZIP_STORED:
      return new ZipEntryIStream {
        pin = inp
      }
    ZIP_DEFLATED: {
      inp.addDummyByte()
      var buf = new [Byte](inp.available())
      inp.readFully(buf)
      var inf = new Inflater(true)
      var sz = entry.getSize().cast(Int)
      return new ZipEntryIStream {
        infin = new InflaterStream(new BufferIStream(buf), inf, 4096)
      }
    }
    else: {
      throw(ERR_IO, "Unknown compression method " + method)
    }
  }
}

def ZipArchive.size(): Int {
  try {
    return this.getEntries().len()
  } catch {
    return 0
  }
}
