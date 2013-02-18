use "crc32.eh"

var crc_table: [Int];

def make_crc_table() {
  var table = new [Int](256);
  for (var n = 0, n < 256, n += 1) {
    var c = n;
    for (var k = 7, k >= 0, k -= 1) {
      if ((c & 1) != 0)
        c = 0xedb88320 ^ (c >>> 1)
      else
        c = c >>> 1;
    }
    table[n] = c;
  }
  crc_table = table;
}

type CRC32 {
  crc: Int = 0
}

def CRC32.new(): CRC32 {
  if (crc_table == null) make_crc_table();
}

def CRC32.get_value(): Int {
  this.crc;
}

def CRC32.reset() {
  this.crc = 0;
}

def CRC32.update(bval: Int) {
  var c = ~this.crc;
  c = crc_table[(c ^ bval) & 0xff] ^ (c >>> 8);
  this.crc = ~c;
}

def CRC32.updatearray(buf: [Byte], off: Int, len: Int) {
  var c = ~this.crc;
  var table = crc_table;
  while (len > 0) {
    c = table[(c ^ buf[off]) & 0xff] ^ (c >>> 8);
    len -= 1;
    off += 1;
  }
  this.crc = ~c;
}
