use "sys.eh"

use "deflaterconstants.eh"
use "pendingbuffer.eh"

type PendingBuffer {
  buf: [Byte],
  start: Int,
  end: Int,
  bits: Int,
  bitCount: Int
}

def new_PendingBuffer(bufsize: Int): PendingBuffer {
  new PendingBuffer {
    buf = new [Byte](bufsize),
    start = 0,
    end = 0,
    bits = 0,
    bitCount = 0
  }
}

def PendingBuffer.reset() {
  this.start = 0;
  this.end = 0;
  this.bitCount = 0;
}

def PendingBuffer.writeByte(b: Int) {
  this.buf[this.end] = b;
  this.end += 1;
}

def PendingBuffer.writeShort(s: Int) {
  this.buf[this.end] = s;
  this.end += 1;
  this.buf[this.end] = s >> 8;
  this.end += 1;
}

def PendingBuffer.writeInt(s: Int) {
  this.buf[this.end] = s;
  this.end += 1;
  this.buf[this.end] = s >> 8;
  this.end += 1;
  this.buf[this.end] = s >> 16;
  this.end += 1;
  this.buf[this.end] = s >> 24;
  this.end += 1;
}

def PendingBuffer.writeBlock(block: [Byte], offset: Int, len: Int) {
  acopy(block, offset, this.buf, this.end, len);
  this.end += len;
}

def PendingBuffer.getBitCount(): Int {
  this.bitCount;
}

def PendingBuffer.alignToByte() {
  if (this.bitCount > 0) {
    this.buf[this.end] = this.bits;
    this.end += 1;
    if (this.bitCount > 8) {
      this.buf[this.end] = this.bits >>> 8;
      this.end += 1;
    }
  }
  this.bits = 0;
  this.bitCount = 0;
}

def PendingBuffer.writeBits(b: Int, count: Int) {
  this.bits |= b << this.bitCount;
  this.bitCount += count;
  if (this.bitCount >= 16) {
    this.buf[this.end] = this.bits;
    this.end += 1;
    this.buf[this.end] = this.bits >>> 8;
    this.end += 1;
    this.bits >>>= 16;
    this.bitCount -= 16;
  }
}

def PendingBuffer.writeShortMSB(s: Int) {
  this.buf[this.end] = s >> 8;
  this.end += 1;
  this.buf[this.end] = s;
  this.end += 1;
}

def PendingBuffer.isFlushed(): Bool {
  this.end == 0;
}

def PendingBuffer.flush(output: [Byte], offset: Int, length: Int): Int {
  if (this.bitCount >= 8) {
    this.buf[this.end] = this.bits;
    this.end += 1;
    this.bits >>>= 8;
    this.bitCount -= 8;
  }
  if (length > this.end - this.start) {
    length = this.end - this.start;
    acopy(this.buf, this.start, output, offset, length);
    this.start = 0;
    this.end = 0;
  } else {
    acopy(this.buf, this.start, output, offset, length);
    this.start += length;
  }
  length;
}

def PendingBuffer.toByteArray(): [Byte] {
  var ret = new [Byte](this.end - this.start);
  acopy(this.buf, this.start, ret, 0, ret.len);
  this.start = 0;
  this.end = 0;
  ret;
}
