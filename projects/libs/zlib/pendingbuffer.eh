type PendingBuffer;

def PendingBuffer.new(bufsize: Int);
def PendingBuffer.reset();
def PendingBuffer.writeByte(b: Int);
def PendingBuffer.writeShort(s: Int);
def PendingBuffer.writeInt(s: Int);
def PendingBuffer.writeBlock(block: [Byte], offset: Int, len: Int);
def PendingBuffer.getBitCount(): Int;
def PendingBuffer.alignToByte();
def PendingBuffer.writeBits(b: Int, count: Int);
def PendingBuffer.writeShortMSB(s: Int);
def PendingBuffer.isFlushed(): Bool;
def PendingBuffer.flush(output: [Byte], offset: Int, length: Int): Int;
def PendingBuffer.toByteArray(): [Byte];
