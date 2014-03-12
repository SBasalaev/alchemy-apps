use "pendingbuffer.eh"

type DeflaterEngine;

def DeflaterEngine.new(pending: PendingBuffer);
def DeflaterEngine.reset();
def DeflaterEngine.resetAdler();
def DeflaterEngine.getAdler(): Int;
def DeflaterEngine.getTotalIn(): Long;
def DeflaterEngine.setStrategy(strat: Int);
def DeflaterEngine.setLevel(lvl: Int);
def DeflaterEngine.setDictionary(buffer: [Byte], offset: Int, length: Int);
def DeflaterEngine.deflate(flush: Bool, finish: Bool): Bool;
def DeflaterEngine.setInput(buf: [Byte], off: Int, len: Int);
def DeflaterEngine.needsInput(): Bool;
