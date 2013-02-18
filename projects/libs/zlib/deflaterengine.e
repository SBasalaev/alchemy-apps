use "deflaterengine.eh"

use "adler32.eh"
use "deflater.eh"
use "deflaterconstants.eh"
use "deflaterhuffman.eh"
use "maxmin.eh"

use "error.eh"
use "sys.eh"

const TOO_FAR = 4096;

type DeflaterEngine {
  ins_h: Int,
  head: [Short],
  prev: [Short],
  matchStart: Int,
  matchLen: Int,
  prevAvailable: Bool,
  blockStart: Int,
  strstart: Int,
  lookahead: Int,
  window: [Byte],
  strategy: Int,
  max_chain: Int,
  max_lazy: Int,
  niceLength: Int,
  goodLength: Int,
  comprFunc: Int,
  inputBuf: [Byte],
  totalIn: Long,
  inputOff: Int,
  inputEnd: Int,
  pending: PendingBuffer,
  huffman: DeflaterHuffman,
  adler: Adler32
}

def new_DeflaterEngine(pending: PendingBuffer): DeflaterEngine {
  new DeflaterEngine {
    pending = pending,
    huffman = new_DeflaterHuffman(pending),
    adler = new Adler32(),

    window = new [Byte](2*WSIZE),
    head   = new [Short](HASH_SIZE),
    prev   = new [Short](WSIZE),

    blockStart = 1,
    strstart = 1,

    /* Initializing numeric fields which otherwise will contain null. */
    ins_h = 0,
    matchStart = 0,
    matchLen = 0,
    prevAvailable = false,
    lookahead = 0,
    strategy = 0,
    max_chain = 0,
    max_lazy = 0,
    niceLength = 0,
    goodLength = 0,
    comprFunc = 0,
    totalIn = 0L,
    inputOff = 0,
    inputEnd = 0
  }
}

def DeflaterEngine.reset() {
  this.huffman.reset();
  this.adler.reset();
  this.blockStart = 1;
  this.strstart = 1;
  this.lookahead = 0;
  this.totalIn = 0;
  this.prevAvailable = false;
  this.matchLen = MIN_MATCH - 1;
  for (var i = 0, i < HASH_SIZE, i += 1)
    this.head[i] = 0;
  for (var i = 0, i < WSIZE, i += 1)
    this.prev[i] = 0;
}

def DeflaterEngine.resetAdler() {
  this.adler.reset();
}

def DeflaterEngine.getAdler(): Int {
  this.adler.value
}

def DeflaterEngine.getTotalIn(): Long {
  this.totalIn;
}

def DeflaterEngine.setStrategy(strat: Int) {
  this.strategy = strat;
}

def DeflaterEngine.updateHash() {
  this.ins_h = (this.window[this.strstart] << HASH_SHIFT)
          ^ this.window[this.strstart + 1];
}

def DeflaterEngine.setLevel(lvl: Int) {
  this.goodLength = GOOD_LENGTH(lvl);
  this.max_lazy = MAX_LAZY(lvl);
  this.niceLength = NICE_LENGTH(lvl);
  this.max_chain = MAX_CHAIN(lvl);

  if (COMPR_FUNC(lvl) != this.comprFunc) {
    switch (this.comprFunc) {
      DEFLATE_STORED: {
        if (this.strstart > this.blockStart) {
          this.huffman.flushStoredBlock(this.window, this.blockStart,
                  this.strstart - this.blockStart, false);
          this.blockStart = this.strstart;
        }
        this.updateHash();
      }
      DEFLATE_FAST: {
        if (this.strstart > this.blockStart) {
          this.huffman.flushBlock(this.window, this.blockStart,
                  this.strstart - this.blockStart, false);
          this.blockStart = this.strstart;
        }
      }
      DEFLATE_SLOW: {
        if (this.prevAvailable)
          this.huffman.tallyLit(this.window[this.strstart-1] & 0xff);
        if (this.strstart > this.blockStart) {
          this.huffman.flushBlock(this.window, this.blockStart,
                  this.strstart - this.blockStart, false);
          this.blockStart = this.strstart;
        }
        this.prevAvailable = false;
        this.matchLen = MIN_MATCH - 1;
      }
    }
    this.comprFunc = COMPR_FUNC(lvl);
  }
}

