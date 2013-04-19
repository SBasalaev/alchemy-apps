use "io.eh"
use "ZipEntry.eh"

type ZipIStream;

def ZipIStream.new(in: IStream);
def ZipIStream.getNextEntry(): ZipEntry;
def ZipIStream.closeEntry();
def ZipIStream.available(): Int;
def ZipIStream.read(): Int;
def ZipIStream.readarray(b: [Byte], off: Int, len: Int): Int;
def ZipIStream.skip(n: Long): Long;
def ZipIStream.close();
