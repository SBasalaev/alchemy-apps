use "ZipEntryImpl.eh"

use "time.eh"

const KNOWN_SIZE    = 1
const KNOWN_CSIZE   = 2
const KNOWN_CRC     = 4
const KNOWN_TIME    = 8
const KNOWN_DOSTIME = 16
const KNOWN_EXTRA   = 32

def ZipEntry.new(name: String) {
  if (name.len() > 65535)
    throw(ERR_ILL_ARG, "name is too long")
  this.name = name
}

def ZipEntry.clone(): ZipEntry {
  var entry = new ZipEntry(this.name)
  entry.name = this.name
  entry.size = this.size
  entry.compressedSize = this.compressedSize
  entry.crc = this.crc
  entry.comment = this.comment
  entry.method = this.method
  entry.known = this.known
  entry.dostime = this.dostime
  entry.time = this.time
  entry.extra = this.extra
  entry.flags = this.flags
  entry.offset = this.offset
  return entry
}

def ZipEntry.setDOSTime(dostime: Int) {
  this.dostime = dostime
  this.known |= KNOWN_DOSTIME
  this.known &= ~KNOWN_TIME
}

def ZipEntry.getDOSTime(): Int {
  if ((this.known & KNOWN_DOSTIME) != 0) {
    return this.dostime
  }
  if ((this.known & KNOWN_TIME) != 0) {
    var time = this.time
    this.dostime = (year(time) - 1980 & 0x7f) << 25
        | (month(time) + 1) << 21
        | (day(time)) << 16
        | (hour(time)) << 11
        | (minute(time)) << 5
        | (second(time)) >> 1
    this.known |= KNOWN_DOSTIME
    return this.dostime
  }
  return 0
}

def ZipEntry.getName(): String {
  return this.name
}

def ZipEntry.setTime(time: Long) {
  this.time = time
  this.known |= KNOWN_TIME
  this.known &= ~KNOWN_DOSTIME
}

def ZipEntry.parseExtra() {
  var extra = this.extra
  if ((this.known & KNOWN_EXTRA) == 0) {
    if (extra == null) {
      this.known |= KNOWN_EXTRA
    } else {
      try {
        var pos = 0
        while (pos < extra.len) {
          var sig = (extra[pos] & 0xff) | (extra[pos+1] & 0xff) << 8
          pos += 2
          var len = (extra[pos] & 0xff) | (extra[pos+1] & 0xff) << 8
          pos += 2
          if (sig == 0x5455) {
            /* extended time stamp */
            var flags = extra[pos]
            if ((flags & 1) != 0) {
              var time: Long = ((extra[pos+1] & 0xff)
                   | (extra[pos+2] & 0xff) << 8
                   | (extra[pos+3] & 0xff) << 16
                   | (extra[pos+4] & 0xff) << 24)
              this.setTime(time*1000)
            }
          }
          pos += len
        }
      } catch { }

      this.known |= KNOWN_EXTRA
    }
  }
}

def ZipEntry.getTime(): Long {
  // The extra bytes might contain the time (posix/unix extension)
  this.parseExtra()

  if ((this.known & KNOWN_TIME) != 0) {
    return this.time
  }
  if ((this.known & KNOWN_DOSTIME) != 0) {
    var dostime = this.dostime
    var sec = 2 * (dostime & 0x1f)
    var min = (dostime >> 5) & 0x3f
    var hrs = (dostime >> 11) & 0x1f
    var dy = (dostime >> 16) & 0x1f
    var mon = ((dostime >> 21) & 0xf) - 1
    var yr = ((dostime >> 25) & 0x7f) + 1980

    try {
      this.time = timeof(yr, mon, dy, hrs, min, sec, 0)
      this.known |= KNOWN_TIME
      return this.time
    } catch {
      /* Ignore illegal time stamp */
      this.known &= ~KNOWN_TIME;
      return -1L
    }
  }
  return -1L
}

def ZipEntry.setSize(size: Long) {
  if ((size & 0xffffffff00000000L) != 0)
    throw(ERR_ILL_ARG)
  this.size = size
  this.known |= KNOWN_SIZE
}

def ZipEntry.getSize(): Long {
  return if ((this.known & KNOWN_SIZE) != 0) this.size & 0xffffffffL else -1L
}

def ZipEntry.setCompressedSize(csize: Long) {
  this.compressedSize = csize
}

def ZipEntry.getCompressedSize(): Long {
  return this.compressedSize
}

def ZipEntry.setCRC(crc: Int) {
  this.crc = crc
  this.known |= KNOWN_CRC
}

def ZipEntry.getCRC(): Int {
  return if ((this.known & KNOWN_CRC) != 0) this.crc else -1
}

def ZipEntry.setMethod(method: Int) {
  if (method != ZIP_STORED && method != ZIP_DEFLATED)
    throw(ERR_ILL_ARG)
  this.method = method
}

def ZipEntry.getMethod(): Int {
  return this.method
}

def ZipEntry.setExtra(extra: [Byte]) {
  if (extra == null) {
    this.extra = null
  } else {
    if (extra.len > 0xffff)
      throw(ERR_ILL_ARG)
    this.extra = extra
  }
}

def ZipEntry.getExtra(): [Byte] {
  return this.extra
}

def ZipEntry.setComment(comment: String) {
  if (comment != null && comment.len() > 0xffff)
    throw(ERR_ILL_ARG)
  this.comment = comment
}

def ZipEntry.getComment(): String {
  return this.comment
}

def ZipEntry.isDir(): Bool {
  var nlen = this.name.len()
  return nlen > 0 && this.name[nlen - 1] == '/'
}

def ZipEntry.tostr(): String {
  return this.name
}
