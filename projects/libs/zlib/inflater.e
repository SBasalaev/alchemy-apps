use "inflater.eh"
use "deflater.eh"
use "deflaterconstants.eh"
use "adler32.eh"
use "inflaterdynheader.eh"
use "inflaterhuffmantree.eh"
use "outputwindow.eh"
use "streammanipulator.eh"

use "error.eh"
use "string.eh"

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
  else: { error(ERR_RANGE, null); 0}
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
 else: { error(ERR_RANGE, null); 0}
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
  else: { error(ERR_RANGE, null); 0}
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
  else: { error(ERR_RANGE, null); 0}
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
  this.input = new_StreamManipulator();
  this.outputWindow = new_OutputWindow();
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
  this.mode == FINISHED && this.outputWindow.getAvailable() == 0;
}

def Inflater.get_adler(): Int {
  if(this.needs_dictionary()) this.readAdler else this.adler.value;
}

def Inflater.get_remaining(): Int {
  this.input.getAvailableBytes();
}

def Inflater.get_bytesread(): Long {
  this.totalIn - this.remaining;
}

def Inflater.get_byteswritten(): Long {
  this.totalOut;
}

def Inflater.decode(): Bool;
def Inflater.inflate(buf: [Byte], off: Int, len: Int): Int {
  /* Check for correct buff, off, len triple */
  if (0 > off || off > off + len || off + len > buf.len)
    error(ERR_RANGE, null);
  var count = 0;
  var break = false;
  while (!break) {
    if (this.outputWindow.getAvailable() == 0) {
      if (!this.decode())
        break = true;
    } else if (len > 0) {
      var more = this.outputWindow.copyOutput(buf, off, len);
      this.adler.updatearray(buf, off, more);
      off += more;
      count += more;
      this.totalOut += more;
      len -= more;
    } else
      break = true;
  }
  count;
}

def Inflater.needs_dictionary(): Bool {
  this.mode == DECODE_DICT && this.neededBits == 0;
}

def Inflater.needs_input(): Bool {
  this.input.needsInput();
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

def Inflater.set_dictionary(buffer: [Byte], off: Int, len: Int) {
  if (!this.needs_dictionary())
    error(ERR_ILL_STATE, null);

  this.adler.updatearray(buffer, off, len);
  if (this.adler.value != this.readAdler)
    error(ERR_ILL_ARG, "Wrong adler checksum");
  this.adler.reset();
  this.outputWindow.copyDict(buffer, off, len);
  this.mode = DECODE_BLOCKS;
}

def Inflater.set_input(buf: [Byte], off: Int, len: Int) {
  this.input.setInput (buf, off, len);
  this.totalIn += len;
}

def Inflater.decodeHeader(): Bool {
  var header = this.input.peekBits(16);
  if (header < 0) {
    false;
  } else {
    this.input.dropBits(16);

    /* The header is written in "wrong" byte order */
    header = ((header << 8) | (header >> 8)) & 0xffff;
    if (header % 31 != 0)
      error(FAIL, "Header checksum illegal");

    if ((header & 0x0f00) != (DEFLATED << 8))
      error(FAIL, "Compression Method unknown");

    /* Maximum size of the backwards window in bits.
     * We currently ignore this, but we could use it to make the
     * inflater window more space efficient. On the other hand the
     * full window (15 bits) is needed most times, anyway.
     int max_wbits = ((header & 0x7000) >> 12) + 8;
     */

    if ((header & 0x0020) == 0) // Dictionary flag?
    {
      this.mode = DECODE_BLOCKS;
    } else {
      this.mode = DECODE_DICT;
      this.neededBits = 32;
    }
    true;
  }
}

def Inflater.decodeDict(): Bool {
  var break = false;
  while (!break && this.neededBits > 0) {
    var dictByte = this.input.peekBits(8);
    if (dictByte < 0) {
      break = true;
    } else {
      this.input.dropBits(8);
      this.readAdler = (this.readAdler << 8) | dictByte;
      this.neededBits -= 8;
    }
  }
  false;
}

def Inflater.decodeHuffman(): Bool {
  var free = this.outputWindow.getFreeSpace();
  var break = false;
  var result = true;
  while (!break && free >= 258) {
    var symbol: Int;
    switch (this.mode) {
      DECODE_HUFFMAN: {
        while (!break && (({symbol = this.litlenTree.getSymbol(this.input); symbol}) & ~0xff) == 0) {
          this.outputWindow.write(symbol);
          free -= 1;
          if (free < 258) {
            break = true;
            result = true;
          }
        }
        if (!break && symbol < 257) {
          if (symbol < 0) {
            break = true;
            result = false;
          } else {
            /* symbol == 256: end of block */
            this.distTree = null;
            this.litlenTree = null;
            this.mode = DECODE_BLOCKS;
            break = true;
            result = true;
          }
        }

        if (!break) {
          try {
            this.repLength = CPLENS(symbol - 257);
            this.neededBits = CPLEXT(symbol - 257);
          } catch {
            error(FAIL, "Illegal rep length code");
          }
          if (this.neededBits > 0) {
            this.mode = DECODE_HUFFMAN_LENBITS;
            var i = this.input.peekBits(this.neededBits);
            if (i < 0) {
              break = true;
              result = false;
            } else {
              this.input.dropBits(this.neededBits);
              this.repLength += i;
            }
          }
          if (!break) this.mode = DECODE_HUFFMAN_DIST;
        }
      }
      DECODE_HUFFMAN_LENBITS: {
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_LENBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) {
            break = true;
            result = false;
          } else {
            this.input.dropBits(this.neededBits);
            this.repLength += i;
          }
        }
        if (!break) this.mode = DECODE_HUFFMAN_DIST;
      }
      DECODE_HUFFMAN_DIST: {
        symbol = this.distTree.getSymbol(this.input);
        if (symbol < 0) {
          break = true;
          result = false;
        } else {
          try {
            this.repDist = CPDIST(symbol);
            this.neededBits = CPDEXT(symbol);
          } catch {
            error(FAIL, "Illegal rep dist code");
          }
        }
        if (!break && this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_DISTBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) {
            break = true;
            result = false;
          } else {
            this.input.dropBits(this.neededBits);
            this.repDist += i;
          }
        }
        if (!break) {
          this.outputWindow.repeat(this.repLength, this.repDist);
          free -= this.repLength;
          this.mode = DECODE_HUFFMAN;
        }
      }
      DECODE_HUFFMAN_DISTBITS: {
        if (this.neededBits > 0) {
          this.mode = DECODE_HUFFMAN_DISTBITS;
          var i = this.input.peekBits(this.neededBits);
          if (i < 0) {
            break = true;
            result = false;
          } else {
            this.input.dropBits(this.neededBits);
            this.repDist += i;
          }
        }
        if (!break) {
          this.outputWindow.repeat(this.repLength, this.repDist);
          free -= this.repLength;
          this.mode = DECODE_HUFFMAN;
        }
      }
      else:
        error(ERR_ILL_STATE, null);
    }
  }
  result;
}

