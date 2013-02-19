/* Library to detect file type. */

type FTypeDB;

type FileType {
  description: String,
  category: String,
  command: String
}

// file categories
const DIR = "dir"
const EXEC = "exec"
const TEXT = "text"
const IMAGE = "image"
const AUDIO = "audio"
const VIDEO = "video"
const LIB = "lib"
const WEB = "web"
const ARCHIVE = "archive"
const UNKNOWN = ""

/* Loads database. */
def ftype_loaddb(): FTypeDB;
/* Returns filetype for given extension, null if not found. */
def ftype_for_ext(db: FTypeDB, ext: String): FileType;
/* Detects filetype of given file. */
def ftype_for_file(db: FTypeDB, file: String): FileType;
