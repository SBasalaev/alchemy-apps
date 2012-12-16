use "inflaterhuffmantree.eh"
use "streammanipulator.eh"

type InflaterDynHeader;

def new_InflaterDynHeader(): InflaterDynHeader;

def InflaterDynHeader.buildLitLenTree(): InflaterHuffmanTree;
def InflaterDynHeader.buildDistTree(): InflaterHuffmanTree;
def InflaterDynHeader.decode(input: StreamManipulator): Bool;
