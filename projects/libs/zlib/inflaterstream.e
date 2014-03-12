use "inflaterstream.eh"

def InflaterStream.new(input: IStream, inf: Inflater, size: Int) {
  this.input = input;
  this.inf = inf;
  this.buf = new [Byte](size);
}

def InflaterStream.available(): Int {
  if (this.inf == null)
    throw(ERR_IO, "stream is closed");
  return 0;
}

def InflaterStream.close() {
  if (this.input != null)
    this.input.close();
  this.input = null;
}

def InflaterStream.fill() {
  if (this.input == null)
    throw(ERR_IO, "stream is closed");

  this.len = this.input.readArray(this.buf, 0, this.buf.len);

  if (this.len < 0)
    throw(ERR_IO, "Deflated stream ends early.");

  this.inf.setInput(this.buf, 0, this.len);
}

def InflaterStream.read(): Int {
  var onebytebuffer = new [Byte](1);
  var nread = this.readArray(onebytebuffer, 0, 1);
  if (nread > 0)
    return onebytebuffer[0] & 0xff
  else
    return -1;
}

def InflaterStream.readArray(b: [Byte], off: Int, len: Int): Int {
  if (this.inf == null)
    throw(ERR_IO, "stream closed")
  if (len == 0) return 0;
  while (true) {
    var count = this.inf.inflate(b, off, len);

    if (count > 0) {
      return count;
    }
    if (this.inf.needsDictionary() | this.inf.finished()) {
      return -1;
    }
    if (this.inf.needsInput()) {
      this.fill();
    } else {
      throw(FAIL, "Don't know what to do");
    }
  }
  // May cause 'Unreachable statement' in future versions
  return 0;
}

def InflaterStream.skip(n: Long): Long {
  if (this.inf == null)
    throw(ERR_IO, "stream closed");
  if (n < 0)
    throw(ERR_ILL_ARG, null);

  if (n == 0) {
    return 0L;
  }
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

def InflaterStream.reset() {
  throw(ERR_IO, "reset() is not supported");
}
