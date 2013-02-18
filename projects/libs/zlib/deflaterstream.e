use "deflaterstream.eh"
use "error.eh"

def DeflaterStream.new(out: OStream, dfl: Deflater, size: Int = 4096) {
  this.out = out;
  this.dfl = dfl;
  this.buf = new [Byte](size)
}

def DeflaterStream.deflate() {
  var break = false;
  while (!break && !this.dfl.needs_input()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);

    if (len <= 0)
      break = true
    else
      this.out.writearray(this.buf, 0, len);
  }

  if (!this.dfl.needs_input())
    error(FAIL, "Can't deflate all input?");
}

def DeflaterStream.write(b: Int) {
  this.writearray(new [Byte] {b}, 0, 1)
}

def DeflaterStream.writearray(buf: [Byte], off: Int, len: Int) {
  this.dfl.set_input(buf, off, len);
  this.deflate();
}

def DeflaterStream.flush() {
  this.dfl.flush();
  this.deflate();
  this.out.flush();
}

def DeflaterStream.finish() {
  this.dfl.finish();
  var break = false;
  while (!break && !this.dfl.finished()) {
    var len = this.dfl.deflate(this.buf, 0, this.buf.len);
    if (len <= 0)
      break = true
    else
      this.out.writearray(this.buf, 0, len);
  }
  if (!this.dfl.finished())
    error(FAIL, "Can't deflate all input?");
  this.out.flush();
}

def DeflaterStream.close() {
  this.finish();
  this.out.close();
}
