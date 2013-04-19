use "ZipEntryImpl.eh"
use "ZipOStream.eh"

use "zlib/crc32.eh"
use "zlib/deflater.eh"
use "zlib/deflaterstream.eh"
use "list.eh"
use "string.eh"
use "error.eh"
use "time.eh"

const ZIP_STORED_VERSION = 10
const ZIP_DEFLATED_VERSION = 20

type ZipOStream < DeflaterStream {
  entries: List,
  crc: CRC32,
  curEntry: ZipEntry,
  curMethod: Int,
  size: Int,
  offset: Int = 0,
  zipComment: [Byte],
  defaultMethod: Int = ZIP_DEFLATED
}

def ZipOStream.new(out: OStream) {
  super(out, new Deflater(DEFAULT_COMPRESSION, true), 4096)
  this.entries = new List()
  this.crc = new CRC32()
  this.zipComment = new [Byte](0)
}

def ZipOStream.set_comment(comment: String) {
  var commentBytes = comment.utfbytes()
  if (commentBytes.len > 0xffff)
    error(ERR_ILL_ARG, "Comment too long.")
  this.zipComment = commentBytes
}

def ZipOStream.set_method(method: Int) {
  if (method != ZIP_STORED && method != ZIP_DEFLATED)
    error(ERR_ILL_ARG, "Method not supported.")
  this.defaultMethod = method
}

def ZipOStream.set_level(level: Int) {
  this.dfl.set_level(level)
}

def ZipOStream.writeLeShort(value: Int) {
  this.out.write(value & 0xff)
  this.out.write((value >> 8) & 0xff)
}

def ZipOStream.writeLeInt(value: Int) {
  this.writeLeShort(value)
  this.writeLeShort(value >> 16)
}

