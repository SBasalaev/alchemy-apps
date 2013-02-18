use "error.eh"
use "string.eh"

use "deflaterconstants.eh"
use "deflaterhuffman.eh"
use "maxmin.eh"

const BUFSIZE = 1 << (DEFAULT_MEM_LEVEL + 6);
const LITERAL_NUM = 286;
const DIST_NUM = 30;
const BITLEN_NUM = 19;
const REP_3_6    = 16;
const REP_3_10   = 17;
const REP_11_138 = 18;
const EOF_SYMBOL = 256;

def BL_ORDER(at: Int): Int = switch (at) {
  0: 16;
  1: 17;
  2: 18;
  3: 0;
  4: 8;
  5: 7;
  6: 9;
  7: 6;
  8: 10;
  9: 5;
  10: 11;
  11: 4;
  12: 12;
  13: 3;
  14: 13;
  15: 2;
  16: 14;
  17: 1;
  18: 15;
  else: -1;
}

const bit4Reverse = "\000\010\004\014\002\012\006\016\001\011\005\015\003\013\007\017";

def bitReverse(value: Int): Short {
  (bit4Reverse[value & 0xf] << 12
    | bit4Reverse[(value >> 4) & 0xf] << 8
    | bit4Reverse[(value >> 8) & 0xf] << 4
    | bit4Reverse[value >> 12]);
}

def l_code(len: Int): Int {
  if (len == 255) {
    285;
  } else {
    var code = 257;
    while (len >= 8) {
      code += 4;
      len >>= 1;
    }
    code + len;
  }
}

def d_code(distance: Int): Int {
  var code = 0;
  while (distance >= 4) {
    code += 2;
    distance >>= 1;
  }
  code + distance;
}

var staticLCodes: [Short];
var staticLLength: [Byte];
var staticDCodes: [Short];
var staticDLength: [Byte];

def init_static() {
  /* See RFC 1951 3.2.6 */
  /* Literal codes */
  staticLCodes = new [Short](LITERAL_NUM);
  staticLLength = new [Byte](LITERAL_NUM);
  var i = 0;
  while (i < 144) {
    staticLCodes[i] = bitReverse((0x030 + i) << 8);
    staticLLength[i] = 8;
    i += 1;
  }
  while (i < 256) {
    staticLCodes[i] = bitReverse((0x190 - 144 + i) << 7);
    staticLLength[i] = 9;
    i += 1;
  }
  while (i < 280) {
    staticLCodes[i] = bitReverse((0x000 - 256 + i) << 9);
    staticLLength[i] = 7;
    i += 1;
  }
  while (i < LITERAL_NUM) {
    staticLCodes[i] = bitReverse((0x0c0 - 280 + i)  << 8);
    staticLLength[i] = 8;
    i += 1;
  }

  /* Distant codes */
  staticDCodes = new [Short](DIST_NUM);
  staticDLength = new [Byte](DIST_NUM);
  for (i = 0, i < DIST_NUM, i += 1) {
    staticDCodes[i] = bitReverse(i << 11);
    staticDLength[i] = 5;
  }
}

type Tree;

type DeflaterHuffman {
  pending: PendingBuffer,
  literalTree: Tree,
  distTree: Tree,
  blTree: Tree,

  d_buf: [Short],
  l_buf: [Byte],
  last_lit: Int,
  extra_bits: Int
}

type Tree {
  owner: DeflaterHuffman,
  freqs: [Short],
  codes: [Short],
  length: [Byte],
  bl_counts: [Int],
  minNumCodes: Int,
  numCodes: Int,
  maxLength: Int
}

def new_Tree(owner: DeflaterHuffman, elems: Int, minCodes: Int, maxLength: Int): Tree {
  new Tree {
    owner = owner,
    minNumCodes = minCodes,
    numCodes = 0,
    maxLength = maxLength,
    freqs = new [Short](elems),
    bl_counts = new [Int](maxLength)
  }
}

def Tree.reset() {
  for (var i = 0, i < this.freqs.len, i += 1)
    this.freqs[i] = 0;
  this.codes = null;
  this.length = null;
}

