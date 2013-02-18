use "io.eh"

type GzOStream;

def GzOStream.new(out: OStream);
def GzOStream.writearray(buf: [Byte], off: Int, len: Int);
def GzOStream.write(b: Int);
def GzOStream.flush();
def GzOStream.finish();
def GzOStream.close();
