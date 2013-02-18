/* CRC32 checksum. */

type CRC32;

def CRC32.new(): CRC32;
def CRC32.get_value(): Int;
def CRC32.reset();
def CRC32.update(bval: Int);
def CRC32.updatearray(buf: [Byte], off: Int, len: Int);
