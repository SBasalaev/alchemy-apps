use "ZipEntry.eh"
use "io.eh"

type ZipOStream

def ZipOStream.new(out: OStream)
def ZipOStream.setComment(comment: String)
def ZipOStream.setMethod(method: Int)
def ZipOStream.setLevel(level: Int)
def ZipOStream.putNextEntry(entry: ZipEntry)
def ZipOStream.closeEntry()
def ZipOStream.write(b: Int)
def ZipOStream.writeArray(b: [Byte], off: Int, len: Int)
def ZipOStream.finish()
def ZipOStream.close()
