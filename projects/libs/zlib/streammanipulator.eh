type StreamManipulator;

def new_StreamManipulator(): StreamManipulator;
def StreamManipulator.peekBits(n: Int): Int;
def StreamManipulator.dropBits(n: Int);
def StreamManipulator.getBits(n: Int): Int;
def StreamManipulator.getAvailableBits(): Int;
def StreamManipulator.getAvailableBytes(): Int;
def StreamManipulator.skipToByteBoundary();
def StreamManipulator.needsInput(): Bool;
def StreamManipulator.copyBytes(output: BArray, offset: Int, length: Int): Int;
def StreamManipulator.reset();
def StreamManipulator.setInput(buf: BArray, off: Int, len: Int);
