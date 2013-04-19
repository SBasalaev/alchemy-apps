use "ZipEntry.eh"
use "io.eh"

type ZipOStream;

def ZipOStream.new(out: OStream);
def ZipOStream.set_comment(comment: String);
def ZipOStream.set_method(method: Int);
def ZipOStream.set_level(level: Int);
def ZipOStream.putNextEntry(entry: ZipEntry);
def ZipOStream.closeEntry();
def ZipOStream.write(b: Int);
def ZipOStream.writearray(b: [Byte], off: Int, len: Int);
def ZipOStream.finish();
def ZipOStream.close();
