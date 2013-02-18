/* Adler32 checksum. */

type Adler32;

def Adler32.new(): Adler32;
def Adler32.reset();
def Adler32.update(bval: Int);
def Adler32.updatearray(buf: [Byte], off: Int, len: Int);
def Adler32.get_value(): Int;
