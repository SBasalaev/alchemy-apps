use "io.eh"
use "ZipEntry.eh"

type ZipArchive;

def ZipArchive.new(in: IStream);
def ZipArchive.entries(): [ZipEntry];
def ZipArchive.getEntry(name: String): ZipEntry;
def ZipArchive.getIStream(entry: ZipEntry): ZipEntryIStream;
def ZipArchive.size(): Int;