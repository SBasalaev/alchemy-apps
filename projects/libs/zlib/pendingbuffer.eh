type PendingBuffer;

def new_PendingBuffer(bufsize: Int): PendingBuffer;
def PendingBuffer.reset();
def PendingBuffer.writeByte(b: Int);
def PendingBuffer.writeShort(s: Int);
def PendingBuffer.writeInt(s: Int);
def PendingBuffer.writeBlock(block: BArray, offset: Int, len: Int);
def PendingBuffer.getBitCount(): Int;
def PendingBuffer.alignToByte();
def PendingBuffer.writeBits(b: Int, count: Int);
def PendingBuffer.writeShortMSB(s: Int);
def PendingBuffer.isFlushed(): Bool;
def PendingBuffer.flush(output: BArray, offset: Int, length: Int): Int;
def PendingBuffer.toByteArray(): BArray;