def DeflaterEngine.insertString(): Int {
  var hash = ((this.ins_h << HASH_SHIFT) ^ this.window[this.strstart + (MIN_MATCH -1)])
      & HASH_MASK;

  var match = this.head[hash];
  this.prev[this.strstart & WMASK] = match;
  this.head[hash] = this.strstart;
  this.ins_h = hash;
  match & 0xffff;
}

def DeflaterEngine.slideWindow() {
  acopy(this.window, WSIZE, this.window, 0, WSIZE);
  this.matchStart -= WSIZE;
  this.strstart -= WSIZE;
  this.blockStart -= WSIZE;

  /* Slide the hash table (could be avoided with 32 bit values
   * at the expense of memory usage).
   */
  for (var i = 0, i < HASH_SIZE, i += 1) {
    var m = this.head[i] & 0xffff;
    this.head[i] = if (m >= WSIZE) m - WSIZE else 0;
  }

  /* Slide the prev table.
   */
  for (var i = 0, i < WSIZE, i += 1) {
    var m = this.prev[i] & 0xffff;
    this.prev[i] = if (m >= WSIZE) m - WSIZE else 0;
  }
}

def DeflaterEngine.fillWindow() {
  /* If the window is almost full and there is insufficient lookahead,
   * move the upper half to the lower one to make room in the upper half.
   */
  if (this.strstart >= WSIZE + MAX_DIST)
    this.slideWindow();

  /* If there is not enough lookahead, but still some input left,
   * read in the input
   */
  while (this.lookahead < MIN_LOOKAHEAD && this.inputOff < this.inputEnd) {
    var more = 2*WSIZE - this.lookahead - this.strstart;

    if (more > this.inputEnd - this.inputOff)
      more = this.inputEnd - this.inputOff;

    acopy(this.inputBuf, this.inputOff, this.window,
            this.strstart + this.lookahead, more);
    this.adler.updatearray(this.inputBuf, this.inputOff, more);
    this.inputOff += more;
    this.totalIn  += more;
    this.lookahead += more;
  }

  if (this.lookahead >= MIN_MATCH)
    this.updateHash();
}