def Tree.writeSymbol(code: Int) {
  this.owner.pending.writeBits(this.codes[code] & 0xffff, this.length[code]);
}

def Tree.setStaticCodes(stCodes: [Short], stLength: [Byte]) {
  this.codes = stCodes;
  this.length = stLength;
}

def Tree.buildCodes() {
  var nextCode = new [Int](this.maxLength);
  var code = 0;
  this.codes = new [Short](this.freqs.len);

  for (var bits = 0, bits < this.maxLength, bits += 1) {
    nextCode[bits] = code;
    code += this.bl_counts[bits] << (15 - bits);
  }

  for (var i=0, i < this.numCodes, i += 1) {
    var bits = this.length[i];
    if (bits > 0) {
      this.codes[i] = bitReverse(nextCode[bits-1]);
      nextCode[bits-1] += 1 << (16 - bits);
    }
  }
}

def Tree.buildLength(childs: [Int]) {
  this.length = new [Byte](this.freqs.len);
  var numNodes = childs.len / 2;
  var numLeafs = (numNodes + 1) / 2;
  var overflow = 0;

  for (var i = 0, i < this.maxLength, i += 1)
    this.bl_counts[i] = 0;

  /* First calculate optimal bit lengths */
  var lengths = new [Int](numNodes);
  lengths[numNodes-1] = 0;
  for (var i = numNodes - 1, i >= 0, i -= 1) {
    if (childs[2*i+1] != -1) {
      var bitLength = lengths[i] + 1;
      if (bitLength > this.maxLength) {
        bitLength = this.maxLength;
        overflow += 1;
      }
      lengths[childs[2*i+1]] = bitLength;
      lengths[childs[2*i]] = bitLength;
    } else {
      /* A leaf node */
      var bitLength = lengths[i];
      this.bl_counts[bitLength - 1] += 1;
      this.length[childs[2*i]] = lengths[i];
    }
  }

  if (overflow != 0) {
    var incrBitLen = this.maxLength - 1;
    do {
      /* Find the first bit length which could increase: */
      while ({incrBitLen -= 1; this.bl_counts[incrBitLen] == 0}) { }

      /* Move this node one down and remove a corresponding
       * amount of overflow nodes.
      */
      do {
        this.bl_counts[incrBitLen] -= 1;
        incrBitLen += 1;
        this.bl_counts[incrBitLen] += 1;
        overflow -= 1 << (this.maxLength - 1 - incrBitLen);
      } while (overflow > 0 && incrBitLen < this.maxLength - 1);
    } while (overflow > 0);

    /* We may have overshot above.  Move some nodes from maxLength to
     * maxLength-1 in that case.
     */
    this.bl_counts[this.maxLength-1] += overflow;
    this.bl_counts[this.maxLength-2] -= overflow;

    /* Now recompute all bit lengths, scanning in increasing
     * frequency.  It is simpler to reconstruct all lengths instead of
     * fixing only the wrong ones. This idea is taken from 'ar'
     * written by Haruhiko Okumura.
     *
     * The nodes were inserted with decreasing frequency into the childs
     * array.
     */
    var nodePtr = 2 * numLeafs;
    for (var bits = this.maxLength, bits != 0, bits -= 1) {
      var n = this.bl_counts[bits-1];
      while (n > 0) {
        var childPtr = 2*childs[nodePtr];
        nodePtr += 1;
        if (childs[childPtr + 1] == -1) {
          /* We found another leaf */
          this.length[childs[childPtr]] = bits;
          n -= 1;
        }
      }
    }
  }
}

