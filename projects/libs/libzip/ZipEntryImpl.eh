use "ZipEntry.eh"

type ZipEntry {
  name: String,
  size: Int,
  compressedSize: Long = -1,
  crc: Int,
  comment: String,
  method: Byte = -1,
  known: Byte = 0,
  dostime: Int,
  time: Long,
  extra: [Byte],
  flags: Int,    /* used by ZipOutputStream */
  offset: Int    /* used by ZipFile and ZipOutputStream */
}

def ZipEntry.setDOSTime(dostime: Int)
def ZipEntry.getDOSTime(): Int
def ZipEntry.clone(): ZipEntry

use "zlib/inflaterstream.eh"
use "PartialIStream.eh"

type ZipEntryIStream {
 infin: InflaterStream,
 pin: PartialIStream
}