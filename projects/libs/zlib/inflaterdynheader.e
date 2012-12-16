use "inflaterdynheader.eh" 
use "inflaterhuffmantree.eh"
use "sys.eh"
use "error.eh"

const LNUM   = 0;
const DNUM   = 1;
const BLNUM  = 2;
const BLLENS = 3;
const LENS   = 4;
const REPS   = 5;

def repMin(at: Int): Int = switch (at) {
  0: 3;
  1: 3;
  2: 11;
  else: -1;
}

def repBits(at: Int): Int = switch (at) {
  0: 2;
  1: 3;
  2: 7;
  else: -1;
}

// reuse BL_ORDER from deflaterhuffman
def BL_ORDER(at: Int): Int;

type InflaterDynHeader {
  blLens: BArray,
  litdistLens: BArray,
  blTree: InflaterHuffmanTree,
  mode: Int,
  lnum: Int,
  dnum: Int,
  blnum: Int,
  num: Int,
  repSymbol: Int,
  lastLen: Int,
  ptr: Int
}

def new_InflaterDynHeader(): InflaterDynHeader {
  new InflaterDynHeader {
    // initialize numerics just to be safe
    mode = 0,
    lnum = 0,
    dnum = 0,
    blnum = 0,
    num = 0,
    repSymbol = 0,
    lastLen = 0,
    ptr = 0
  }
}

def InflaterDynHeader.decode(input: StreamManipulator): Bool {
  var break = false;
  var result: Bool;
  while (!break) {
    switch (this.mode) {
      LNUM: {
        this.lnum = input.peekBits(5);
        if (this.lnum < 0) {
          break = true;
          result = false;
        } else {
          this.lnum += 257;
          input.dropBits(5);
          this.mode = DNUM;
        }
      }
      DNUM: {
        this.dnum = input.peekBits(5);
        if (this.dnum < 0) {
          break = true;
          result = false;
        } else {
          this.dnum += 1;
          input.dropBits(5);
          this.num = this.lnum + this.dnum;
          this.litdistLens = new BArray(this.num);
          this.mode = BLNUM;
        }
      }
      BLNUM: {
        this.blnum = input.peekBits(4);
        if (this.blnum < 0) {
          break = true;
          result = false;
        } else {
          this.blnum += 4;
          input.dropBits(4);
          this.blLens = new BArray(19);
          this.ptr = 0;
          this.mode = BLLENS;
        }
      }
      BLLENS: {
        while (!break && this.ptr < this.blnum) {
          var len = input.peekBits(3);
          if (len < 0) {
            break = true;
            result = false;
          } else {
            input.dropBits(3);
            this.blLens[BL_ORDER(this.ptr)] = len;
            this.ptr += 1;
          }
        }
        if (!break) {
          this.blTree = new_InflaterHuffmanTree(this.blLens);
          this.blLens = null;
          this.ptr = 0;
          this.mode = LENS;
        }
      }
      LENS: {
        var symbol: Int;
        while (!break && ({symbol = this.blTree.getSymbol(input); symbol} & ~15) == 0) {
          /* Normal case: symbol in [0..15] */
          this.lastLen = symbol;
          this.litdistLens[this.ptr] = symbol;
          this.ptr += 1;

          if (this.ptr == this.num) {
            /* Finished */
            break = true;
            result = true;
          }
        }

        if (!break) {
          /* need more input ? */
          if (symbol < 0) {
            break = true;
            result = false;
          } else {
            /* otherwise repeat code */
            if (symbol >= 17) {
              /* repeat zero */
              this.lastLen = 0;
            } else {
              if (this.ptr == 0)
                error(FAIL, null);
            }
            this.repSymbol = symbol-16;
            this.mode = REPS;
          }
        }
      }
      REPS: {
        var bits = repBits(this.repSymbol);
        var count = input.peekBits(bits);
        if (count < 0) {
          break = true;
          result = false;
        } else {
          input.dropBits(bits);
          count += repMin(this.repSymbol);

          if (this.ptr + count > this.num)
            error(FAIL, null);
          while (count > 0) {
            count -= 1;
            this.litdistLens[this.ptr] = this.lastLen;
            this.ptr += 1;
          }

          if (this.ptr == this.num) {
            /* Finished */
            break = true;
            result = true;
          } else {
            this.mode = LENS;
          }
        }
      }
    }
  }
  result;
}

def InflaterDynHeader.buildLitLenTree(): InflaterHuffmanTree {
  var litlenLens = new BArray(this.lnum);
  bacopy(this.litdistLens, 0, litlenLens, 0, this.lnum);
  new_InflaterHuffmanTree(litlenLens);
}

def InflaterDynHeader.buildDistTree(): InflaterHuffmanTree {
  var distLens = new BArray(this.dnum);
  bacopy(this.litdistLens, this.lnum, distLens, 0, this.dnum);
  new_InflaterHuffmanTree(distLens);
}
