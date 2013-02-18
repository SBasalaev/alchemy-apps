use "outputwindow.eh"

use "maxmin.eh"

use "error.eh"
use "sys.eh"

const WINDOW_SIZE = 1 << 15;
const WINDOW_MASK = WINDOW_SIZE - 1;

type OutputWindow {
  window: [Byte],
  window_end: Int,
  window_filled: Int
}

def new_OutputWindow(): OutputWindow {
  new OutputWindow(new [Byte](WINDOW_SIZE), 0, 0)
}

def OutputWindow.write(abyte: Int) {
  if (this.window_filled == WINDOW_SIZE)
    error(ERR_ILL_STATE, "Window full");
  this.window_filled += 1;
  this.window[this.window_end] = abyte;
  this.window_end += 1;
  this.window_end &= WINDOW_MASK;
}

def OutputWindow.slowRepeat(rep_start: Int, len: Int, dist: Int) {
  while (len > 0) {
    len -= 1;
    this.window[this.window_end] = this.window[rep_start];
    this.window_end += 1;
    rep_start += 1;
    this.window_end &= WINDOW_MASK;
    rep_start &= WINDOW_MASK;
  }
}

def OutputWindow.repeat(len: Int, dist: Int) {
  this.window_filled += len;
  if (this.window_filled > WINDOW_SIZE)
    error(ERR_ILL_STATE, "Window full");

  var rep_start = (this.window_end - dist) & WINDOW_MASK;
  var border = WINDOW_SIZE - len;
  if (rep_start <= border && this.window_end < border) {
    if (len <= dist) {
      acopy(this.window, rep_start, this.window, this.window_end, len);
      this.window_end += len;
    } else {
      // TODO: test if works without this, acopy handles overlaping copies!
      /* We have to copy manually, since the repeat pattern overlaps. */
      while (len > 0) {
        len -= 1;
        this.window[this.window_end] = this.window[rep_start];
        this.window_end += 1;
        rep_start += 1;
      }
    }
  } else {
    this.slowRepeat(rep_start, len, dist);
  }
}

def OutputWindow.copyStored(input: StreamManipulator, len: Int): Int {
  len = min(min(len, WINDOW_SIZE - this.window_filled), input.getAvailableBytes());
  var copied: Int;

  var tailLen = WINDOW_SIZE - this.window_end;
  if (len > tailLen) {
    copied = input.copyBytes(this.window, this.window_end, tailLen);
    if (copied == tailLen)
      copied += input.copyBytes(this.window, 0, len - tailLen);
  } else {
    copied = input.copyBytes(this.window, this.window_end, len);
  }

  this.window_end = (this.window_end + copied) & WINDOW_MASK;
  this.window_filled += copied;
  copied;
}

def OutputWindow.copyDict(dict: [Byte], offset: Int, len: Int) {
  if (this.window_filled > 0)
    error(ERR_ILL_STATE, null);

  if (len > WINDOW_SIZE) {
    offset += len - WINDOW_SIZE;
    len = WINDOW_SIZE;
  }
  acopy(dict, offset, this.window, 0, len);
  this.window_end = len & WINDOW_MASK;
}

def OutputWindow.getFreeSpace(): Int {
  WINDOW_SIZE - this.window_filled;
}

def OutputWindow.getAvailable(): Int {
  this.window_filled;
}

def OutputWindow.copyOutput(output: [Byte], offset: Int, len: Int): Int {
  var copy_end = this.window_end;
  if (len > this.window_filled)
    len = this.window_filled
  else
    copy_end = (this.window_end - this.window_filled + len) & WINDOW_MASK;

  var copied = len;
  var tailLen = len - copy_end;

  if (tailLen > 0) {
    acopy(this.window, WINDOW_SIZE - tailLen, output, offset, tailLen);
    offset += tailLen;
    len = copy_end;
  }
  acopy(this.window, copy_end - len, output, offset, len);
  this.window_filled -= copied;
  if (this.window_filled < 0)
    error(ERR_ILL_STATE, null);
  copied;
}

def OutputWindow.reset() {
  this.window_filled = 0;
  this.window_end = 0;
}
