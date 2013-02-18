use "streammanipulator.eh"
use "error.eh"
use "sys.eh"

type StreamManipulator {
  window: [Byte],
  window_start: Int,
  window_end: Int,

  buffer: Int,
  bits_in_buffer: Int
}

def new_StreamManipulator(): StreamManipulator {
  new StreamManipulator {
    window_start = 0,
    window_end = 0,
    buffer = 0,
    bits_in_buffer = 0
  }
}

def StreamManipulator.peekBits(n: Int): Int {
  if (this.bits_in_buffer < n) {
    if (this.window_start == this.window_end) {
      -1;
    } else {
      var buf = this.window[this.window_start] & 0xff;
      this.window_start += 1;
      buf |= (this.window[this.window_start] & 0xff) << 8;
      this.window_start += 1;
      this.buffer |= buf << this.bits_in_buffer;
      this.bits_in_buffer += 16;
      this.buffer & ((1 << n) - 1);
    }
  } else {
    this.buffer & ((1 << n) - 1);
  }
}

def StreamManipulator.dropBits(n: Int) {
  this.buffer >>>= n;
  this.bits_in_buffer -= n;
}

def StreamManipulator.getBits(n: Int): Int {
  var bits = this.peekBits(n);
  if (bits >= 0) this.dropBits(n);
  bits;
}

def StreamManipulator.getAvailableBits(): Int {
  this.bits_in_buffer;
}

def StreamManipulator.getAvailableBytes(): Int {
  this.window_end - this.window_start + (this.bits_in_buffer >> 3);
}

def StreamManipulator.skipToByteBoundary() {
  this.buffer >>= (this.bits_in_buffer & 7);
  this.bits_in_buffer &= ~7;
}

def StreamManipulator.needsInput(): Bool {
  this.window_start == this.window_end;
}

def StreamManipulator.copyBytes(output: [Byte], offset: Int, length: Int): Int {
  if (length < 0)
    error(ERR_ILL_ARG, "length negative");
  if ((this.bits_in_buffer & 7) != 0)
    /* bits_in_buffer may only be 0 or 8 */
    error(ERR_ILL_STATE, "Bit buffer is not aligned!");

  var count = 0;
  while (this.bits_in_buffer > 0 && length > 0) {
    output[offset] = this.buffer;
    offset += 1;
    this.buffer >>>= 8;
    this.bits_in_buffer -= 8;
    length -= 1;
    count += 1;
  }
  if (length == 0) {
    count;
  } else {
    var avail = this.window_end - this.window_start;
    if (length > avail)
      length = avail;
    acopy(this.window, this.window_start, output, offset, length);
    this.window_start += length;

    if (((this.window_start - this.window_end) & 1) != 0) {
      /* We always want an even number of bytes in input, see peekBits */
      this.buffer = (this.window[this.window_start] & 0xff);
      this.window_start += 1;
      this.bits_in_buffer = 8;
    }
    count + length;
  }
}

def StreamManipulator.reset() {
  this.window_start = 0;
  this.window_end = 0;
  this.buffer = 0;
  this.bits_in_buffer = 0;
}

def StreamManipulator.setInput(buf: [Byte], off: Int, len: Int) {
  if (this.window_start < this.window_end)
    error(ERR_ILL_STATE, "Old input was not completely processed");

  var end = off + len;

  /* We want to throw a range error early. The check is very
   * tricky: it also handles integer wrap around.
   */
  if (0 > off || off > end || end > buf.len)
    error(ERR_RANGE, null);

  if ((len & 1) != 0) {
    /* We always want an even number of bytes in input, see peekBits */
    this.buffer |= (buf[off] & 0xff) << this.bits_in_buffer;
    off += 1;
    this.bits_in_buffer += 8;
  }

  this.window = buf;
  this.window_start = off;
  this.window_end = end;
}
