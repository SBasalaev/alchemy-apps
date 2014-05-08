use "ZipConstants.eh"

const ZIP_STORED = 0
const ZIP_DEFLATED = 8

type ZipEntry

def ZipEntry.new(name: String)
def ZipEntry.getName(): String
def ZipEntry.setTime(time: Long)
def ZipEntry.getTime(): Long
def ZipEntry.setSize(size: Long)
def ZipEntry.getSize(): Long
def ZipEntry.setCompressedSize(csize: Long)
def ZipEntry.getCompressedSize(): Long
def ZipEntry.setCRC(crc: Int)
def ZipEntry.getCRC(): Int
def ZipEntry.setMethod(method: Int)
def ZipEntry.getMethod(): Int
def ZipEntry.setExtra(extra: [Byte])
def ZipEntry.getExtra(): [Byte]
def ZipEntry.setComment(comment: String)
def ZipEntry.getComment(): String
def ZipEntry.isDir(): Bool
def ZipEntry.tostr(): String

type ZipEntryIStream

def ZipEntryIStream.read(): Int
def ZipEntryIStream.readArray(b: [Byte], off: Int, len: Int): Int
def ZipEntryIStream.skip(n: Long): Long
def ZipEntryIStream.close()
