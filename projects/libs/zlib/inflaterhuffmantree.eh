use "streammanipulator.eh"

type InflaterHuffmanTree;

def new_InflaterHuffmanTree(codeLengths: [Byte]): InflaterHuffmanTree;

def defLitLenTree(): InflaterHuffmanTree;
def defDistTree(): InflaterHuffmanTree;

def InflaterHuffmanTree.getSymbol(input: StreamManipulator): Int;
