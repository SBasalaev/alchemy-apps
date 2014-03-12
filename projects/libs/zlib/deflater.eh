/* Compression levels. */
const BEST_COMPRESSION = 9;
const BEST_SPEED = 1;
const DEFAULT_COMPRESSION = -1;
const NO_COMPRESSION = 0;

/* Strategies. */
const DEFAULT_STRATEGY = 0;
const FILTERED = 1;
const HUFFMAN_ONLY = 2;

/* Compression methods. */
const DEFLATED = 8;

type Deflater;

def Deflater.new(lvl: Int = DEFAULT_COMPRESSION, nowrap: Bool = false): Deflater;
def Deflater.reset();
def Deflater.end();
def Deflater.getAdler(): Int;
def Deflater.getBytesRead(): Long;
def Deflater.getBytesWritten(): Long;
def Deflater.flush();
def Deflater.finish();
def Deflater.finished(): Bool;
def Deflater.needsInput(): Bool;
def Deflater.setInput(input: [Byte], off: Int, len: Int);
def Deflater.setLevel(lvl: Int);
def Deflater.setStrategy(stgy: Int);
def Deflater.setDictionary(dict: [Byte], offset: Int, length: Int);
def Deflater.deflate(output: [Byte], offset: Int, length: Int): Int;
