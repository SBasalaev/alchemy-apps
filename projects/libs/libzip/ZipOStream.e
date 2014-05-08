use "ZipEntryImpl.eh"

use "zlib/crc32.eh"
use "zlib/deflater.eh"
use "zlib/deflaterstream.eh"
use "list.eh"
use "sys.eh"

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

def ZipOStream.setComment(comment: String) {
  var commentBytes = comment.utfbytes()
  if (commentBytes.len > 0xffff)
    throw(ERR_ILL_ARG, "Comment too long.")
  this.zipComment = commentBytes
}

def ZipOStream.setMethod(method: Int) {
  if (method != ZIP_STORED && method != ZIP_DEFLATED)
    throw(ERR_ILL_ARG, "Method not supported.")
  this.defaultMethod = method
}

def ZipOStream.setLevel(level: Int) {
  this.dfl.setLevel(level)
}

def ZipOStream.writeLeShort(value: Int) {
  this.out.write(value & 0xff)
  this.out.write((value >> 8) & 0xff)
}

def ZipOStream.writeLeInt(value: Int) {
  this.writeLeShort(value)
  this.writeLeShort(value >> 16)
}


def ZipOStream.closeEntry() {
  if (this.curEntry == null)
    throw(ERR_IO, "No open entry")

  /* First finish the deflater, if appropriate */
  if (this.curMethod == ZIP_DEFLATED)
    super.finish()

  var csize = if (this.curMethod == ZIP_DEFLATED) this.dfl.getBytesWritten() else this.size

  if (this.curEntry.getSize() < 0)
    this.curEntry.setSize(this.size)
  else if (this.curEntry.getSize() != this.size)
    throw(ERR_IO, "size was " + this.size + ", but expected " + this.curEntry.getSize())

  if (this.curEntry.getCompressedSize() < 0)
    this.curEntry.setCompressedSize(csize)
  else if (this.curEntry.getCompressedSize() != csize)
    throw(ERR_IO, "compressed size was " + csize + ", but expected " + this.curEntry.getCompressedSize())

  if (this.curEntry.getCRC() < 0)
    this.curEntry.setCRC(this.crc.value)
  else if (this.curEntry.getCRC() != this.crc.value)
    throw(ERR_IO, "crc was " + this.crc.value.tohex() + ", but expected " + this.curEntry.getCRC().tohex())

  this.offset += csize

  /* Now write the data descriptor entry if needed. */
  if (this.curMethod == ZIP_DEFLATED && (this.curEntry.flags & 8) != 0) {
    this.writeLeInt(EXTSIG);
    this.writeLeInt(this.curEntry.getCRC())
    this.writeLeInt(this.curEntry.getCompressedSize())
    this.writeLeInt(this.curEntry.getSize())
    this.offset += EXTHDR;
  }

  this.entries.add(this.curEntry)
  this.curEntry = null
}

