use "streammanipulator.eh"

type OutputWindow;

def new_OutputWindow(): OutputWindow;
def OutputWindow.write(abyte: Int);
def OutputWindow.repeat(len: Int, dist: Int);
def OutputWindow.copyStored(input: StreamManipulator, len: Int): Int;
def OutputWindow.copyDict(dict: [Byte], offset: Int, len: Int);
def OutputWindow.getFreeSpace(): Int;
def OutputWindow.getAvailable(): Int;
def OutputWindow.copyOutput(output: [Byte], offset: Int, len: Int): Int;
def OutputWindow.reset();
