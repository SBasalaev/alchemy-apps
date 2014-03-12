use "inflater.eh"
use "deflater.eh"
use "deflaterconstants.eh"
use "adler32.eh"
use "inflaterdynheader.eh"
use "inflaterhuffmantree.eh"
use "outputwindow.eh"
use "streammanipulator.eh"

/* Copy lengths for literal codes 257..285 */
def CPLENS(at: Int): Int = switch (at) {
  0: 3;
  1: 4;
  2: 5;
  3: 6;
  4: 7;
  5: 8;
  6: 9;
  7: 10;
  8: 11;
  9: 13;
  10: 15;
  11: 17;
  12: 19;
  13: 23;
  14: 27;
  15: 31;
  16: 35;
  17: 43;
  18: 51;
  19: 59;
  20: 67;
  21: 83;
  22: 99;
  23: 115;
  24: 131;
  25: 163;
  26: 195;
  27: 227;
  28: 258;
  else: -1;
}

/* Extra bits for literal codes 257..285 */
def CPLEXT(at: Int): Int = switch (at) {
 0: 0;
 1: 0;
 2: 0;
 3: 0;
 4: 0;
 5: 0;
 6: 0;
 7: 0;
 8: 1;
 9: 1;
 10: 1;
 11: 1;
 12: 2;
 13: 2;
 14: 2;
 15: 2;
 16: 3;
 17: 3;
 18: 3;
 19: 3;
 20: 4;
 21: 4;
 22: 4;
 23: 4;
 24: 5;
 25: 5;
 26: 5;
 27: 5;
 28: 0;
 else: -1;
}

/* Copy offsets for distance codes 0..29 */
def CPDIST(at: Int): Int = switch (at) {
  0: 1;
  1: 2;
  2: 3;
  3: 4;
  4: 5;
  5: 7;
  6: 9;
  7: 13;
  8: 17;
  9: 25;
  10: 33;
  11: 49;
  12: 65;
  13: 97;
  14: 129;
  15: 193;
  16: 257;
  17: 385;
  18: 513;
  19: 769;
  20: 1025;
  21: 1537;
  22: 2049;
  23: 3073;
  24: 4097;
  25: 6145;
  26: 8193;
  27: 12289;
  28: 16385;
  29: 24577;
  else: -1;
}

/* Extra bits for distance codes */
def CPDEXT(at: Int): Int = switch (at) {
  0: 0;
  1: 0;
  2: 0;
  3: 0;
  4: 1;
  5: 1;
  6: 2;
  7: 2;
  8: 3;
  9: 3;
  10: 4;
  11: 4;
  12: 5;
  13: 5;
  14: 6;
  15: 6;
  16: 7;
  17: 7;
  18: 8;
  19: 8;
  20: 9;
  21: 9;
  22: 10;
  23: 10;
  24: 11;
  25: 11;
  26: 12;
  27: 12;
  28: 13;
  29: 13;
  else: -1;
}

/* The states in which the inflater can be. */
const DECODE_HEADER           = 0;
const DECODE_DICT             = 1;
const DECODE_BLOCKS           = 2;
const DECODE_STORED_LEN1      = 3;
const DECODE_STORED_LEN2      = 4;
const DECODE_STORED           = 5;
const DECODE_DYN_HEADER       = 6;
const DECODE_HUFFMAN          = 7;
const DECODE_HUFFMAN_LENBITS  = 8;
const DECODE_HUFFMAN_DIST     = 9;
const DECODE_HUFFMAN_DISTBITS = 10;
const DECODE_CHKSUM           = 11;
const FINISHED                = 12;

type Inflater {
  mode: Int,
  readAdler: Int,
  neededBits: Int,
  repLength: Int,
  repDist: Int,
  uncomprLen: Int,
  isLastBlock: Bool,
  totalOut: Long,
  totalIn: Long,
  nowrap: Bool,
  input: StreamManipulator,
  outputWindow: OutputWindow,
  dynHeader: InflaterDynHeader,
  litlenTree: InflaterHuffmanTree,
  distTree: InflaterHuffmanTree,
  adler: Adler32
}

def Inflater.new(nowrap: Bool = false) {
  this.mode = if (nowrap) DECODE_BLOCKS else DECODE_HEADER;
  this.nowrap = nowrap;
  this.input = new StreamManipulator();
  this.outputWindow = new OutputWindow();
  this.adler = new Adler32();
}

def Inflater.end() {
  this.outputWindow = null;
  this.input = null;
  this.dynHeader = null;
  this.litlenTree = null;
  this.distTree = null;
  this.adler = null;
}

def Inflater.finished(): Bool {
  return this.mode == FINISHED && this.outputWindow.getAvailable() == 0;
}

def Inflater.getAdler(): Int {
  if (this.needsDictionary()) {
    return this.readAdler
  } else {
    return this.adler.value;
  }
}

