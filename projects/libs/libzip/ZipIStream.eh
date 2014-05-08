use "io.eh"
use "ZipEntry.eh"

type ZipIStream

def ZipIStream.new(inp: IStream)
def ZipIStream.getNextEntry(): ZipEntry
def ZipIStream.closeEntry()
def ZipIStream.available(): Int
def ZipIStream.read(): Int
def ZipIStream.readArray(b: [Byte], off: Int, len: Int): Int
def ZipIStream.skip(n: Long): Long
def ZipIStream.close()
