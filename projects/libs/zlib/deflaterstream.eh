use "deflater.eh"
use "io.eh"

type DeflaterStream;

def new_deflaterstream(out: OStream, dfl: Deflater, size: Int): DeflaterStream;

def DeflaterStream.write(b: Int);
def DeflaterStream.writearray(buf: BArray, off: Int, len: Int);
def DeflaterStream.flush();
def DeflaterStream.finish();
def DeflaterStream.close();
