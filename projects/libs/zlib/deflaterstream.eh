use "deflater.eh"
use "io.eh"

type DeflaterStream {
  out: OStream,
  dfl: Deflater,
  buf: [Byte]
}

def DeflaterStream.new(out: OStream, dfl: Deflater, size: Int = 4096);
def DeflaterStream.write(b: Int);
def DeflaterStream.writeArray(buf: [Byte], off: Int, len: Int);
def DeflaterStream.flush();
def DeflaterStream.finish();
def DeflaterStream.close();