def ZipOStream.putNextEntry(entry: ZipEntry) {
  if (this.entries == null)
    error(ERR_IO, "ZipOutputStream was finished")

  var method = entry.get_method()
  var flags = 0
  if (method == -1)
    method = this.defaultMethod

  if (method == ZIP_STORED) {
    if (entry.get_compressedsize() >= 0) {
      if (entry.get_size() < 0)
        entry.set_size(entry.get_compressedsize())
      else if (entry.get_size() != entry.get_compressedsize())
        error(ERR_IO, "Method STORED, but compressed size != size")
    } else {
      entry.set_compressedsize(entry.get_size())
    }

    if (entry.get_size() < 0)
      error(ERR_IO, "Method STORED, but size not set")
    if (entry.get_crc() < 0)
      error(ERR_IO, "Method STORED, but crc not set")
  } else if (method == ZIP_DEFLATED) {
    if (entry.get_compressedsize() < 0 || entry.get_size() < 0 || entry.get_crc() < 0)
      flags |= 8
  }

  if (this.curEntry != null)
    this.closeEntry()

  if (entry.get_time() < 0)
    entry.set_time(systime())

  entry.flags = flags
  entry.offset = this.offset
  entry.set_method(method)
  this.curMethod = method
  /* Write the local file header */
  this.writeLeInt(LOCSIG)
  this.writeLeShort(if (method == ZIP_STORED)
      ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
  this.writeLeShort(flags)
  this.writeLeShort(method)
  this.writeLeInt(entry.getDOSTime())
  if ((flags & 8) == 0) {
    this.writeLeInt(entry.get_crc())
    this.writeLeInt(entry.get_compressedsize())
    this.writeLeInt(entry.get_size())
  } else {
    this.writeLeInt(0)
    this.writeLeInt(0)
    this.writeLeInt(0)
  }
  var name = entry.get_name().utfbytes()
  if (name.len > 0xffff)
    error(ERR_IO, "Name too long.")
  var extra = entry.get_extra()
  if (extra == null)
    extra = new [Byte](0)
  this.writeLeShort(name.len)
  this.writeLeShort(extra.len)
  this.out.writearray(name, 0, name.len)
  this.out.writearray(extra, 0, extra.len)

  this.offset += LOCHDR + name.len + extra.len

  /* Activate the entry. */

  this.curEntry = entry
  this.crc.reset()
  if (method == ZIP_DEFLATED)
    this.dfl.reset()
  this.size = 0
}

def ZipOStream.closeEntry() {
  if (this.curEntry == null)
    error(ERR_IO, "No open entry")

  /* First finish the deflater, if appropriate */
  if (this.curMethod == ZIP_DEFLATED)
    super.finish()

  var csize = if (this.curMethod == ZIP_DEFLATED) this.dfl.get_byteswritten() else this.size

  if (this.curEntry.get_size() < 0)
    this.curEntry.set_size(this.size)
  else if (this.curEntry.get_size() != this.size)
    error(ERR_IO, "size was " + this.size + ", but expected " + this.curEntry.get_size())

  if (this.curEntry.get_compressedsize() < 0)
    this.curEntry.set_compressedsize(csize)
  else if (this.curEntry.get_compressedsize() != csize)
    error(ERR_IO, "compressed size was " + csize + ", but expected " + this.curEntry.get_compressedsize())

  if (this.curEntry.get_crc() < 0)
    this.curEntry.set_crc(this.crc.value)
  else if (this.curEntry.get_crc() != this.crc.value)
    error(ERR_IO, "crc was " + this.crc.value.tohex() + ", but expected " + this.curEntry.get_crc().tohex())

  this.offset += csize

  /* Now write the data descriptor entry if needed. */
  if (this.curMethod == ZIP_DEFLATED && (this.curEntry.flags & 8) != 0) {
    this.writeLeInt(EXTSIG);
    this.writeLeInt(this.curEntry.get_crc())
    this.writeLeInt(this.curEntry.get_compressedsize())
    this.writeLeInt(this.curEntry.get_size())
    this.offset += EXTHDR;
  }

  this.entries.add(this.curEntry)
  this.curEntry = null
}

def ZipOStream.writearray(b: [Byte], off: Int, len: Int) {
  if (this.curEntry == null)
    error(ERR_IO, "No open entry.")

  switch (this.curMethod) {
    ZIP_DEFLATED:
      super.writearray(b, off, len)
    ZIP_STORED:
      this.out.writearray(b, off, len)
  }

  this.crc.updatearray(b, off, len)
  this.size += len
}

def ZipOStream.write(b: Int) {
  var buf = new [Byte] {b}
  this.writearray(buf, 0, 1)
}

def ZipOStream.finish() {
  if (this.entries != null) {
    if (this.curEntry != null)
      this.closeEntry()

    var numEntries = 0
    var sizeEntries = 0
    
    for (var i=0, i < this.entries.len(), i+=1) {
      var entry = this.entries[i].cast(ZipEntry)
        
      var method = entry.get_method()
      this.writeLeInt(CENSIG)
      this.writeLeShort(if (method == ZIP_STORED)
             ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
      this.writeLeShort(if (method == ZIP_STORED)
             ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
      this.writeLeShort(entry.flags)
      this.writeLeShort(method)
      this.writeLeInt(entry.getDOSTime())
      this.writeLeInt(entry.get_crc())
      this.writeLeInt(entry.get_compressedsize())
      this.writeLeInt(entry.get_size())

      var name = entry.get_name().utfbytes()
      if (name.len > 0xffff)
        error(ERR_IO, "Name too long.")
      var extra = entry.get_extra()
      if (extra == null)
        extra = new [Byte](0)
      var str = entry.get_comment()
      var comment = if (str != null) str.utfbytes() else new [Byte](0)
      if (comment.len > 0xffff)
        error(ERR_IO, "Comment too long.")

      this.writeLeShort(name.len)
      this.writeLeShort(extra.len)
      this.writeLeShort(comment.len)
      this.writeLeShort(0) /* disk number */
      this.writeLeShort(0) /* internal file attr */
      this.writeLeInt(0)   /* external file attr */
      this.writeLeInt(entry.offset)

      this.out.writearray(name, 0, name.len)
      this.out.writearray(extra, 0, extra.len)
      this.out.writearray(comment, 0, comment.len)
      numEntries += 1
      sizeEntries += CENHDR + name.len + extra.len + comment.len
    }

    this.writeLeInt(ENDSIG)
    this.writeLeShort(0) /* disk number */
    this.writeLeShort(0) /* disk with start of central dir */
    this.writeLeShort(numEntries)
    this.writeLeShort(numEntries)
    this.writeLeInt(sizeEntries)
    this.writeLeInt(this.offset)
    this.writeLeShort(this.zipComment.len)
    this.out.writearray(this.zipComment, 0, this.zipComment.len)
    this.out.flush()
    this.entries = null
  }
}

def ZipOStream.close() {
  this.finish()
  this.out.close()
}