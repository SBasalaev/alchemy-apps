use "deflaterstream.eh"
use "error.eh"

def DeflaterStream.new(out: OStream, dfl: Deflater, size: Int = 4096) {
  this.out = out;
  this.dfl = dfl;
  this.buf = new [Byte](size)
}

def DeflaterStream.deflate() {
  while (!this.dfl.needsInput()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);

    if (len <= 0)
      break;
    else
      this.out.writeArray(this.buf, 0, len);
  }

  if (!this.dfl.needsInput())
    throw(FAIL, "Can't deflate all input?");
}

def DeflaterStream.write(b: Int) {
  this.writeArray(new [Byte] {b}, 0, 1)
}

def DeflaterStream.writeArray(buf: [Byte], off: Int, len: Int) {
  this.dfl.setInput(buf, off, len);
  this.deflate();
}

def DeflaterStream.flush() {
  this.dfl.flush();
  this.deflate();
  this.out.flush();
}

def DeflaterStream.finish() {
  this.dfl.finish();
  while (!this.dfl.finished()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);
    if (len <= 0)
      break;
    else
      this.out.writeArray(this.buf, 0, len);
  }
  if (!this.dfl.finished())
    throw(FAIL, "Can't deflate all input?");
  this.out.flush();
}

def DeflaterStream.close() {
  this.finish();
  this.out.close();
}
