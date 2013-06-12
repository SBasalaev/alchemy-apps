use "textio.eh"
use "dict.eh"

type CfgReader;

def CfgReader.new(r: Reader, name: String);
def CfgReader.nextSection(): Dict;
def CfgReader.close();