def DeflaterEngine.findLongestMatch(curMatch: Int): Bool {
  var chainLength = this.max_chain;
  var niceLength = this.niceLength;
  var prev = this.prev;
  var scan  = this.strstart;
  var match: Int;
  var best_end = this.strstart + this.matchLen;
  var best_len = max(this.matchLen, MIN_MATCH - 1);

  var limit = max(this.strstart - MAX_DIST, 0);

  var strend = scan + MAX_MATCH - 1;
  var scan_end1 = this.window[best_end - 1];
  var scan_end  = this.window[best_end];

  /* Do not waste too much time if we already have a good match: */
  if (best_len >= this.goodLength)
    chainLength >>= 2;

  /* Do not look for matches beyond the end of the input. This is necessary
   * to make deflate deterministic.
   */
  if (niceLength > this.lookahead)
    niceLength = this.lookahead;

  var break = false;
  do {
    if (this.window[curMatch + best_len] == scan_end
     && this.window[curMatch + best_len - 1] == scan_end1
     && this.window[curMatch] == this.window[scan]
     && this.window[curMatch+1] == this.window[scan + 1]) {

      match = curMatch + 2;
      scan += 2;

      /* We check for insufficient lookahead only every 8th comparison;
       * the 256th check will be made at strstart+258.
       */
      while ({scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && {scan += 1; match += 1; this.window[scan] == this.window[match]}
          && scan < strend) { }

      if (scan > best_end) {
        this.matchStart = curMatch;
        best_end = scan;
        best_len = scan - this.strstart;
        if (best_len >= niceLength) {
          break = true;
        } else {
          scan_end1 = this.window[best_end-1];
          scan_end  = this.window[best_end];
        }
      }
      scan = this.strstart;
    }
  } while (({curMatch = (prev[curMatch & WMASK] & 0xffff); curMatch}) > limit
             && {chainLength -= 1; chainLength != 0});

  this.matchLen = min(best_len, this.lookahead);
  this.matchLen >= MIN_MATCH;
}

def DeflaterEngine.setDictionary(buffer: [Byte], offset: Int, length: Int) {
  this.adler.updatearray(buffer, offset, length);
  if (length >= MIN_MATCH) {
    if (length > MAX_DIST) {
      offset += length - MAX_DIST;
      length = MAX_DIST;
    }

    acopy(buffer, offset, this.window, this.strstart, length);

    this.updateHash();
    length -= 1;
    while ({length -= 1; length > 0}) {
      this.insertString();
      this.strstart += 1;
    }
    this.strstart += 2;
    this.blockStart = this.strstart;
  }
}

def DeflaterEngine.deflateStored(flush: Bool, finish: Bool): Bool {
  var result = true
  
  if (!flush && this.lookahead == 0) {
    result = false;
  } else {
    this.strstart += this.lookahead;
    this.lookahead = 0;

    var storedLen = this.strstart - this.blockStart;

    if ((storedLen >= MAX_BLOCK_SIZE)
        /* Block is full */
        || (this.blockStart < WSIZE && storedLen >= MAX_DIST)
        /* Block may move out of window */
        || flush) {
      var lastBlock = finish;
      if (storedLen > MAX_BLOCK_SIZE) {
        storedLen = MAX_BLOCK_SIZE;
        lastBlock = false;
      }

      this.huffman.flushStoredBlock(this.window, this.blockStart, storedLen, lastBlock);
      this.blockStart += storedLen;
      result = !lastBlock;
    }
  }
  result;
}

def DeflaterEngine.deflateFast(flush: Bool, finish: Bool): Bool {
  var quit = false;
  var result = true;

  if (this.lookahead < MIN_LOOKAHEAD && !flush) {
    quit = true;
    result = false;
  }

  while (!quit && (this.lookahead >= MIN_LOOKAHEAD || flush)) {
    if (this.lookahead == 0) {
      /* We are flushing everything */
      this.huffman.flushBlock(this.window, this.blockStart,
              this.strstart - this.blockStart, finish);
      this.blockStart = this.strstart;
      quit = true;
      result = false;
    } else {

      if (this.strstart > 2 * WSIZE - MIN_LOOKAHEAD) {
        /* slide window, as findLongestMatch need this.
         * This should only happen when flushing and the window
         * is almost full.
         */
        this.slideWindow();
      }

      var hashHead: Int;
      var full = true;
      if (this.lookahead >= MIN_MATCH
          && ({hashHead = this.insertString(); hashHead}) != 0
          && this.strategy != HUFFMAN_ONLY
          && this.strstart - hashHead <= MAX_DIST
          && this.findLongestMatch(hashHead)) {
        /* longestMatch sets matchStart and matchLen */
        full = this.huffman.tallyDist(this.strstart - this.matchStart, this.matchLen);

        this.lookahead -= this.matchLen;
        if (this.matchLen <= this.max_lazy && this.lookahead >= MIN_MATCH) {
           while ({this.matchLen -= 1; this.matchLen > 0}) {
             this.strstart += 1;
             this.insertString();
           }
           this.strstart += 1;
        } else {
          this.strstart += this.matchLen;
          if (this.lookahead >= MIN_MATCH - 1)
            this.updateHash();
        }
        this.matchLen = MIN_MATCH - 1;
      } else {
        /* No match found */
        this.huffman.tallyLit(this.window[this.strstart] & 0xff);
        this.strstart += 1;
        this.lookahead -= 1;
      }

      if (full && this.huffman.isFull()) {
        var lastBlock = finish && this.lookahead == 0;
        this.huffman.flushBlock(this.window, this.blockStart,
            this.strstart - this.blockStart, lastBlock);
        this.blockStart = this.strstart;
        quit = true;
        result = !lastBlock;
      }
    }
  }
  result;
}

def DeflaterEngine.deflateSlow(flush: Bool, finish: Bool): Bool {
  var result = true;
  var quit = false;
  
  if (this.lookahead < MIN_LOOKAHEAD && !flush) {
    quit = true;
    result = false;
  }

  while (!quit && (this.lookahead >= MIN_LOOKAHEAD || flush)) {
    if (this.lookahead == 0) {
      if (this.prevAvailable)
        this.huffman.tallyLit(this.window[this.strstart-1] & 0xff);
      this.prevAvailable = false;

      /* We are flushing everything */
      this.huffman.flushBlock(this.window, this.blockStart,
              this.strstart - this.blockStart, finish);
      this.blockStart = this.strstart;
      quit = true;
      result = false;
    } else {

      if (this.strstart >= 2 * WSIZE - MIN_LOOKAHEAD) {
        /* slide window, as findLongestMatch need this.
         * This should only happen when flushing and the window
         * is almost full.
         */
        this.slideWindow();
      }

      var prevMatch = this.matchStart;
      var prevLen = this.matchLen;
      if (this.lookahead >= MIN_MATCH) {
        var hashHead = this.insertString();
        if (this.strategy != HUFFMAN_ONLY
            && hashHead != 0 && this.strstart - hashHead <= MAX_DIST
            && this.findLongestMatch(hashHead)) {
          /* longestMatch sets matchStart and matchLen */

          /* Discard match if too small and too far away */
          if (this.matchLen <= 5
                && (this.strategy == FILTERED
                        || (this.matchLen == MIN_MATCH
                            && this.strstart - this.matchStart > TOO_FAR))) {
            this.matchLen = MIN_MATCH - 1;
          }
        }
      }

      /* previous match was better */
      if (prevLen >= MIN_MATCH && this.matchLen <= prevLen) {
        this.huffman.tallyDist(this.strstart - 1 - prevMatch, prevLen);
        prevLen -= 2;
        do {
          this.strstart += 1;
          this.lookahead -= 1;
          if (this.lookahead >= MIN_MATCH)
            this.insertString();
        } while ({prevLen -= 1; prevLen > 0});
        this.strstart += 1;
        this.lookahead -= 1;
        this.prevAvailable = false;
        this.matchLen = MIN_MATCH - 1;
      } else {
        if (this.prevAvailable)
          this.huffman.tallyLit(this.window[this.strstart-1] & 0xff);
        this.prevAvailable = true;
        this.strstart += 1;
        this.lookahead -= 1;
      }

      if (this.huffman.isFull()) {
        var len = this.strstart - this.blockStart;
        if (this.prevAvailable)
          len -= 1;
        var lastBlock = (finish && this.lookahead == 0 && !this.prevAvailable);
        this.huffman.flushBlock(this.window, this.blockStart, len, lastBlock);
        this.blockStart += len;
        quit = true;
        result = !lastBlock;
      }
    }
  }
  result;
}

def DeflaterEngine.deflate(flush: Bool, finish: Bool): Bool {
  var progress: Bool;
  do {
    this.fillWindow();
    var canFlush = flush && this.inputOff == this.inputEnd;
    switch (this.comprFunc) {
      DEFLATE_STORED: progress = this.deflateStored(canFlush, finish);
      DEFLATE_FAST: progress = this.deflateFast(canFlush, finish);
      DEFLATE_SLOW: progress = this.deflateSlow(canFlush, finish);
      else: error(FAIL, null);
    }
  } while (this.pending.isFlushed()  /* repeat while we have no pending output */
           && progress);             /* and progress was made */

  progress;
}

def DeflaterEngine.setInput(buf: [Byte], off: Int, len: Int) {
  if (this.inputOff < this.inputEnd)
    error(ERR_ILL_STATE, "Old input was not completely processed");

  var end = off + len;

  /* We want to throw an ArrayIndexOutOfBoundsException early.  The
   * check is very tricky: it also handles integer wrap around.
   */
  if (0 > off || off > end || end > buf.len)
    error(ERR_RANGE, null);

  this.inputBuf = buf;
  this.inputOff = off;
  this.inputEnd = end;
}

def DeflaterEngine.needsInput(): Bool {
  this.inputEnd == this.inputOff;
}
