use "inflaterhuffmantree.eh"
use "deflaterhuffman.eh"

use "error.eh"

const MAX_BITLEN = 15;

type InflaterHuffmanTree {
  tree: [Int]
}

def InflaterHuffmanTree.buildTree(codeLengths: BArray) {
  // In Alchemy 2.0 [Int] is an object array, so to be safe we fill it with zeros
  var blCount = new [Int](MAX_BITLEN+1);
  var nextCode = new [Int](MAX_BITLEN+1);
  for (var i=MAX_BITLEN, i>=0, i-=1) {
    blCount[i] = 0;
    nextCode[i] = 0;
  }
  for (var i = 0, i < codeLengths.len, i += 1) {
    var bits = codeLengths[i];
    if (bits > 0)
      blCount[bits] += 1;
  }

  var max = 0;
  var code = 0;
  var treeSize = 512;
  for (var bits = 1, bits <= MAX_BITLEN, bits += 1) {
    nextCode[bits] = code;
    if (blCount[bits] > 0)
      max = bits;
    code += blCount[bits] << (16 - bits);
    if (bits >= 10) {
      /* We need an extra table for bit lengths >= 10. */
      var start = nextCode[bits] & 0x1ff80;
      var end   = code & 0x1ff80;
      treeSize += (end - start) >> (16 - bits);
    }
  }
  if (code != 65536 && max > 1)
    error(FAIL, "incomplete dynamic bit lengths tree");

  /* Now create and fill the extra tables from longest to shortest
   * bit len.  This way the sub trees will be aligned.
   */
  this.tree = new [Int](treeSize);
  for (var i=0, i<treeSize, i+=1) {
    this.tree[i] = 0;
  }
  var treePtr = 512;
  for (var bits = MAX_BITLEN, bits >= 10, bits -= 1) {
    var end = code & 0x1ff80;
    code -= blCount[bits] << (16 - bits);
    var start = code & 0x1ff80;
    for (var i = start, i < end, i += 1 << 7) {
      this.tree[bitReverse(i)] = (-treePtr << 4) | bits;
      treePtr += 1 << (bits-9);
    }
  }

  for (var i = 0, i < codeLengths.len, i += 1) {
    var bits = codeLengths[i];
    if (bits != 0) {
      code = nextCode[bits];
      var revcode = bitReverse(code);
      if (bits <= 9) {
        do {
          this.tree[revcode] = (i << 4) | bits;
          revcode += 1 << bits;
        } while (revcode < 512);
      } else {
        var subTree = this.tree[revcode & 511];
        var treeLen = 1 << (subTree & 15);
        subTree = -(subTree >> 4);
        do {
          this.tree[subTree | (revcode >> 9)] = (i << 4) | bits;
          revcode += 1 << bits;
        } while (revcode < treeLen);
      }
      nextCode[bits] = code + (1 << (16 - bits));
    }
  }
}

def new_InflaterHuffmanTree(codeLengths: BArray): InflaterHuffmanTree {
  var iht = new InflaterHuffmanTree { }
  iht.buildTree(codeLengths)
  iht
}

var defLT: InflaterHuffmanTree;
var defDT: InflaterHuffmanTree;

def init_static_trees() = {
  var codeLengths = new BArray(288);
  var i = 0;
  while (i < 144) {
    codeLengths[i] = 8;
    i += 1;
  }
  while (i < 256) {
    codeLengths[i] = 9;
    i += 1;
  }
  while (i < 280) {
    codeLengths[i] = 7;
    i += 1;
  }
  while (i < 288) {
    codeLengths[i] = 8;
    i += 1;
  }
  defLT = new_InflaterHuffmanTree(codeLengths);

  codeLengths = new BArray(32);
  i = 0;
  while (i < 32) {
    codeLengths[i] = 5;
    i += 1;
  }
  defDT = new_InflaterHuffmanTree(codeLengths);
}

def defLitLenTree(): InflaterHuffmanTree {
  var tree = defLT;
  if (tree != null) {
    tree
  } else {
    init_static_trees()
    defLT
  }
}

def defDistTree(): InflaterHuffmanTree {
  var tree = defDT;
  if (tree != null) {
    tree
  } else {
    init_static_trees()
    defDT
  }
}

def InflaterHuffmanTree.getSymbol(input: StreamManipulator): Int {
  var lookahead = input.peekBits(9);
  if (lookahead >= 0) {
    var symbol = this.tree[lookahead];
    if (symbol >= 0) {
      input.dropBits(symbol & 15);
      symbol >> 4;
    } else {
      var subtree = -(symbol >> 4);
      var bitlen = symbol & 15;
      lookahead = input.peekBits(bitlen);
      if (lookahead >= 0) {
        symbol = this.tree[subtree | (lookahead >> 9)];
        input.dropBits(symbol & 15);
        symbol >> 4;
      } else {
        var bits = input.getAvailableBits();
        lookahead = input.peekBits(bits);
        symbol = this.tree[subtree | (lookahead >> 9)];
        if ((symbol & 15) <= bits) {
          input.dropBits(symbol & 15);
          symbol >> 4;
        } else {
          -1;
        }
      }
    }
  } else {
    var bits = input.getAvailableBits();
    lookahead = input.peekBits(bits);
    var symbol = this.tree[lookahead];
    if (symbol >= 0 && (symbol & 15) <= bits) {
      input.dropBits(symbol & 15);
      symbol >> 4;
    } else {
      -1;
    }
  }
}
