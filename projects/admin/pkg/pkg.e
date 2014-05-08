use "pkg/pkg.eh"
use "io"

const VERSION = "pkg 2.0"
const HELP =
  "Command line package manager\n" +
  "Please refer to documentation for usage"

def humanSize(size: Int): String {
  if (size < 1100) {
    return "" + size + " B"
  }
  if (size < 1000000) {
    return "" + (size / 1000) + "." + (size / 100 % 10) + " KB"
  }
  return "" + (size / 1000000) + "." + (size / 100000 % 10) + " MB"
}

def failMsg(msg: String, err: Error) {
  println(msg)
  if (err != null) {
    println(err)
  }
}

def warnMsg(msg: String) {
  print("pkg warning: ")
  println(msg)
}

def installMsg(name: String, version: String, step: Int, total: Int) {
  println("[" + step + "/" + total + "] Installing " + name + " (" + version + ")")
}

def removeMsg(name: String, version: String, step: Int, total: Int) {
  println("[" + step + "/" + total + "] Removing " + name + " (" + version + ")")
}

def downloadMsg(baseUrl: String, name: String, step: Int, total: Int) {
  println("[" + step + "/" + total + "] Downloading " + name + " from " + baseUrl)
}

def installRequest(fromFile: Bool, seq: [Package]): Bool {
  if (seq.len == 0) {
    if (!fromFile) println("No packages will be installed or updated.")
    return true
  }
  // print package names and calculate size
  println("The following packages will be installed:")
  var size = 0
  for (var pkg in seq) {
    write(' ')
    print(pkg.name)
    size += pkg.size
  }
  write('\n')
  println("After installing " + humanSize(size) + " will be used.")
  // ask confirmation if more than one package
  if (seq.len == 1 && !fromFile) return true
  println("Do you wish to continue? [y/n]")
  var line = readline()
  return line.trim().lcase() == "y"
}

def removeRequest(seq: [Package]): Bool {
  if (seq.len == 0) {
    println("No packages will be removed.")
    return true
  }
  // print package names and calculate size
  println("The following packages will be removed:")
  var size = 0
  for (var pkg in seq) {
    write(' ')
    print(pkg.name)
    size += pkg.size
  }
  write('\n')
  println("After removing " + humanSize(size) + " will be freed.")
  // ask confirmation if more than one package
  if (seq.len == 1) return true
  println("Do you wish to continue? [y/n]")
  var line = readline()
  return line.trim().lcase() == "y"
}

def main(args: [String]): Int {
  if (args.len == 0) {
    println("pkg: no commands given")
    return FAIL
  } else if (args[0] == "-h") {
    println(HELP)
    return SUCCESS
  } else if (args[0] == "-v") {
    println(VERSION)
    return SUCCESS
  }

  var manager = initPkgManager()
  manager.onFail(failMsg)
  manager.onWarn(warnMsg)
  manager.onInstall(installMsg)
  manager.onRemove(removeMsg)
  manager.onDownload(downloadMsg)
  manager.onRemoveRequest(removeRequest)
  var ok = false
  switch (args[0]) {
    "install": {
      manager.onInstallRequest(installRequest.apply(false))
      manager.loadPkgLists()
      var names = new [String](args.len-1)
      acopy(args, 1, names, 0, names.len)
      ok = manager.install(names)
    }
    "installfile": {
      manager.onInstallRequest(installRequest.apply(true))
      manager.loadPkgLists()
      if (args.len < 2) {
        println("pkg: no files given to install")
        ok = false
      }
      for (var i=1, i<args.len, i+=1) {
        manager.installFile(args[i])
      }
    }
    "remove": {
      manager.loadPkgLists()
      var names = new [String](args.len-1)
      acopy(args, 1, names, 0, names.len)
      ok = manager.remove(names)
    }
    "refresh": {
      ok = manager.refresh()
    }
    "update": {
      manager.onInstallRequest(installRequest.apply(false))
      manager.loadPkgLists()
      var names = new [String](args.len-1)
      acopy(args, 1, names, 0, names.len)
      ok = manager.update(names)
    }
    else: {
      println("pkg: unknown command " + args[0])
      ok = false
    }
  }
  return if (ok) SUCCESS else FAIL
}
