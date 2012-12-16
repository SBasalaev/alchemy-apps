/* Adler32 checksum. */

type Adler32;

def new_adler32(): Adler32;
def Adler32.reset();
def Adler32.update(bval: Int);
def Adler32.updatearray(buf: BArray, off: Int, len: Int);
def Adler32.get_value(): Int;
