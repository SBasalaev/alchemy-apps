use "gzistream.eh"
use "crc32.eh"
use "deflater.eh"

const FTEXT = 0x1;
const FHCRC = 0x2;
const FEXTRA = 0x4;
const FNAME = 0x8;
const FCOMMENT = 0x10;

type GzIStream < InflaterStream {
  crc: CRC32,
  eos: Bool,
  readGZIPHeader: Bool
}

def GzIStream.readHeader() {
  var input = this.input;
  /* 1. Check the two magic bytes */
  var headCRC = new CRC32();
  var magic = input.read();
  if (magic < 0) {
    this.eos = true;
  } else {
    var magic2 = input.read();
    if ((magic + (magic2 << 8)) != GZIP_MAGIC)
      throw(ERR_IO, "Error in GZIP header, bad magic code");
    headCRC.update(magic);
    headCRC.update(magic2);

    /* 2. Check the compression type (must be 8) */
    var CM = input.read();
    if (CM != DEFLATED)
      throw(ERR_IO, "Error in GZIP header, data not in deflate format");
    headCRC.update(CM);

    /* 3. Check the flags */
    var flags = input.read();
    if (flags < 0)
      throw(ERR_IO, "Early EOF in GZIP header");
    headCRC.update(flags);

    /*    This flag byte is divided into individual bits as follows:

          bit 0   FTEXT
          bit 1   FHCRC
          bit 2   FEXTRA
          bit 3   FNAME
          bit 4   FCOMMENT
          bit 5   reserved
          bit 6   reserved
          bit 7   reserved
    */

    /* 3.1 Check the reserved bits are zero */
    if ((flags & 0xd0) != 0)
      throw(ERR_IO, "Reserved flag bits in GZIP header != 0");

    /* 4.-6. Skip the modification time, extra flags, and OS type */
    for (var i=0, i< 6, i += 1) {
      var readByte = input.read();
      if (readByte < 0)
        throw(ERR_IO, "Early EOF in GZIP header");
      headCRC.update(readByte);
    }

    /* 7. Read extra field */
    if ((flags & FEXTRA) != 0) {
      /* Skip subfield id */
      for (var i=0, i<2, i += 1) {
        var readByte = input.read();
        if (readByte < 0)
          throw(ERR_IO, "Early EOF in GZIP header");
        headCRC.update(readByte);
      }
      if (input.read() < 0 || input.read() < 0)
        throw(ERR_IO, "Early EOF in GZIP header");

      var len1 = input.read();
      var len2 = input.read();
      if ((len1 < 0) || (len2 < 0))
        throw(ERR_IO, "Early EOF in GZIP header");
      headCRC.update(len1);
      headCRC.update(len2);

      var extraLen = (len1 << 8) | len2;
      for (var i = 0, i < extraLen, i += 1) {
        var readByte = input.read();
        if (readByte < 0)
          throw(ERR_IO, "Early EOF in GZIP header");
        headCRC.update(readByte);
      }
    }

    /* 8. Read file name */
    if ((flags & FNAME) != 0) {
      var readByte = input.read();
      while (readByte > 0) {
        headCRC.update(readByte);
        readByte = input.read();
      }
      if (readByte < 0)
        throw(ERR_IO, "Early EOF in GZIP file name");
      headCRC.update(readByte);
    }

    /* 9. Read comment */
    if ((flags & FCOMMENT) != 0) {
      var readByte = input.read();
      while (readByte > 0) {
        headCRC.update(readByte);
        readByte = input.read();
      }

      if (readByte < 0)
        throw(ERR_IO, "Early EOF in GZIP comment");
      headCRC.update(readByte);
    }

    /* 10. Read header CRC */
    if ((flags & FHCRC) != 0) {
      var crcval = input.read();
      if (crcval < 0)
        throw(ERR_IO, "Early EOF in GZIP header");

      var tempByte = input.read();
      if (tempByte < 0)
        throw(ERR_IO, "Early EOF in GZIP header");

      crcval = (crcval << 8) | tempByte;
      if (crcval != (headCRC.value & 0xffff))
        throw(ERR_IO, "Header CRC value mismatch");
    }

    this.readGZIPHeader = true;
  }
}

def GzIStream.readFooter() {
  var footer = new [Byte](8);
  var avail = this.inf.remaining;
  if (avail > 8)
    avail = 8;
  acopy(this.buf, this.len - this.inf.remaining, footer, 0, avail);
  var needed = 8 - avail;
  while (needed > 0) {
    var count = this.input.readArray(footer, 8-needed, needed);
    if (count <= 0)
      throw(ERR_IO, "Early EOF in GZIP footer");
    needed -= count;
  }

  var crcval = (footer[0] & 0xff) | ((footer[1] & 0xff) << 8)
      | ((footer[2] & 0xff) << 16) | (footer[3] << 24);
  if (crcval != this.crc.value)
    throw(ERR_IO, "GZIP crc sum mismatch, theirs \""
            + crcval.tohex() + "\" and ours \"" + this.crc.value.tohex());

  var total = (footer[4] & 0xff) | ((footer[5] & 0xff) << 8)
      | ((footer[6] & 0xff) << 16) | (footer[7] << 24);
  if (total != this.inf.bytesWritten)
    throw(ERR_IO, "Number of bytes mismatch");

  this.eos = true;
}

def GzIStream.new(input: IStream) {
  super(input, new Inflater(true), 4096);
  this.crc = new CRC32();
  this.readHeader();
}

def GzIStream.close() {
  super.close();
}

def GzIStream.reset() {
  super.reset();
}

def GzIStream.available(): Int {
  return super.available();
}

def GzIStream.read(): Int {
  var onebytebuffer = new [Byte](1);
  var nread = this.readArray(onebytebuffer, 0, 1);
  if (nread > 0)
    return onebytebuffer[0] & 0xff
  else
    return -1;
}

def GzIStream.readArray(buf: [Byte], off: Int, len: Int): Int {
  if (this.input == null)
    throw(ERR_IO, "stream is closed");

  if (!this.readGZIPHeader)
    this.readHeader();

  if (this.eos) {
    return -1;
  } else if (len == 0) {
    return 0;
  } else {
    var numRead = super.readArray(buf, off, len);
    if (numRead > 0)
      this.crc.updateArray(buf, off, numRead);
    if (this.inf.finished())
      this.readFooter();
    return numRead;
  }
}

def GzIStream.skip(n: Long): Long {
  if (this.inf == null)
    throw(ERR_IO, "stream is closed");
  if (n < 0)
    throw(ERR_ILL_ARG, null);

  if (n == 0) {
    return 0L;
  } else {
    var buflen = if (n < 2048) n else 2048;
    var tmpbuf = new [Byte](buflen);

    var skipped = 0L;
    while (n > 0L) {
      var numread = this.readArray(tmpbuf, 0, buflen);
      if (numread <= 0) {
        n = 0L;
      } else {
        n -= numread;
        skipped += numread;
        buflen = if (n < 2048) n else 2048;
      }
    }
    return skipped;
  }
}
