type Inflater;

def new_inflater(nowrap: Bool): Inflater;
def Inflater.end();
def Inflater.finished(): Bool;
def Inflater.get_adler(): Int;
def Inflater.get_remaining(): Int;
def Inflater.get_bytesread(): Long;
def Inflater.get_byteswritten(): Long;
def Inflater.inflate(buf: BArray, off: Int, len: Int): Int;
def Inflater.needs_dictionary(): Bool;
def Inflater.needs_input(): Bool;
def Inflater.reset();
def Inflater.set_dictionary(buffer: BArray, off: Int, len: Int);
def Inflater.set_input(buf: BArray, off: Int, len: Int);
