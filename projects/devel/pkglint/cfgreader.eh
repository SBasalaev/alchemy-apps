use "textio.eh"
use "dict.eh"

type CfgReader;

def new_cfgreader(r: Reader, name: String): CfgReader;
def CfgReader.next_section(): Dict;
def CfgReader.close();