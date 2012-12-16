use "io.eh"

type GzipOStream;

def new_gzostream(out: OStream): GzipOStream;

def GzipOStream.writearray(buf: BArray, off: Int, len: Int);
def GzipOStream.write(b: Int);
def GzipOStream.flush();
def GzipOStream.finish();
def GzipOStream.close();
