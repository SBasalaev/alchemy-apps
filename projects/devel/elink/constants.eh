const SUPPORTED = 0x0201;

const VERSION = "Ether linker version 2.1";

const HELP =
 "Usage: el [options] <input>...\nOptions:\n" +
 "-o <output>\n write to this file\n" +
 "-l<lib>\n link with given library\n" +
 "-L<path>\n append path to LIBPATH\n" +
 "-s<soname>\n use this soname\n" +
 "-h\n print this help and exit\n" +
 "-v\n print version and exit";

const ERR_LINKER = 2

const LFLAG_SONAME = 1;       /* Library has soname. */
const LFLAG_DEPS = 2;         /* Library has dependencies. */
const LFLAG_COMMENT = 0x8000; /* Library has comment section. */

const FFLAG_SHARED = 1;       /* Function is shared. */
const FFLAG_RELOCS = 2;       /* Function has relocation table. */
const FFLAG_LNUM   = 4;       /* Function has line number table. */
const FFLAG_ERRTBL = 8;       /* Function has error table. */
const FFLAG_COMMENT = 0x8000; /* Function has comment section. */