def Tree.buildTree() {
  var numSymbols = this.freqs.len;

  /* heap is a priority queue, sorted by frequency, least frequent
   * nodes first.  The heap is a binary tree, with the property, that
   * the parent node is smaller than both child nodes.  This assures
   * that the smallest node is the first parent.
   *
   * The binary tree is encoded in an array:  0 is root node and
   * the nodes 2*n+1, 2*n+2 are the child nodes of node n.
   */
  var heap = new [Int](numSymbols);
  var heapLen = 0;
  var maxCode = 0;
  for (var n = 0, n < numSymbols, n += 1) {
    var freq = this.freqs[n];
    if (freq != 0) {
      /* Insert n into heap */
      var pos = heapLen;
      heapLen += 1;
      var ppos: Int;
      while (pos > 0 &&
              this.freqs[heap[{ppos = (pos - 1) / 2; ppos}]] > freq) {
        heap[pos] = heap[ppos];
        pos = ppos;
      }
      heap[pos] = n;
      maxCode = n;
    }
  }

  /* We could encode a single literal with 0 bits but then we
   * don't see the literals.  Therefore we force at least two
   * literals to avoid this case.  We don't care about order in
   * this case, both literals get a 1 bit code.
   */
  while (heapLen < 2) {
    var node = if (maxCode < 2) {maxCode += 1; maxCode} else 0;
    heap[heapLen] = node;
    heapLen += 1;
  }

  this.numCodes = max(maxCode + 1, this.minNumCodes);

  var numLeafs = heapLen;
  var childs = new [Int](4*heapLen - 2);
  var values = new [Int](2*heapLen - 1);
  var numNodes = numLeafs;
  for (var i = 0, i < heapLen, i += 1) {
    var node = heap[i];
    childs[2*i]   = node;
    childs[2*i+1] = -1;
    values[i] = this.freqs[node] << 8;
    heap[i] = i;
  }

  /* Construct the Huffman tree by repeatedly combining the least two
   * frequent nodes.
   */
  do {
    var first = heap[0];
    heapLen -= 1;
    var last = heap[heapLen];

    /* Propagate the hole to the leafs of the heap */
    var ppos = 0;
    var path = 1;
    while (path < heapLen) {
      if (path + 1 < heapLen && values[heap[path]] > values[heap[path+1]])
        path += 1;

      heap[ppos] = heap[path];
      ppos = path;
      path = path * 2 + 1;
    }

    /* Now propagate the last element down along path.  Normally
     * it shouldn't go too deep.
     */
    var lastVal = values[last];
    while (({path = ppos; path}) > 0
            && values[heap[{ppos = (path - 1)/2; ppos}]] > lastVal)
      heap[path] = heap[ppos];
    heap[path] = last;


    var second = heap[0];

    /* Create a new node father of first and second */
    last = numNodes;
    numNodes += 1;
    childs[2*last] = first;
    childs[2*last+1] = second;
    var mindepth = min(values[first] & 0xff, values[second] & 0xff);
    lastVal = values[first] + values[second] - mindepth + 1;
    values[last] = lastVal;

    /* Again, propagate the hole to the leafs */
    ppos = 0;
    path = 1;
    while (path < heapLen) {
      if (path + 1 < heapLen
              && values[heap[path]] > values[heap[path+1]])
      path += 1;

      heap[ppos] = heap[path];
      ppos = path;
      path = ppos * 2 + 1;
    }

    /* Now propagate the new element down along path */
    while (({path = ppos; path}) > 0
            && values[heap[{ppos = (path - 1)/2; ppos}]] > lastVal)
      heap[path] = heap[ppos];
      heap[path] = last;
  } while (heapLen > 1);

  if (heap[0] != childs.len / 2 - 1)
    error(FAIL, "Weird!");

  this.buildLength(childs);
}

def Tree.getEncodedLength(): Int {
  var len = 0;
  for (var i = 0, i < this.freqs.len, i += 1)
    len += this.freqs[i] * this.length[i];
  len;
}