def Inflater.getRemaining(): Int {
  return this.input.getAvailableBytes();
}

def Inflater.getBytesRead(): Long {
  return this.totalIn - this.remaining;
}

def Inflater.getBytesWritten(): Long {
  return this.totalOut;
}

def Inflater.decode(): Bool;
def Inflater.inflate(buf: [Byte], off: Int, len: Int): Int {
  /* Check for correct buff, off, len triple */
  if (0 > off || off > off + len || off + len > buf.len)
    throw(ERR_RANGE, null);
  var count = 0;
  while (true) {
    if (this.outputWindow.getAvailable() == 0) {
      if (!this.decode())
        break;
    } else if (len > 0) {
      var more = this.outputWindow.copyOutput(buf, off, len);
      this.adler.updateArray(buf, off, more);
      off += more;
      count += more;
      this.totalOut += more;
      len -= more;
    } else break;
  }
  return count;
}

def Inflater.needsDictionary(): Bool {
  return this.mode == DECODE_DICT && this.neededBits == 0;
}

def Inflater.needsInput(): Bool {
  return this.input.needsInput();
}

def Inflater.reset() {
  this.mode = if (this.nowrap) DECODE_BLOCKS else DECODE_HEADER;
  this.totalIn = 0;
  this.totalOut = 0;
  this.input.reset();
  this.outputWindow.reset();
  this.dynHeader = null;
  this.litlenTree = null;
  this.distTree = null;
  this.isLastBlock = false;
  this.adler.reset();
}

def Inflater.setDictionary(buffer: [Byte], off: Int, len: Int) {
  if (!this.needsDictionary())
    throw(ERR_ILL_STATE, null);

  this.adler.updateArray(buffer, off, len);
  if (this.adler.value != this.readAdler)
    throw(ERR_ILL_ARG, "Wrong adler checksum");
  this.adler.reset();
  this.outputWindow.copyDict(buffer, off, len);
  this.mode = DECODE_BLOCKS;
}

def Inflater.setInput(buf: [Byte], off: Int, len: Int) {
  this.input.setInput (buf, off, len);
  this.totalIn += len;
}

def Inflater.decodeHeader(): Bool {
  var header = this.input.peekBits(16);
  if (header < 0) return false;
  this.input.dropBits(16);

  /* The header is written in "wrong" byte order */
  header = ((header << 8) | (header >> 8)) & 0xffff;
  if (header % 31 != 0)
    throw(FAIL, "Header checksum illegal");

  if ((header & 0x0f00) != (DEFLATED << 8))
    throw(FAIL, "Compression Method unknown");

  /* Maximum size of the backwards window in bits.
   * We currently ignore this, but we could use it to make the
   * inflater window more space efficient. On the other hand the
   * full window (15 bits) is needed most times, anyway.
   int max_wbits = ((header & 0x7000) >> 12) + 8;
   */

  if ((header & 0x0020) == 0) { // Dictionary flag?
    this.mode = DECODE_BLOCKS;
  } else {
    this.mode = DECODE_DICT;
    this.neededBits = 32;
  }
  return true;
}

def Inflater.decodeDict(): Bool {
  while (this.neededBits > 0) {
    var dictByte = this.input.peekBits(8);
    if (dictByte < 0) break;
    this.input.dropBits(8);
    this.readAdler = (this.readAdler << 8) | dictByte;
    this.neededBits -= 8;
  }
  return false;
}

def Inflater.decodeHuffman(): Bool {
  var free = this.outputWindow.getFreeSpace();
  while (free >= 258) {
    var symbol: Int;
    switch (this.mode) {
      DECODE_HUFFMAN: {
        while (symbol = this.litlenTree.getSymbol(this.input), (symbol & ~0xff) == 0) {
          this.outputWindow.write(symbol);
          free -= 1;
          if (free < 258) return true;
        }
        if (symbol < 257) {
          if (symbol < 0) return false;

          /* symbol == 256: end of block */
          this.distTree = null;
          this.litlenTree = null;
          this.mode = DECODE_BLOCKS;
          return true;
        }

        try {
          this.repLength = CPLENS(symbol - 257);
          this.neededBits = CPLEXT(symbol - 257);
        } catch {
          throw(FAIL, "Illegal rep length code");
        }
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_LENBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) return false;
          this.input.dropBits(this.neededBits);
          this.repLength += i;
        }
        this.mode = DECODE_HUFFMAN_DIST;
      }
      DECODE_HUFFMAN_LENBITS: {
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_LENBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) return false;
          this.input.dropBits(this.neededBits);
          this.repLength += i;
        }
        this.mode = DECODE_HUFFMAN_DIST;
      }
      DECODE_HUFFMAN_DIST: {
        symbol = this.distTree.getSymbol(this.input);
        if (symbol < 0) return false;
        try {
          this.repDist = CPDIST(symbol);
          this.neededBits = CPDEXT(symbol);
        } catch {
          throw(FAIL, "Illegal rep dist code");
        }
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_DISTBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) return false;
          this.input.dropBits(this.neededBits);
          this.repDist += i;
        }
        this.outputWindow.repeat(this.repLength, this.repDist);
        free -= this.repLength;
        this.mode = DECODE_HUFFMAN;
      }
      DECODE_HUFFMAN_DISTBITS: {
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_DISTBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) return false;
          this.input.dropBits(this.neededBits);
          this.repDist += i;
        }
        this.outputWindow.repeat(this.repLength, this.repDist);
        free -= this.repLength;
        this.mode = DECODE_HUFFMAN;
      }
      else:
        throw(ERR_ILL_STATE, null);
    }
  }
  return true;
}

