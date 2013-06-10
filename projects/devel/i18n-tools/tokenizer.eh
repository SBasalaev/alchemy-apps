use "textio.eh"

type Tokenizer;

const TT_EOF = -1
const TT_WORD = -2

def Tokenizer.new(r: Reader);
def Tokenizer.ttype(): Int;
def Tokenizer.value(): String;
def Tokenizer.lineno(): Int;
def Tokenizer.pushback();
def Tokenizer.next(): Int;