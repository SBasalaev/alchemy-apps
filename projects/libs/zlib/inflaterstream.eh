use "inflater.eh"
use "io.eh"

type InflaterStream {
  in: IStream,
  inf: Inflater,
  buf: [Byte],
  len: Int
}

def InflaterStream.new(in: IStream, inf: Inflater, size: Int): InflaterStream;
def InflaterStream.available(): Int;
def InflaterStream.close();
def InflaterStream.read(): Int;
def InflaterStream.readarray(b: [Byte], off: Int, len: Int): Int;
def InflaterStream.skip(n: Long): Long;
def InflaterStream.reset();