def Inflater.decodeChksum(): Bool {
  while (this.neededBits > 0) {
    var chkByte = this.input.peekBits(8);
    if (chkByte < 0) return false;
    this.input.dropBits(8);
    this.readAdler = (this.readAdler << 8) | chkByte;
    this.neededBits -= 8;
  }
  if (this.adler.value != this.readAdler)
    throw(FAIL, "Adler chksum doesn't match: "
          + (this.adler.value).tohex()
          + " vs. " + (this.readAdler).tohex());
  this.mode = FINISHED;
  return false;
}

def Inflater.decode(): Bool {
  switch (this.mode) {
    DECODE_HEADER:
      return this.decodeHeader();
    DECODE_DICT:
      return this.decodeDict();
    DECODE_CHKSUM:
      return this.decodeChksum();
    DECODE_BLOCKS: {
      if (this.isLastBlock) {
        if (this.nowrap) {
          this.mode = FINISHED;
          return false;
        } else {
          this.input.skipToByteBoundary();
          this.neededBits = 32;
          this.mode = DECODE_CHKSUM;
          return true;
        }
      }
      var `type` = this.input.peekBits(3);
      if (`type` < 0) return false;
      this.input.dropBits(3);

      if ((`type` & 1) != 0)
        this.isLastBlock = true;
      switch (`type` >> 1) {
        STORED_BLOCK: {
          this.input.skipToByteBoundary();
          this.mode = DECODE_STORED_LEN1;
        }
        STATIC_TREES: {
          this.litlenTree = defLitLenTree();
          this.distTree = defDistTree();
          this.mode = DECODE_HUFFMAN;
        }
        DYN_TREES: {
          this.dynHeader = new InflaterDynHeader();
          this.mode = DECODE_DYN_HEADER;
        }
        else:
          throw(FAIL, "Unknown block type " + `type`);
      }
      return true;
    }
    DECODE_STORED_LEN1: {
      this.uncomprLen = this.input.peekBits(16);
      if (this.uncomprLen < 0) return false;
      this.input.dropBits(16);
      this.mode = DECODE_STORED_LEN2;
      var nlen = this.input.peekBits(16);
      if (nlen < 0) return false;
      this.input.dropBits(16);
      if (nlen != (this.uncomprLen ^ 0xffff))
        throw(FAIL, "broken uncompressed block");
      this.mode = DECODE_STORED;
      var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
      this.uncomprLen -= more;
      if (this.uncomprLen == 0) {
        this.mode = DECODE_BLOCKS;
        return true;
      }
      return !this.input.needsInput();
    }
    DECODE_STORED_LEN2: {
      var nlen = this.input.peekBits(16);
      if (nlen < 0) return false;
      this.input.dropBits(16);
      if (nlen != (this.uncomprLen ^ 0xffff))
        throw(FAIL, "broken uncompressed block");
      this.mode = DECODE_STORED;
      var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
      this.uncomprLen -= more;
      if (this.uncomprLen == 0) {
        this.mode = DECODE_BLOCKS;
        return true;
      }
      return !this.input.needsInput();
    }
    DECODE_STORED: {
      var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
      this.uncomprLen -= more;
      if (this.uncomprLen == 0) {
        this.mode = DECODE_BLOCKS;
        return true;
      }
      return !this.input.needsInput();
    }
    DECODE_DYN_HEADER: {
      if (!this.dynHeader.decode(this.input)) return false;
      this.litlenTree = this.dynHeader.buildLitLenTree();
      this.distTree = this.dynHeader.buildDistTree();
      this.mode = DECODE_HUFFMAN;
      return this.decodeHuffman();
    }
    DECODE_HUFFMAN,
    DECODE_HUFFMAN_LENBITS,
    DECODE_HUFFMAN_DIST,
    DECODE_HUFFMAN_DISTBITS:
      return this.decodeHuffman();
    FINISHED:
      return false;
    else:
      throw(ERR_ILL_STATE, null);
  }
}
