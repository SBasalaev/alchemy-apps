
// file categories
const FTYPE_AUDIO = "audio"
const FTYPE_BINARY = "bin"
const FTYPE_DIRECTORY = "dir"
const FTYPE_EXECUTABLE = "exec"
const FTYPE_IMAGE = "image"
const FTYPE_PACKAGE = "package"
const FTYPE_SCRIPT = "script"
const FTYPE_TEXT = "text"
const FTYPE_VIDEO = "video"
const FTYPE_WEB = "web"

type FileType {
  extension: String,
  category: String,
  description: String
}

type Application {
  name: String,
  icon: String,
  exec: String,
  extensions: [String],
  categories: [String]
}

def readApplication(name: String): Application;

type DesktopDB;

def DesktopDB.new();
def DesktopDB.getType(ext: String): FileType;
def DesktopDB.typeForFile(file: String): FileType;
def DesktopDB.allAppsFor(ext: String): [Application];
def DesktopDB.defaultAppFor(ext: String): Application;
