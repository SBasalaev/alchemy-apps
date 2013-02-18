use "adler32.eh"

/** largest prime smaller than 65536 */
const BASE = 65521;

type Adler32 {
  checksum: Int = 1
}

def Adler32.new() { }

def Adler32.reset() {
  this.checksum = 1
}

def Adler32.update(bval: Int) {
  var s1 = this.checksum & 0xffff;
  var s2 = this.checksum >>> 16;

  s1 = (s1 + (bval & 0xFF)) % BASE;
  s2 = (s1 + s2) % BASE;

  this.checksum = (s2 << 16) + s1;
}

def Adler32.updatearray(buf: [Byte], off: Int, len: Int) {
  //(By Per Bothner)
  var s1 = this.checksum & 0xffff;
  var s2 = this.checksum >>> 16;

  while (len > 0) {
    // We can defer the modulo operation:
    // s1 maximally grows from 65521 to 65521 + 255 * 3800
    // s2 maximally grows by 3800 * median(s1) = 2090079800 < 2^31
    var n = 3800;
    if (n > len) n = len;
    len -= n;
    while ({n-=1; n >= 0}) {
      s1 = s1 + (buf[off] & 0xFF);
      off += 1;
      s2 = s2 + s1;
    }
    s1 %= BASE;
    s2 %= BASE;
  }

  this.checksum = (s2 << 16) | s1;
}

def Adler32.get_value(): Int {
  this.checksum
}
