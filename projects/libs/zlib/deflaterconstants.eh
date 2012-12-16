const STORED_BLOCK = 0;
const STATIC_TREES = 1;
const DYN_TREES = 2;
const PRESET_DICT = 0x20;

const DEFAULT_MEM_LEVEL = 8;

const MAX_MATCH = 258;
const MIN_MATCH = 3;

const MAX_WBITS = 15;
const WSIZE = 1 << MAX_WBITS;
const WMASK = WSIZE - 1;

const HASH_BITS = DEFAULT_MEM_LEVEL + 7;
const HASH_SIZE = 1 << HASH_BITS;
const HASH_MASK = HASH_SIZE - 1;
const HASH_SHIFT = (HASH_BITS + MIN_MATCH - 1) / MIN_MATCH;

const MIN_LOOKAHEAD = MAX_MATCH + MIN_MATCH + 1;
const MAX_DIST = WSIZE - MIN_LOOKAHEAD;

const PENDING_BUF_SIZE = 1 << (DEFAULT_MEM_LEVEL + 8);
const MAX_BLOCK_SIZE = if (65535 < PENDING_BUF_SIZE-5) 65535 else PENDING_BUF_SIZE-5;

const DEFLATE_STORED = 0;
const DEFLATE_FAST = 1;
const DEFLATE_SLOW = 2;

def GOOD_LENGTH(at: Int): Int;
def MAX_LAZY(at: Int): Int;
def NICE_LENGTH(at: Int): Int;
def MAX_CHAIN(at: Int): Int;
def COMPR_FUNC(at: Int): Int;
