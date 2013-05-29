use "mbasic.eh" 
use "list.eh"
use "dict.eh"
use "tokenizer.eh"

type BasicFunc {
  name: String,
  args: String,
  rettype: Int,
  impl: Function
}

type BasicVM {
  size: Int,
  current: Int,
  state: Int,
  modules: List,
  constants: List,
  varcount: Int,
  varnames: [String],
  varvalues: [Array],
  labels: [Int],
  forframes: Dict,
  program: [[Byte]],
  stack: [Any],
  stackpos: Int,
  functions: List,
  commands: List,
  tokenizer: Tokenizer,
  usestd: Bool,
  channels: [Any],
  channelstates: [Byte]
}

const CHANNEL_CLOSED = 0
const CHANNEL_INPUT = 1
const CHANNEL_OUTPUT = 2

/* Executes bytecoded command. */
def BasicVM.exec(command: [Byte]);
/* Finds index of command with given label. */
def BasicVM.indexof(label: Int): Int;
/* Prints program list within given labels inclusively. */
def BasicVM.list(from: Int, to: Int);

def BasicVM.get_varindex(name: String, create: Bool): Int;

def BasicVM.functionindex(name: String): Int;
def BasicVM.commandindex(name: String): Int;

def BasicVM.addstdfunctions();
