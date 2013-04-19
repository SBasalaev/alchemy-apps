use "ZipConstants.eh"

const ZIP_STORED = 0;
const ZIP_DEFLATED = 8;

type ZipEntry;

def ZipEntry.new(name: String);
def ZipEntry.get_name(): String;
def ZipEntry.set_time(time: Long);
def ZipEntry.get_time(): Long;
def ZipEntry.set_size(size: Long);
def ZipEntry.get_size(): Long;
def ZipEntry.set_compressedsize(csize: Long);
def ZipEntry.get_compressedsize(): Long;
def ZipEntry.set_crc(crc: Int);
def ZipEntry.get_crc(): Int;
def ZipEntry.set_method(method: Int);
def ZipEntry.get_method(): Int;
def ZipEntry.set_extra(extra: [Byte]);
def ZipEntry.get_extra(): [Byte];
def ZipEntry.set_comment(comment: String);
def ZipEntry.get_comment(): String;
def ZipEntry.isdir(): Bool;
def ZipEntry.tostr(): String;

type ZipEntryIStream;

def ZipEntryIStream.read(): Int;
def ZipEntryIStream.readarray(b: [Byte], off: Int, len: Int): Int;
def ZipEntryIStream.skip(n: Long): Long;
def ZipEntryIStream.close();
