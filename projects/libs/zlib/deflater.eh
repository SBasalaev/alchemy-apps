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
def Deflater.get_adler(): Int;
def Deflater.get_bytesread(): Long;
def Deflater.get_byteswritten(): Long;
def Deflater.flush();
def Deflater.finish();
def Deflater.finished(): Bool;
def Deflater.needs_input(): Bool;
def Deflater.set_input(input: [Byte], off: Int, len: Int);
def Deflater.set_level(lvl: Int);
def Deflater.set_strategy(stgy: Int);
def Deflater.set_dictionary(dict: [Byte], offset: Int, length: Int);
def Deflater.deflate(output: [Byte], offset: Int, length: Int): Int;
