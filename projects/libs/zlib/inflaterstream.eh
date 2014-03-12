use "inflater.eh"
use "io.eh"

type InflaterStream {
  input: IStream,
  inf: Inflater,
  buf: [Byte],
  len: Int
}

def InflaterStream.new(input: IStream, inf: Inflater, size: Int);
def InflaterStream.available(): Int;
def InflaterStream.close();
def InflaterStream.read(): Int;
def InflaterStream.readArray(b: [Byte], off: Int, len: Int): Int;
def InflaterStream.skip(n: Long): Long;
def InflaterStream.reset();
