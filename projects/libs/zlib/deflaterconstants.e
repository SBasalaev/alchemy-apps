
def GOOD_LENGTH(at: Int): Int = switch (at) {
  0: 0;
  1: 4;
  2: 4;
  3: 4;
  4: 4;
  5: 8;
  6: 8;
  7: 8;
  8: 32;
  9: 32;
  else: -1;
}

def MAX_LAZY(at: Int): Int = switch (at) {
  0: 0;
  1: 4;
  2: 5;
  3: 6;
  4: 4;
  5: 16;
  6: 16;
  7: 32;
  8: 128;
  9: 258;
  else: -1;
}

def NICE_LENGTH(at: Int): Int = switch (at) {
  0: 0;
  1: 8;
  2: 16;
  3: 32;
  4: 16;
  5: 32;
  6: 128;
  7: 128;
  8: 258;
  9: 258;
  else: -1;
}

def MAX_CHAIN(at: Int): Int = switch (at) {
  0: 0;
  1: 4;
  2: 8;
  3: 32;
  4: 16;
  5: 32;
  6: 128;
  7: 256;
  8: 1024;
  9: 4096;
  else: -1;
}

def COMPR_FUNC(at: Int): Int = switch (at) {
  0: 0;
  1: 1;
  2: 1;
  3: 1;
  4: 1;
  5: 2;
  6: 2;
  7: 2;
  8: 2;
  9: 2;
  else: -1;
}
