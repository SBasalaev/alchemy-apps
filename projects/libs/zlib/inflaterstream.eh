use "inflater.eh"
use "io.eh"

type InflaterStream;

def new_inflaterstream(in: IStream, inf: Inflater, size: Int): InflaterStream;

def InflaterStream.available(): Int;
def InflaterStream.close();
def InflaterStream.read(): Int;
def InflaterStream.readarray(b: BArray, off: Int, len: Int): Int;
def InflaterStream.skip(n: Long): Long;
def InflaterStream.reset();