def Tree.calcBLFreq(blTree: Tree) {
  var max_count: Int;          /* max repeat count */
  var min_count: Int;          /* min repeat count */
  var count: Int;              /* repeat count of the current code */
  var curlen = -1;             /* length of current code */

  var i = 0;
  while (i < this.numCodes) {
    count = 1;
    var nextlen = this.length[i];
    if (nextlen == 0) {
      max_count = 138;
      min_count = 3;
    } else {
      max_count = 6;
      min_count = 3;
      if (curlen != nextlen) {
        blTree.freqs[nextlen] += 1;
        count = 0;
      }
    }
    curlen = nextlen;
    i += 1;

    var break = false;
    while (!break && i < this.numCodes && curlen == this.length[i]) {
      i += 1;
      count += 1;
      if (count >= max_count)
        break = true;
    }

    if (count < min_count)
      blTree.freqs[curlen] += count
    else if (curlen != 0)
      blTree.freqs[REP_3_6] += 1
    else if (count <= 10)
      blTree.freqs[REP_3_10] += 1
    else
      blTree.freqs[REP_11_138] += 1;
  }
}

def Tree.writeTree(blTree: Tree) {
  var max_count: Int;          /* max repeat count */
  var min_count: Int;          /* min repeat count */
  var count: Int;              /* repeat count of the current code */
  var curlen = -1;             /* length of current code */

  var i = 0;
  while (i < this.numCodes) {
    count = 1;
    var nextlen = this.length[i];
    if (nextlen == 0) {
      max_count = 138;
      min_count = 3;
    } else {
      max_count = 6;
      min_count = 3;
      if (curlen != nextlen) {
        blTree.writeSymbol(nextlen);
        count = 0;
      }
    }
    curlen = nextlen;
    i += 1;

    var break = false;
    while (!break && i < this.numCodes && curlen == this.length[i]) {
      i += 1;
      count += 1;
      if (count >= max_count)
        break = true;
    }

    if (count < min_count) {
      while ({count -= 1; count+1} > 0)
        blTree.writeSymbol(curlen);
    } else if (curlen != 0) {
      blTree.writeSymbol(REP_3_6);
      this.owner.pending.writeBits(count - 3, 2);
    } else if (count <= 10) {
      blTree.writeSymbol(REP_3_10);
      this.owner.pending.writeBits(count - 3, 3);
    } else {
      blTree.writeSymbol(REP_11_138);
      this.owner.pending.writeBits(count - 11, 7);
    }
  }
}

def new_DeflaterHuffman(pending: PendingBuffer): DeflaterHuffman {
  if (staticLCodes == null) init_static()
  var dh = new DeflaterHuffman {
    pending = pending,
    d_buf = new [Short](BUFSIZE),
    l_buf = new [Byte](BUFSIZE),
    last_lit = 0,
    extra_bits = 0
  }
  dh.literalTree = new_Tree(dh, LITERAL_NUM, 257, 15);
  dh.distTree    = new_Tree(dh, DIST_NUM, 1, 15);
  dh.blTree      = new_Tree(dh, BITLEN_NUM, 4, 7);

  dh
}

def DeflaterHuffman.reset() {
  this.last_lit = 0;
  this.extra_bits = 0;
  this.literalTree.reset();
  this.distTree.reset();
  this.blTree.reset();
}

def DeflaterHuffman.sendAllTrees(blTreeCodes: Int) {
  this.blTree.buildCodes();
  this.literalTree.buildCodes();
  this.distTree.buildCodes();
  this.pending.writeBits(this.literalTree.numCodes - 257, 5);
  this.pending.writeBits(this.distTree.numCodes - 1, 5);
  this.pending.writeBits(blTreeCodes - 4, 4);
  for (var rank = 0, rank < blTreeCodes, rank += 1)
    this.pending.writeBits(this.blTree.length[BL_ORDER(rank)], 3);
  this.literalTree.writeTree(this.blTree);
  this.distTree.writeTree(this.blTree);
}

def DeflaterHuffman.compressBlock() {
  for (var i = 0, i < this.last_lit, i += 1) {
    var litlen = this.l_buf[i] & 0xff;
    var dist = this.d_buf[i];
    if ({dist -=1; dist+1} != 0) {
      var lc = l_code(litlen);
      this.literalTree.writeSymbol(lc);

      var bits = (lc - 261) / 4;
      if (bits > 0 && bits <= 5)
        this.pending.writeBits(litlen & ((1 << bits) - 1), bits);

      var dc = d_code(dist);
      this.distTree.writeSymbol(dc);

      bits = dc / 2 - 1;
      if (bits > 0)
        this.pending.writeBits(dist & ((1 << bits) - 1), bits);
    } else {
      this.literalTree.writeSymbol(litlen);
    }
  }
  
  this.literalTree.writeSymbol(EOF_SYMBOL);
}

