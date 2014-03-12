use "deflaterstream.eh"

type GzOStream < DeflaterStream;

def GzOStream.new(out: OStream);
def GzOStream.writeArray(buf: [Byte], off: Int, len: Int);
def GzOStream.write(b: Int);
def GzOStream.flush();
def GzOStream.finish();
def GzOStream.close();