def Inflater.decodeChksum(): Bool {
  var break = false;
  var result = false;
  while (!break && this.neededBits > 0) {
    var chkByte = this.input.peekBits(8);
    if (chkByte < 0) {
      break = true;
      result = false;
    } else {
      this.input.dropBits(8);
      this.readAdler = (this.readAdler << 8) | chkByte;
      this.neededBits -= 8;
    }
  }
  if (!break) {
    if (this.adler.value != this.readAdler)
      error(FAIL, "Adler chksum doesn't match: "
            + (this.adler.value).tohex()
            + " vs. " + (this.readAdler).tohex());
    this.mode = FINISHED;
  }
  result;
}

def Inflater.decode(): Bool {
  switch (this.mode) {
    DECODE_HEADER:
      this.decodeHeader();
    DECODE_DICT:
      this.decodeDict();
    DECODE_CHKSUM:
      this.decodeChksum();
    DECODE_BLOCKS: {
      if (this.isLastBlock) {
        if (this.nowrap) {
          this.mode = FINISHED;
          false;
        } else {
          this.input.skipToByteBoundary();
          this.neededBits = 32;
          this.mode = DECODE_CHKSUM;
          true;
        }
      } else {
        var `type` = this.input.peekBits(3);
        if (`type` < 0) {
          false;
        } else {
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
              this.dynHeader = new_InflaterDynHeader();
              this.mode = DECODE_DYN_HEADER;
            }
            else:
              error(FAIL, "Unknown block type " + `type`);
          }
          true;
        }
      }
    }
    DECODE_STORED_LEN1:
      if (({this.uncomprLen = this.input.peekBits(16); this.uncomprLen}) < 0) {
        false;
      } else {
        this.input.dropBits(16);
        this.mode = DECODE_STORED_LEN2;
        var nlen = this.input.peekBits(16);
        if (nlen < 0) {
          false;
        } else {
          this.input.dropBits(16);
          if (nlen != (this.uncomprLen ^ 0xffff))
            error(FAIL, "broken uncompressed block");
          this.mode = DECODE_STORED;
          var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
          this.uncomprLen -= more;
          if (this.uncomprLen == 0) {
            this.mode = DECODE_BLOCKS;
            true;
          } else {
            !this.input.needsInput();
          }
        }
      }
    DECODE_STORED_LEN2: {
      var nlen = this.input.peekBits(16);
      if (nlen < 0) {
        false;
      } else {
        this.input.dropBits(16);
        if (nlen != (this.uncomprLen ^ 0xffff))
          error(FAIL, "broken uncompressed block");
        this.mode = DECODE_STORED;
        var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
        this.uncomprLen -= more;
        if (this.uncomprLen == 0) {
          this.mode = DECODE_BLOCKS;
          true;
        } else {
          !this.input.needsInput();
        }
      }
    }
    DECODE_STORED: {
      var more = this.outputWindow.copyStored(this.input, this.uncomprLen);
      this.uncomprLen -= more;
      if (this.uncomprLen == 0) {
        this.mode = DECODE_BLOCKS;
        true;
      } else {
        !this.input.needsInput();
      }
    }
    DECODE_DYN_HEADER:
      if (!this.dynHeader.decode(this.input)) {
        false;
      } else {
        this.litlenTree = this.dynHeader.buildLitLenTree();
        this.distTree = this.dynHeader.buildDistTree();
        this.mode = DECODE_HUFFMAN;
        this.decodeHuffman();
      }
    DECODE_HUFFMAN,
    DECODE_HUFFMAN_LENBITS,
    DECODE_HUFFMAN_DIST,
    DECODE_HUFFMAN_DISTBITS:
      this.decodeHuffman();
    FINISHED:
      false;
    else:
      {error(ERR_ILL_STATE, null); false}
  }
}
