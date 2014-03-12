type Inflater;

def Inflater.new(nowrap: Bool = false): Inflater;
def Inflater.end();
def Inflater.finished(): Bool;
def Inflater.getAdler(): Int;
def Inflater.getRemaining(): Int;
def Inflater.getBytesRead(): Long;
def Inflater.getBytesWritten(): Long;
def Inflater.inflate(buf: [Byte], off: Int, len: Int): Int;
def Inflater.needsDictionary(): Bool;
def Inflater.needsInput(): Bool;
def Inflater.reset();
def Inflater.setDictionary(buffer: [Byte], off: Int, len: Int);
def Inflater.setInput(buf: [Byte], off: Int, len: Int);
