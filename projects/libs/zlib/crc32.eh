/* CRC32 checksum. */

type CRC32;

def new_crc32(): CRC32;
def CRC32.get_value(): Int;
def CRC32.reset();
def CRC32.update(bval: Int);
def CRC32.updatearray(buf: BArray, off: Int, len: Int);
