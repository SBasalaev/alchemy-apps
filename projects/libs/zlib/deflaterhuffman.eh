use "pendingbuffer.eh"

type DeflaterHuffman;

def bitReverse(value: Int): Int;

def new_DeflaterHuffman(pending: PendingBuffer): DeflaterHuffman;

def DeflaterHuffman.reset();
def DeflaterHuffman.sendAllTrees(blTreeCodes: Int);
def DeflaterHuffman.compressBlock();
def DeflaterHuffman.flushStoredBlock(stored: BArray, stored_offset: Int, stored_len: Int, lastBlock: Bool);
def DeflaterHuffman.flushBlock(stored: BArray, stored_offset: Int, stored_len: Int, lastBlock: Bool);
def DeflaterHuffman.isFull(): Bool;
def DeflaterHuffman.tallyLit(lit: Int): Bool;
def DeflaterHuffman.tallyDist(dist: Int, len: Int): Bool;
