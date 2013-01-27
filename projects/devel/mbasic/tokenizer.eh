type Tokenizer;

/* Token types. */
const TT_EOF = -1
const TT_INT = 0
const TT_FLOAT = 1
const TT_STRING = 2
const TT_WORD = 3
const TT_OPERATOR = 4

def new_tokenizer(): Tokenizer;

def Tokenizer.set_source(source: String);
def Tokenizer.next(): Int;
def Tokenizer.get_type(): Int;
def Tokenizer.get_value(): String;
def Tokenizer.pushback();
def Tokenizer.set_raw();
