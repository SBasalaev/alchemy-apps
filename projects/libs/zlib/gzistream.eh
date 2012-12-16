use "io.eh"

const GZIP_MAGIC = 0x8b1f;

type GzipIStream;

def new_gzistream(in: IStream): GzipIStream;

def GzipIStream.read(): Int;
def GzipIStream.readarray(buf: BArray, off: Int, len: Int): Int;
def GzipIStream.skip(n: Long): Long;
def GzipIStream.available(): Int;
def GzipIStream.reset();
def GzipIStream.close();
