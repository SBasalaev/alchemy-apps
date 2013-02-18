use "io.eh"

const GZIP_MAGIC = 0x8b1f;

type GzIStream;

def GzIStream.new(in: IStream): GzIStream;
def GzIStream.read(): Int;
def GzIStream.readarray(buf: [Byte], off: Int, len: Int): Int;
def GzIStream.skip(n: Long): Long;
def GzIStream.available(): Int;
def GzIStream.reset();
def GzIStream.close();
