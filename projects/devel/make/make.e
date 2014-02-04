/* Make utility for Alchemy OS
 * Copyright (c) 2012-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "dict"
use "list"
use "strbuf"
use "sys"
use "textio"

const VERSION = "make 1.5"
const HELP = "Usage: make [options] [targets]\n" +
             "Options:\n" +
             "-h this help\n" +
             "-v product version\n" +
             "-s silent mode\n" +
             "-C change directory"

type Rule {
  target: String,
  deps: [String],
  exec: [String]
}

var def_rule: Rule
var rules: Dict
var vars: Dict

/* Do variable substitution in line. */
def substvars(line: String): String {
  var sb = new StrBuf()
  while (line.len() > 0) {
    var S = line.indexof('$')
    if (S < 0 || S >= line.len()) {
      sb.append(line)
      line = ""
    } else {
      sb.append(line[:S])
      line = line[S+1:]
      var ch = line[0]
      if (ch == '$') {
        sb.addch('$')
        line = line[1:]
      } else if (ch == '{') {
        var rbrace = line.indexof('}')
        if (rbrace < 0) rbrace = line.len()
        var value = vars[line[1:rbrace]]
        if (value == null) value = ""
        sb.append(value)
        line = line[rbrace+1:]
      } else {
        var value = vars[ch.tostr()]
        if (value == null) value = ""
        sb.append(value)
        line = line[1:]
      }
    }
  }
  return sb.tostr()
}

/* Build named target. */
def build(target: String, silent: Bool): Bool {
  var rule = rules[target].cast(Rule)
  if (rule == null) {
    // if no rule just check if file exists
    if (exists(target)) {
      return true
    } else {
      stderr().println("** No rule to build target "+target)
      return false
    }
  }
  var ok = true
  // build dependencies
  for (var i=0, ok && i<rule.deps.len, i+=1) {
    ok = build(rule.deps[i], silent)
  }
  if (ok) {
    // test if we need to build target
    var needs = !exists(target)
    if (!needs) {
      var time = fmodified(target)
      for (var i=0, !needs && i<rule.deps.len, i+=1) {
        needs = time < fmodified(rule.deps[i])
      }
    }
    // build target
    if (needs) {
      for (var i=0, ok && i<rule.exec.len, i+=1) {
        if (!silent) println(rule.exec[i])
        ok = 0 == execWait("sh", ["-c", rule.exec[i]])
      }
    }
    if (!ok) {
      stderr().println("** Failed to build target "+target)
    }
  }
  return ok
}

/* Parses makefile. */
def readmf(fname: String): Bool {
  var r = utfreader(fread(fname))
  var ok = true
  var lineno = 1
  var line = r.readLine()
  var rule: Rule
  var commands = new List()
  while (ok && line != null) {
    if (line.len() == 0 || line[0] == '#') {
      //skip this line
    } else if (line[0] == ' ') {
      // add command to the target
      if (rule == null) {
        stderr().println(fname+":"+lineno+": Commands before first target. Stop.")
        ok = false
      } else {
        commands.add(substvars(line.trim()))
      }
    } else if (line.indexof('=') > 0) {
      // end target
      if (rule != null) {
        rule.exec = new [String](commands.len())
        commands.copyInto(0, rule.exec, 0, rule.exec.len)
        rules[rule.target] = rule
        commands = new List()
        if (def_rule == null) def_rule = rule
        vars.remove("@")
        vars.remove("<")
      }
      // add variable
      var eq = line.indexof('=')
      vars[line[:eq].trim()] = substvars(line[eq+1:].trim())
    } else if (line.indexof(':') > 0) {
      // start new target
      if (rule != null) {
        rule.exec = new [String](commands.len())
        commands.copyInto(0, rule.exec, 0, rule.exec.len)
        rules[rule.target] = rule
        commands = new List()
        if (def_rule == null) def_rule = rule
        vars.remove("<")
        vars.remove("@")
      }
      var cl = line.indexof(':')
      var target = substvars(line[:cl])
      var deps = substvars(line[cl+1:])
      vars["<"] = deps
      vars["@"] = target
      rule = new Rule { target = target, deps = deps.split(' ') }
    } else if (line.find("include ") == 0) {
      var incl_name = line[8:].trim()
      if (exists(incl_name)) {
        ok = readmf(incl_name)
      } else {
        ok = false
        stderr().println(fname+":"+lineno+": Included file does not exist: "+incl_name)
      }
    } else {
      stderr().println(fname+":"+lineno+": Syntax error")
      ok = false
    }
    line = r.readLine()
    lineno += 1
  }
  if (rule != null) {
    rule.exec = new [String](commands.len())
    commands.copyInto(0, rule.exec, 0, rule.exec.len)
    rules[rule.target] = rule
    if (def_rule == null) def_rule = rule
  }
  r.close()
  return ok
}

def main(args: [String]): Int {
  // init
  rules = new Dict()
  vars = new Dict()
  // parse args
  var targets = new List()
  var todir = ""
  var silent = false
  var readdir = false
  for (var arg in args) {
    if (readdir) {
      readdir = false
      todir = arg
    } else {
      if (arg == "-h") {
        println(HELP)
        return 0
      } else if (arg == "-v") {
        println(VERSION)
        return 0
      } else if (arg == "-s") {
        silent = true
      } else if (arg == "-C") {
        readdir = true
      } else if (arg.ch(0) == '-') {
        stderr().println("make: Unknown option: "+arg)
        return 2
      } else if (arg.indexof('=') > 0) {
        var eq = arg.indexof('=')
        vars[arg[:eq]] = arg[eq+1:]
      } else {
        targets.add(arg)
      }
    }
  }
  // apply args
  if (todir.len() > 0) setCwd(todir)
  if (readdir) {
    stderr().println("** -C must precede dir name")
    return 2
  }
  // check makefile
  var fname = "Makefile"
  if (!exists(fname)) {
    fname = "makefile"
    if (!exists(fname)) {
      stderr().println("** Makefile not found")
      return 2
    }
  }
  // parse makefile
  if (!readmf(fname)) {
    return 2
  }
  // build
  var ok = true
  if (targets.len() == 0) {
    ok = build(def_rule.target, silent)
  } else for (var i=0, ok && i < targets.len(), i+=1) {
    ok = build(targets[i].tostr(), silent)
  }
  return if (ok) 0 else 1
}