def ZipOStream.putNextEntry(entry: ZipEntry) {
  if (this.entries == null)
    throw(ERR_IO, "ZipOutputStream was finished")

  var method = entry.getMethod()
  var flags = 0
  if (method == -1)
    method = this.defaultMethod

  if (method == ZIP_STORED) {
    if (entry.getCompressedSize() >= 0) {
      if (entry.getSize() < 0)
        entry.setSize(entry.getCompressedSize())
      else if (entry.getSize() != entry.getCompressedSize())
        throw(ERR_IO, "Method STORED, but compressed size != size")
    } else {
      entry.setCompressedSize(entry.getSize())
    }

    if (entry.getSize() < 0)
      throw(ERR_IO, "Method STORED, but size not set")
    if (entry.getCRC() < 0)
      throw(ERR_IO, "Method STORED, but crc not set")
  } else if (method == ZIP_DEFLATED) {
    if (entry.getCompressedSize() < 0 || entry.getSize() < 0 || entry.getCRC() < 0)
      flags |= 8
  }

  if (this.curEntry != null)
    this.closeEntry()

  if (entry.getTime() < 0)
    entry.setTime(systime())

  entry.flags = flags
  entry.offset = this.offset
  entry.setMethod(method)
  this.curMethod = method
  /* Write the local file header */
  this.writeLeInt(LOCSIG)
  this.writeLeShort(if (method == ZIP_STORED)
      ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
  this.writeLeShort(flags)
  this.writeLeShort(method)
  this.writeLeInt(entry.getDOSTime())
  if ((flags & 8) == 0) {
    this.writeLeInt(entry.getCRC())
    this.writeLeInt(entry.getCompressedSize())
    this.writeLeInt(entry.getSize())
  } else {
    this.writeLeInt(0)
    this.writeLeInt(0)
    this.writeLeInt(0)
  }
  var name = entry.getName().utfbytes()
  if (name.len > 0xffff)
    throw(ERR_IO, "Name too long.")
  var extra = entry.getExtra()
  if (extra == null)
    extra = new [Byte](0)
  this.writeLeShort(name.len)
  this.writeLeShort(extra.len)
  this.out.writeArray(name, 0, name.len)
  this.out.writeArray(extra, 0, extra.len)

  this.offset += LOCHDR + name.len + extra.len

  /* Activate the entry. */

  this.curEntry = entry
  this.crc.reset()
  if (method == ZIP_DEFLATED)
    this.dfl.reset()
  this.size = 0
}

def ZipOStream.writeArray(b: [Byte], off: Int, len: Int) {
  if (this.curEntry == null)
    throw(ERR_IO, "No open entry.")

  switch (this.curMethod) {
    ZIP_DEFLATED:
      super.writeArray(b, off, len)
    ZIP_STORED:
      this.out.writeArray(b, off, len)
  }

  this.crc.updateArray(b, off, len)
  this.size += len
}

def ZipOStream.write(b: Int) {
  this.writeArray([b.cast(Byte)], 0, 1)
}

def ZipOStream.finish() {
  if (this.entries != null) {
    if (this.curEntry != null)
      this.closeEntry()

    var numEntries = 0
    var sizeEntries = 0
    
    for (var i=0, i < this.entries.len(), i+=1) {
      var entry = this.entries[i].cast(ZipEntry)
        
      var method = entry.getMethod()
      this.writeLeInt(CENSIG)
      this.writeLeShort(if (method == ZIP_STORED)
             ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
      this.writeLeShort(if (method == ZIP_STORED)
             ZIP_STORED_VERSION else ZIP_DEFLATED_VERSION)
      this.writeLeShort(entry.flags)
      this.writeLeShort(method)
      this.writeLeInt(entry.getDOSTime())
      this.writeLeInt(entry.getCRC())
      this.writeLeInt(entry.getCompressedSize())
      this.writeLeInt(entry.getSize())

      var name = entry.getName().utfbytes()
      if (name.len > 0xffff)
        throw(ERR_IO, "Name too long.")
      var extra = entry.getExtra()
      if (extra == null)
        extra = new [Byte](0)
      var str = entry.getComment()
      var comment = if (str != null) str.utfbytes() else new [Byte](0)
      if (comment.len > 0xffff)
        throw(ERR_IO, "Comment too long.")

      this.writeLeShort(name.len)
      this.writeLeShort(extra.len)
      this.writeLeShort(comment.len)
      this.writeLeShort(0) /* disk number */
      this.writeLeShort(0) /* internal file attr */
      this.writeLeInt(0)   /* external file attr */
      this.writeLeInt(entry.offset)

      this.out.writeArray(name, 0, name.len)
      this.out.writeArray(extra, 0, extra.len)
      this.out.writeArray(comment, 0, comment.len)
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
    this.out.writeArray(this.zipComment, 0, this.zipComment.len)
    this.out.flush()
    this.entries = null
  }
}

def ZipOStream.close() {
  this.finish()
  this.out.close()
}
