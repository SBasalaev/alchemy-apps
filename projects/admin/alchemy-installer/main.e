use "textio"
use "ui"
use "stdscreens"
use "dialog"
use "pkg"
use "infoscreens"
use "string"

const VERSION = "2.1.7"

const TASK_BASE = 0
const TASK_UI = 1

const STATUS_OK = 0
const STATUS_FAIL = 1
const STATUS_BASEONLY = 2

def writeString(file: String, msg: String, append: Bool = false) {
  var out = (if (append) fopen_a else fopen_w)(file)
  out.println(msg)
  out.flush()
  out.close()
}

def installSeq(progress: ProgressScreen, manager: PkgManager, seq: [String]) {
  var count = seq.len / 2
  for (var i=0, i<count, i+=1) {
    var pkgname = seq[i*2]
    var pkgurl = seq[i*2+1]
    var pkgversion = pkgurl[pkgurl.lindexof('_')+1 : pkgurl.len()-4]
    progress.setProgress(i+1, count, pkgname, pkgversion)
    // download package
    var tmpfile = "/tmp/" + pkgurl[pkgurl.lindexof('/')+1 : pkgurl.len()]
    var input = readurl(pkgurl)
    var out = fopen_w(tmpfile)
    out.writeall(input)
    input.close()
    out.close()
    pkg_arh_unpack(manager, tmpfile)
    fremove(tmpfile)
  }
}

def installBaseSystem(progress: ProgressScreen, manager: PkgManager) {
  pkg_refresh(manager)
  var seq = pkg_install_seq(manager,
    ["alchemy-core", "libcore-dev", "libui-dev", "nec", "elink", "ex", "pkg-arh", "mount"])
  progress.show()
  installSeq(progress, manager, seq)
}

def configureBaseSystem() {
  writeString("/cfg/pkg/sources",
    "http://alchemy-os.org/pkg 2.1/main\n" +
    "http://alchemy-os.org/pkg 2.1/nonfree", true)
  writeString("/bin/ec", "#=nec")
  writeString("/bin/el", "#=elink")
}

def installUi(progress: ProgressScreen, manager: PkgManager) {
  var seq = pkg_install_seq(manager, ["alchemy-gui"])
  progress.show()
  installSeq(progress, manager, seq)
}

def installUpdates(progress: ProgressScreen, manager: PkgManager) {
  var ok = true
  try {
    pkg_refresh(manager)
  } catch {
    showMessage("Error", "Failed to download package lists. Updates will not be installed.")
    ok = false
  }
  if (ok) {
    var seq = pkg_install_seq(manager, pkg_list_installed(manager))
    if (seq.len > 0) {
      progress.show()
      installSeq(progress, manager, seq)
    }
  }
}

def makeInit(task: Int) {
  if (!exists("/cfg/init.user")) fcreate("/cfg/init.user")
  var out = utfwriter(fopen_w("/cfg/init"))
  out.println("mount /dev devfs")
  out.println("sh /cfg/init.user")
  if (task == TASK_BASE) {
    out.println("terminal")
  } else {
    out.println("appmenu")
  }
  out.flush()
  out.close()
}

def removeInstaller() {
  try {
    fremove("/bin/alchemy-installer")
  } catch { }
}

def main(args: [String]): Int {
  var status = STATUS_OK
  try {
    // initialization
    var message = new MessageScreen("Installer")
    message.setMessage("Preparing to install")
    message.show()
    var progress = new ProgressScreen("Installer")
    var upgrade = exists("/cfg/pkg/db/sources/installed")
    if (!upgrade) {
      fcreate("/cfg/pkg/db/sources/installed")
    }
    writeString("/cfg/pkg/sources", "res:/pkg 2.1")
    var manager = pkg_init()
    // choosing install task
    var task: Int
    if (upgrade) {
      // task is selected based on presence of alchemy-gui package
      if (pkg_query_installed(manager, "alchemy-gui") != null) task = TASK_UI
      else task = TASK_BASE
    } else {
      task = showOption("Install variant",
        ["Base system", "Standard UI"],
        ["This variant will only install system utilities and terminal session. 60 KiB to install.",
         "This variant will install graphical user interface. 90 KiB to install."])
    }
    // installing base system and local updates
    try {
      message.setMessage("Reading local repository")
      message.show()
      progress.setMessage("Installing base system")
      installBaseSystem(progress, manager)
      message.show()
      progress.setMessage("Installing updates")
      installUpdates(progress, manager)
    } catch (var e) {
      status = STATUS_FAIL
      showMessage("Error", "The base system could not be installed properly.\n\n" + e)
    }
    // TODO: remove outdated packages on upgrade
    // configuring base system
    if (status == STATUS_OK) try {
      message.setMessage("Configuring base system")
      message.show()
      configureBaseSystem()
    } catch (var e) {
      status = STATUS_FAIL
      showMessage("Error", "The base system could not be configured properly.\n\n" + e)
    }
    // install chosen task
    if (!upgrade && status == STATUS_OK && task == TASK_UI) try {
      message.setMessage("Reading local repository")
      message.show()
      progress.setMessage("Installing user interface")
      installUi(progress, manager)
    } catch (var e) {
      status == STATUS_BASEONLY
      showMessage("Error", "Could not install user interface.\n\n" + e)
    }
    // downloading and installing updates
    if (status == STATUS_OK && showYesNo("Updates",
        "Do you want to download and install the latest updates?" +
        "Requires internet connection!")) try {
      message.setMessage("Downloading package lists")
      message.show()
      progress.setMessage("Installing updates")
      installUpdates(progress, manager)
    } catch (var e) {
      showMessage("Error", "Updates could not be properly installed.\n\n" + e)
    }
    // generate startup script and remove installer
    if (status == STATUS_BASEONLY) task = TASK_BASE
    if (status != STATUS_FAIL) try {
      message.setMessage("Configuring system")
      message.show()
      makeInit(task)
      removeInstaller()
    } catch (var e) {
      showMessage("Error", "Failed to configure system.\n\n" + e)
      status = STATUS_FAIL
    }
    // show goodbye message
    var msg = switch (status) {
      STATUS_OK:
        "Alchemy OS " + VERSION + " has been successfully installed. " +
        "We hope you enjoy it!"
      STATUS_BASEONLY:
        "User interface could not be installed, base terminal session was " +
        "configured instead. You can try to install user interface later."
      else:
        "For some reason installation failed. Sorry :("
    }
    showMessage("Installer", msg)
    status
  } catch (var e) {
    showMessage("Fatal Error", "There was a terrible error. Installation cannot proceed.\n\n" + e)
    STATUS_FAIL
  }
}
