type PartialIStream

def PartialIStream.new(buf: [Byte], offset: Int, len: Int)
def PartialIStream.setLength(length: Int)
def PartialIStream.addDummyByte()
def PartialIStream.available(): Int
def PartialIStream.read(): Int
def PartialIStream.readArray(b: [Byte], off: Int, len: Int): Int
def PartialIStream.readFully(buf: [Byte], off: Int = 0, len: Int = -1)
def PartialIStream.readLeShort(): Int
def PartialIStream.readLeInt(): Int
def PartialIStream.readString(length: Int): String
def PartialIStream.skip(n: Int): Int
def PartialIStream.seek(newpos: Int)