def DeflaterHuffman.flushStoredBlock(stored: [Byte], stored_offset: Int, stored_len: Int, lastBlock: Bool) {
  this.pending.writeBits((STORED_BLOCK << 1) + if (lastBlock) 1 else 0, 3);
  this.pending.alignToByte();
  this.pending.writeShort(stored_len);
  this.pending.writeShort(~stored_len);
  this.pending.writeBlock(stored, stored_offset, stored_len);
  this.reset();
}

def DeflaterHuffman.flushBlock(stored: [Byte], stored_offset: Int, stored_len: Int, lastBlock: Bool) {
  this.literalTree.freqs[EOF_SYMBOL] += 1;

  /* Build trees */
  this.literalTree.buildTree();
  this.distTree.buildTree();

  /* Calculate bitlen frequency */
  this.literalTree.calcBLFreq(this.blTree);
  this.distTree.calcBLFreq(this.blTree);

  /* Build bitlen tree */
  this.blTree.buildTree();

  var blTreeCodes = 4;
  for (var i = 18, i > blTreeCodes, i -= 1) {
    if (this.blTree.length[BL_ORDER(i)] > 0)
      blTreeCodes = i+1;
  }
  var opt_len = 14 + blTreeCodes * 3 + this.blTree.getEncodedLength()
      + this.literalTree.getEncodedLength() + this.distTree.getEncodedLength()
      + this.extra_bits;

  var static_len = this.extra_bits;
  for (var i = 0, i < LITERAL_NUM, i += 1)
      static_len += this.literalTree.freqs[i] * staticLLength[i];
  for (var i = 0, i < DIST_NUM, i += 1)
      static_len += this.distTree.freqs[i] * staticDLength[i];
  if (opt_len >= static_len) {
    /* Force static trees */
    opt_len = static_len;
  }

  if (stored_offset >= 0 && stored_len+4 < opt_len >> 3) {
    /* Store Block */
    this.flushStoredBlock(stored, stored_offset, stored_len, lastBlock);
  } else if (opt_len == static_len) {
    /* Encode with static tree */
    this.pending.writeBits((STATIC_TREES << 1) + if (lastBlock) 1 else 0, 3);
    this.literalTree.setStaticCodes(staticLCodes, staticLLength);
    this.distTree.setStaticCodes(staticDCodes, staticDLength);
    this.compressBlock();
    this.reset();
  } else {
    /* Encode with dynamic tree */
    this.pending.writeBits((DYN_TREES << 1) + if (lastBlock) 1 else 0, 3);
    this.sendAllTrees(blTreeCodes);
    this.compressBlock();
    this.reset();
  }
}

def DeflaterHuffman.isFull(): Bool {
  this.last_lit == BUFSIZE;
}

def DeflaterHuffman.tallyLit(lit: Int): Bool {
  this.d_buf[this.last_lit] = 0;
  this.l_buf[this.last_lit] = lit;
  this.last_lit += 1;
  this.literalTree.freqs[lit] += 1;
  this.last_lit == BUFSIZE;
}

def DeflaterHuffman.tallyDist(dist: Int, len: Int): Bool {
  this.d_buf[this.last_lit] = dist;
  this.l_buf[this.last_lit] = len - 3;
  this.last_lit += 1;

  var lc = l_code(len-3);
  this.literalTree.freqs[lc] += 1;
  if (lc >= 265 && lc < 285)
    this.extra_bits += (lc - 261) / 4;

  var dc = d_code(dist-1);
  this.distTree.freqs[dc] += 1;
  if (dc >= 4)
    this.extra_bits += dc / 2 - 1;
  this.last_lit == BUFSIZE;
}
