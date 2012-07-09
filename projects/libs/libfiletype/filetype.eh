/* Library to determine file types. */

type FTypeDB;

type FileType {
  description: String,
  kind: String,
  command: String
}

def ftype_loaddb(): FTypeDB;
def ftype_for_ext(db: FTypeDB, ext: String): FileType;
def ftype_for_file(db: FTypeDB, file: String): FileType;
