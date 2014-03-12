use "streammanipulator.eh"

type InflaterHuffmanTree;

def InflaterHuffmanTree.new(codeLengths: [Byte]);

def defLitLenTree(): InflaterHuffmanTree;
def defDistTree(): InflaterHuffmanTree;

def InflaterHuffmanTree.getSymbol(input: StreamManipulator): Int;
