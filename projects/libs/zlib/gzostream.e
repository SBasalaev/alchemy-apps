use "crc32.eh"
use "deflaterstream.eh"
use "gzostream.eh"
use "gzistream.eh"

use "time.eh"
use "sys.eh"

type GzOStream < DeflaterStream {
  crc: CRC32
}

def GzOStream.new(out: OStream) {
  super(out, new Deflater(DEFAULT_COMPRESSION, true), 4096)
  this.crc = new CRC32()
  var mod_time = (systime() / 1000L).cast(Int)
  var gzipHeader = new [Byte] {
    /* The two magic bytes */
    GZIP_MAGIC,
    GZIP_MAGIC >> 8,

    /* The compression type */
    DEFLATED,

    /* The flags (not set) */
    0,

    /* The modification time */
    mod_time,
    mod_time >> 8,
    mod_time >> 16,
    mod_time >> 24,

    /* The extra flags */
    0,

    /* The OS type (unknown) */
    255
  };

  out.writeArray(gzipHeader, 0, gzipHeader.len);
}

def GzOStream.writeArray(buf: [Byte], off: Int, len: Int) {
  super.writeArray(buf, off, len);
  this.crc.updateArray(buf, off, len);
}

def GzOStream.write(b: Int) {
  this.writeArray(new [Byte] {b}, 0, 1)
}

def GzOStream.flush() {
  super.flush();
}

def GzOStream.close() {
  this.finish();
  this.out.close();
}

def GzOStream.finish() {
  super.finish();

  var totalin = this.dfl.bytesRead.cast(Int);
  var crcval = this.crc.value;

  var gzipFooter = new [Byte] {
    crcval,
    crcval >> 8,
    crcval >> 16,
    crcval >> 24,

    totalin,
    totalin >> 8,
    totalin >> 16,
    totalin >> 24
  };

  this.out.writeArray(gzipFooter, 0, gzipFooter.len);
}
