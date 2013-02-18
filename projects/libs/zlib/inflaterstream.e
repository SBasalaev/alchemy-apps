use "inflaterstream.eh"
use "error.eh"


def InflaterStream.new(in: IStream, inf: Inflater, size: Int): InflaterStream {
  this.in = in;
  this.inf = inf;
  this.buf = new [Byte](size);
}

def InflaterStream.available(): Int {
  if (this.inf == null)
    error(ERR_IO, "stream is closed");
  0;
}

def InflaterStream.close() {
  if (this.in != null)
    this.in.close();
  this.in = null;
}

def InflaterStream.fill() {
  if (this.in == null)
    error(ERR_IO, "stream is closed");

  this.len = this.in.readarray(this.buf, 0, this.buf.len);

  if (this.len < 0)
    error(ERR_IO, "Deflated stream ends early.");

  this.inf.set_input(this.buf, 0, this.len);
}

def InflaterStream.read(): Int {
  var onebytebuffer = new [Byte](1);
  var nread = this.readarray(onebytebuffer, 0, 1);
  if (nread > 0)
    onebytebuffer[0] & 0xff
  else
    -1;
}

def InflaterStream.readarray(b: [Byte], off: Int, len: Int): Int {
  if (this.inf == null)
    error(ERR_IO, "stream closed")
  if (len == 0) {
    0;
  } else {
    var break = false;
    var count = 0;
    while (!break) {
      count = this.inf.inflate(b, off, len);

      if (count > 0) {
        break = true;
      } else {
        if (this.inf.needs_dictionary() | this.inf.finished()) {
          break = true;
          count = -1;
        } else if (this.inf.needs_input()) {
          this.fill();
        } else {
          error(FAIL, "Don't know what to do");
        }
      }
    }
    count;
  }
}

def InflaterStream.skip(n: Long): Long {
  if (this.inf == null)
    error(ERR_IO, "stream closed");
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

def InflaterStream.reset() {
  error(ERR_IO, "reset() is not supported");
}
