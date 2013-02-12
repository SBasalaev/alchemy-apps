use "list.eh"
use "io.eh"
use "constants.eh"

/* Reads info from the library */
type LibInfo {
  soname: String, // Shared object name.
  symbols: List,  // Symbols that this library provides.
  index: Int,     // Index assigned to this library by linker.
  used: Bool      // Are symbols from this library actually used?
}

def loadLibInfo(libname: String): LibInfo;