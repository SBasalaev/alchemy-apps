use "gzistream.eh"
use "crc32.eh"
use "deflater.eh"
use "inflaterstream.eh"
use "error.eh"
use "string.eh"

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
  var in = this.in;
  /* 1. Check the two magic bytes */
  var headCRC = new CRC32();
  var magic = in.read();
  if (magic < 0) {
    this.eos = true;
  } else {
    var magic2 = in.read();
    if ((magic + (magic2 << 8)) != GZIP_MAGIC)
      error(ERR_IO, "Error in GZIP header, bad magic code");
    headCRC.update(magic);
    headCRC.update(magic2);

    /* 2. Check the compression type (must be 8) */
    var CM = in.read();
    if (CM != DEFLATED)
      error(ERR_IO, "Error in GZIP header, data not in deflate format");
    headCRC.update(CM);

    /* 3. Check the flags */
    var flags = in.read();
    if (flags < 0)
      error(ERR_IO, "Early EOF in GZIP header");
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
      error(ERR_IO, "Reserved flag bits in GZIP header != 0");

    /* 4.-6. Skip the modification time, extra flags, and OS type */
    for (var i=0, i< 6, i += 1) {
      var readByte = in.read();
      if (readByte < 0)
        error(ERR_IO, "Early EOF in GZIP header");
      headCRC.update(readByte);
    }

    /* 7. Read extra field */
    if ((flags & FEXTRA) != 0) {
      /* Skip subfield id */
      for (var i=0, i<2, i += 1) {
        var readByte = in.read();
        if (readByte < 0)
          error(ERR_IO, "Early EOF in GZIP header");
        headCRC.update(readByte);
      }
      if (in.read() < 0 || in.read() < 0)
        error(ERR_IO, "Early EOF in GZIP header");

      var len1 = in.read();
      var len2 = in.read();
      if ((len1 < 0) || (len2 < 0))
        error(ERR_IO, "Early EOF in GZIP header");
      headCRC.update(len1);
      headCRC.update(len2);

      var extraLen = (len1 << 8) | len2;
      for (var i = 0, i < extraLen, i += 1) {
        var readByte = in.read();
        if (readByte < 0)
          error(ERR_IO, "Early EOF in GZIP header");
        headCRC.update(readByte);
      }
    }

    /* 8. Read file name */
    if ((flags & FNAME) != 0) {
      var readByte = in.read();
      while (readByte > 0) {
        headCRC.update(readByte);
        readByte = in.read();
      }
      if (readByte < 0)
        error(ERR_IO, "Early EOF in GZIP file name");
      headCRC.update(readByte);
    }

    /* 9. Read comment */
    if ((flags & FCOMMENT) != 0) {
      var readByte = in.read();
      while (readByte > 0) {
        headCRC.update(readByte);
        readByte = in.read();
      }

      if (readByte < 0)
        error(ERR_IO, "Early EOF in GZIP comment");
      headCRC.update(readByte);
    }

    /* 10. Read header CRC */
    if ((flags & FHCRC) != 0) {
      var crcval = in.read();
      if (crcval < 0)
        error(ERR_IO, "Early EOF in GZIP header");

      var tempByte = in.read();
      if (tempByte < 0)
        error(ERR_IO, "Early EOF in GZIP header");

      crcval = (crcval << 8) | tempByte;
      if (crcval != (headCRC.value & 0xffff))
        error(ERR_IO, "Header CRC value mismatch");
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
    var count = this.in.readarray(footer, 8-needed, needed);
    if (count <= 0)
      error(ERR_IO, "Early EOF in GZIP footer");
    needed -= count;
  }

  var crcval = (footer[0] & 0xff) | ((footer[1] & 0xff) << 8)
      | ((footer[2] & 0xff) << 16) | (footer[3] << 24);
  if (crcval != this.crc.value)
    error(ERR_IO, "GZIP crc sum mismatch, theirs \""
            + crcval.tohex() + "\" and ours \"" + this.crc.value.tohex());

  var total = (footer[4] & 0xff) | ((footer[5] & 0xff) << 8)
      | ((footer[6] & 0xff) << 16) | (footer[7] << 24);
  if (total != this.inf.byteswritten)
    error(ERR_IO, "Number of bytes mismatch");

  this.eos = true;
}

def GzIStream.new(in: IStream) {
  super(in, new Inflater(true), 4096);
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
  super.available();
}

def GzIStream.read(): Int {
  var onebytebuffer = new [Byte](1);
  var nread = this.readarray(onebytebuffer, 0, 1);
  if (nread > 0)
    onebytebuffer[0] & 0xff
  else
    -1;
}

def GzIStream.readarray(buf: [Byte], off: Int, len: Int): Int {
  if (this.in == null)
    error(ERR_IO, "stream is closed");

  if (!this.readGZIPHeader)
    this.readHeader();

  if (this.eos) {
    -1;
  } else if (len == 0) {
    0;
  } else {
    var numRead = super.readarray(buf, off, len);
    if (numRead > 0)
      this.crc.updatearray(buf, off, numRead);
    if (this.inf.finished())
      this.readFooter();
    numRead;
  }
}

def GzIStream.skip(n: Long): Long {
  if (this.inf == null)
    error(ERR_IO, "stream is closed");
  if (n < 0)
    error(ERR_ILL_ARG, null);

  if (n == 0) {
    0L;
  } else {
    var buflen = if (n < 2048) n else 2048;
    var tmpbuf = new [Byte](buflen);

    var skipped = 0L;
    while (n > 0L) {
      var numread = this.readarray(tmpbuf, 0, buflen);
      if (numread <= 0) {
        n = 0L;
      } else {
        n -= numread;
        skipped += numread;
        buflen = if (n < 2048) n else 2048;
      }
    }
    skipped;
  }
}
