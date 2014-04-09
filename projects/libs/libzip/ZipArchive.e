use "ZipConstants.eh"
use "ZipArchive.eh"
use "ZipEntryImpl.eh"
use "PartialIStream.eh"

use "dict.eh"
use "string.eh"
use "error.eh"

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
    error(ERR_IO, "Not a valid zip archive")
  }
  var sig = this.buf[this.off] & 0xFF
            | ((this.buf[this.off + 1] & 0xFF) << 8)
            | ((this.buf[this.off + 2] & 0xFF) << 16)
            | ((this.buf[this.off + 3] & 0xFF) << 24)
  if (sig != LOCSIG) {
    error(ERR_IO, "Not a valid zip archive");
  }
}

def ZipArchive.new(in: IStream) {
  var out = new BArrayOStream()
  out.writeall(in)
  this.buf = out.tobarray()
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
      error(ERR_IO, "central directory not found, probably not a zip archive")
    inp.seek(this.off + pos)
    pos -= 1
  } while (inp.readLeInt() != ENDSIG)
    
  if (inp.skip(ENDTOT - ENDNRD) != ENDTOT - ENDNRD)
    error(ERR_IO, "End of stream")
  var count = inp.readLeShort()
  if (inp.skip(ENDOFF - ENDSIZ) != ENDOFF - ENDSIZ)
    error(ERR_IO, "End of stream")
  var centralOffset = inp.readLeInt()

  this.entries = new Dict()
  inp.seek(this.off + centralOffset)
    
  for (var i=0, i < count, i+=1) {
    if (inp.readLeInt() != CENSIG)
      error(ERR_IO, "Wrong Central Directory signature")

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
    entry.set_method(method)
    entry.set_crc(crc)
    entry.set_size(size)
    entry.set_compressedsize(csize)
    entry.setDOSTime(dostime)
    if (extraLen > 0) {
      var extra = new [Byte](extraLen)
      inp.readFully(extra)
      entry.set_extra(extra)
    }
    if (commentLen > 0) {
      entry.set_comment(inp.readString(commentLen))
    }
    entry.offset = offset
    this.entries[name] = entry
  }
}

def ZipArchive.getEntries(): Dict {
  if (this.entries == null)
    this.readEntries()

  this.entries
}

def ZipArchive.entries(): [ZipEntry] {
  var d = try {
    this.getEntries()
  } catch {
    new Dict()
  }
  
  var keys = d.keys()
  var result = new [ZipEntry](keys.len)
  
  for (var i=0, i<keys.len, i+=1) {
    result[i] = d[keys[i]].cast(ZipEntry)
  }
  
  result
}

def ZipArchive.getEntry(name: String): ZipEntry {
  try {
    var entries = this.getEntries()
    var entry = entries[name].cast(ZipEntry)
    // If we didn't find it, maybe it's a directory.
    if (entry == null && !name.endswith("/"))
      entry = entries[name + '/'].cast(ZipEntry)
    if (entry != null) {
      var z = entry.clone()
      z.name = name
      z
    } else
      null
  } catch {
    null
  }
}

def ZipArchive.getIStream(entry: ZipEntry): ZipEntryIStream {
  var entries = this.getEntries()
  var name = entry.get_name()
  var zipEntry = entries[name].cast(ZipEntry)
  if (zipEntry == null) {
    error(ERR_IO, "No such entry: " + name)
  }
  var inp = new PartialIStream(this.buf, this.off, this.len)
  inp.seek(this.off + zipEntry.offset)

  if (inp.readLeInt() != LOCSIG)
    error(ERR_IO, "Wrong Local header signature: " + name)

  inp.skip(4)

  if (zipEntry.get_method() != inp.readLeShort())
    error(ERR_IO, "Compression method mismatch: " + name)

  inp.skip(16)

  var nameLen = inp.readLeShort()
  var extraLen = inp.readLeShort()
  inp.skip(nameLen + extraLen)

  inp.setLength(zipEntry.get_compressedsize())

  var method = zipEntry.get_method()
  switch (method) {
    ZIP_STORED:
      new ZipEntryIStream { pin = inp }
    ZIP_DEFLATED: {
      inp.addDummyByte()
      var buf = new [Byte](inp.available())
      inp.readFully(buf)
      var inf = new Inflater(true)
      var sz = entry.get_size().cast(Int)
      new ZipEntryIStream { infin = new InflaterStream(istream_from_ba(buf), inf, 4096) }
    }
    else: {
      error(ERR_IO, "Unknown compression method " + method)
      null
    }
  }
}

def ZipArchive.size(): Int {
  try {
    this.getEntries().size()
  } catch {
    0
  }
}
