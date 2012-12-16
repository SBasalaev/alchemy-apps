use "crc32.eh"
use "deflater.eh"
use "gzostream.eh"
use "gzistream.eh"

use "time.eh"
use "error.eh"

type GzipOStream {
  out: OStream,
  dfl: Deflater,
  buf: BArray,
  crc: CRC32
}

def new_gzostream(out: OStream): GzipOStream {
  var gzout = new GzipOStream {
    out = out,
    dfl = new_deflater(DEFAULT_COMPRESSION, true),
    buf = new BArray(4096),
    crc = new_crc32()
  }
  var mod_time = cast (Int) (systime() / 1000L);
  var gzipHeader = new BArray {
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

  out.writearray(gzipHeader, 0, gzipHeader.len);

  gzout
}

def GzipOStream.deflate() {
  var break = false;
  while (!break && !this.dfl.needs_input()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);

    if (len <= 0)
      break = true;
    else
      this.out.writearray(this.buf, 0, len);
  }

  if (!this.dfl.needs_input())
    error(FAIL, "Can't deflate all input?");
}

def GzipOStream.writearray(buf: BArray, off: Int, len: Int) {
  this.dfl.set_input(buf, off, len);
  this.deflate();
  this.crc.updatearray(buf, off, len);
}

def GzipOStream.write(b: Int) {
  this.writearray(new BArray {b}, 0, 1)
}

def GzipOStream.flush() {
  this.dfl.flush();
  this.deflate();
  this.out.flush();
}

def GzipOStream.close() {
  this.finish();
  this.out.close();
}

def GzipOStream.finish() {
  this.dfl.finish();
  var break = false;
  while (!break && !this.dfl.finished()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);
    if (len <= 0)
      break = true;
    else
      this.out.writearray(this.buf, 0, len);
  }
  if (!this.dfl.finished())
    error(FAIL, "Can't deflate all input?");
  this.out.flush();

  var totalin = cast (Int) this.dfl.bytesread;
  var crcval = this.crc.value;

  var gzipFooter = new BArray {
    crcval,
    crcval >> 8,
    crcval >> 16,
    crcval >> 24,

    totalin,
    totalin >> 8,
    totalin >> 16,
    totalin >> 24
  };

  this.out.writearray(gzipFooter, 0, gzipFooter.len);
}
