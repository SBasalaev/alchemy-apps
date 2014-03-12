use "deflater.eh"

use "deflaterconstants.eh"
use "deflaterengine.eh"
use "pendingbuffer.eh"

const IS_SETDICT              = 0x01;
const IS_FLUSHING             = 0x04;
const IS_FINISHING            = 0x08;

const INIT_STATE              = 0x00;
const SETDICT_STATE           = 0x01;
const INIT_FINISHING_STATE    = 0x08;
const SETDICT_FINISHING_STATE = 0x09;
const BUSY_STATE              = 0x10;
const FLUSHING_STATE          = 0x14;
const FINISHING_STATE         = 0x1c;
const FINISHED_STATE          = 0x1e;
const CLOSED_STATE            = 0x7f;

type Deflater {
  level: Int,
  noHeader: Bool,
  state: Int,
  totalOut: Long,
  pending: PendingBuffer,
  engine: DeflaterEngine
}

def Deflater.new(lvl: Int = DEFAULT_COMPRESSION, nowrap: Bool = false) {
  this.pending = new PendingBuffer(PENDING_BUF_SIZE);
  this.noHeader = nowrap;
  this.engine = new DeflaterEngine(this.pending);
  this.setStrategy(DEFAULT_STRATEGY);
  this.setLevel(lvl);
  this.reset();
}

def Deflater.reset() {
  this.state = if (this.noHeader) BUSY_STATE else INIT_STATE;
  this.totalOut = 0;
  this.pending.reset();
  this.engine.reset();
}

def Deflater.end() {
  this.engine = null;
  this.pending = null;
  this.state = CLOSED_STATE;
}

def Deflater.getAdler(): Int {
  return this.engine.getAdler();
}

def Deflater.getBytesRead(): Long {
  return this.engine.getTotalIn();
}

def Deflater.getBytesWritten(): Long {
  return this.totalOut;
}

def Deflater.flush() {
  this.state |= IS_FLUSHING;
}

def Deflater.finish() {
  this.state |= IS_FLUSHING | IS_FINISHING;
}

def Deflater.finished(): Bool {
  return this.state == FINISHED_STATE && this.pending.isFlushed();
}

def Deflater.needsInput(): Bool {
  return this.engine.needsInput();
}

def Deflater.setInput(input: [Byte], off: Int, len: Int) {
  if ((this.state & IS_FINISHING) != 0)
    throw(ERR_ILL_ARG, "finish()/end() already called");
  this.engine.setInput(input, off, len);
}

def Deflater.setLevel(lvl: Int) {
  if (lvl == DEFAULT_COMPRESSION)
    lvl = 6
  else if (lvl < NO_COMPRESSION || lvl > BEST_COMPRESSION)
    throw(ERR_ILL_ARG, null);

  if (this.level != lvl) {
    this.level = lvl;
    this.engine.setLevel(lvl);
  }
}

def Deflater.setStrategy(stgy: Int) {
  if (stgy != DEFAULT_STRATEGY && stgy != FILTERED
        && stgy != HUFFMAN_ONLY)
    throw(ERR_ILL_ARG, null);
  this.engine.setStrategy(stgy);
}

def Deflater.setDictionary(dict: [Byte], offset: Int, length: Int) {
  if (this.state != INIT_STATE)
    throw(ERR_ILL_STATE, null);

  this.state = SETDICT_STATE;
  this.engine.setDictionary(dict, offset, length);
}

def Deflater.deflate(output: [Byte], offset: Int, length: Int): Int {
  var origLength = length;

  if (this.state == CLOSED_STATE)
    throw(ERR_ILL_STATE, "Deflater closed");

  if (this.state < BUSY_STATE) {
    /* output header */
    var header = (DEFLATED + ((MAX_WBITS - 8) << 4)) << 8;
    var level_flags = (this.level - 1) >> 1;
    if (level_flags < 0 || level_flags > 3)
      level_flags = 3;
    header |= level_flags << 6;
    if ((this.state & IS_SETDICT) != 0)
      /* Dictionary was set */
      header |= PRESET_DICT;
    header += 31 - (header % 31);

    this.pending.writeShortMSB(header);
    if ((this.state & IS_SETDICT) != 0) {
      var chksum = this.engine.getAdler();
      this.engine.resetAdler();
      this.pending.writeShortMSB(chksum >> 16);
      this.pending.writeShortMSB(chksum & 0xffff);
    }

    this.state = BUSY_STATE | (this.state & (IS_FLUSHING | IS_FINISHING));
  }

  while (true) {
    var count = this.pending.flush(output, offset, length);
    offset += count;
    this.totalOut += count;
    length -= count;
    if (length == 0 || this.state == FINISHED_STATE) {
      break;
    } else {
      if (!this.engine.deflate((this.state & IS_FLUSHING) != 0,
              (this.state & IS_FINISHING) != 0)) {
        if (this.state == BUSY_STATE) {
          /* We need more input now */
          break;
        } else if (this.state == FLUSHING_STATE) {
          if (this.level != NO_COMPRESSION) {
            /* We have to supply some lookahead.  8 bit lookahead
             * are needed by the zlib inflater, and we must fill
             * the next byte, so that all bits are flushed.
             */
            var neededbits = 8 + ((-this.pending.getBitCount()) & 7);
            while (neededbits > 0) {
              /* write a static tree block consisting solely of
               * an EOF:
               */
              this.pending.writeBits(2, 10);
              neededbits -= 10;
            }
          }
          this.state = BUSY_STATE;
        } else if (this.state == FINISHING_STATE) {
          this.pending.alignToByte();
          /* We have completed the stream */
          if (!this.noHeader) {
            var adler = this.engine.getAdler();
            this.pending.writeShortMSB(adler >> 16);
            this.pending.writeShortMSB(adler & 0xffff);
          }
          this.state = FINISHED_STATE;
        }
      }
    }
  }

  return origLength - length;
}
