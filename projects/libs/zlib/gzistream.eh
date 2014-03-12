use "inflaterstream.eh"

const GZIP_MAGIC = 0x8b1f;

type GzIStream < InflaterStream;

def GzIStream.new(input: IStream): GzIStream;
def GzIStream.read(): Int;
def GzIStream.readArray(buf: [Byte], off: Int, len: Int): Int;
def GzIStream.skip(n: Long): Long;
def GzIStream.available(): Int;
def GzIStream.reset();
def GzIStream.close();
