use "pendingbuffer.eh"

type DeflaterEngine;

def new_DeflaterEngine(pending: PendingBuffer): DeflaterEngine;
def DeflaterEngine.reset();
def DeflaterEngine.resetAdler();
def DeflaterEngine.getAdler(): Int;
def DeflaterEngine.getTotalIn(): Long;
def DeflaterEngine.setStrategy(strat: Int);
def DeflaterEngine.setLevel(lvl: Int);
def DeflaterEngine.setDictionary(buffer: BArray, offset: Int, length: Int);
def DeflaterEngine.deflate(flush: Bool, finish: Bool): Bool;
def DeflaterEngine.setInput(buf: BArray, off: Int, len: Int);
def DeflaterEngine.needsInput(): Bool;
