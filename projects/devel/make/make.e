/* Make utility for Alchemy OS
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "hash.eh"
use "string.eh"
use "sys.eh"
use "textio.eh"
use "vector.eh"

const VERSION = "Alchemy make 1.0"
const HELP = "Usage: make [options] [targets]\n\nOptions:\n-h this help\n-v product version\n-s silent mode\n-C change directory"

type Rule {
  target: String,
  deps: Array,
  exec: Array
}

var def_rule: Rule
var rules: Hashtable
var vars: Hashtable

/* Do variable substitution in line. */
def substvars(line: String): String {
  var sb = new_sb()
  while (strlen(line) > 0) {
    var S = strindex(line, '$')
    if (S < 0 || S >= strlen(line)) {
      sb_append(sb, line)
      line = ""
    } else {
      sb_append(sb, substr(line, 0, S))
      line = substr(line, S+1, strlen(line))
      var ch = strchr(line, 0)
      if (ch == '$') {
        sb_addch(sb, '$')
        line = substr(line, 1, strlen(line))
      } else if (ch == '{') {
        var rbrace = strindex(line, '}')
        if (rbrace < 0) rbrace = strlen(line)
        var value = ht_get(vars, substr(line, 1, rbrace))
        if (value == null) value = ""
        sb_append(sb, value)
        line = substr(line, rbrace+1, strlen(line))
      } else {
        var chstr = to_str(sb_addch(new_sb(), ch))
        var value = ht_get(vars, chstr)
        if (value == null) value = ""
        sb_append(sb, value)
        line = substr(line, 1, strlen(line))
      }
    }
  }
  to_str(sb)
}

/* Build named target. */
def build(target: String, silent: Bool): Bool {
  var rule = cast (Rule) ht_get(rules, target)
  if (rule == null) {
    // if no rule just check if file exists
    if (exists(target)) {
      true
    } else {
      fprintln(stderr(), "** No rule to build target "+target)
      false
    }
  } else {
    var ok = true
    // build dependencies
    for (var i=0, ok && i<rule.deps.len, i=i+1) {
      ok = build(to_str(rule.deps[i]), silent)
    }
    if (ok) {
      // test if we need to build target
      var needs = !exists(target)
      if (!needs) {
        var time = fmodified(target)
        for (var i=0, !needs && i<rule.deps.len, i=i+1) {
          needs = time < fmodified(to_str(rule.deps[i]))
        }
      }
      // build target
      if (needs) {
        for (var i=0, ok && i<rule.exec.len, i=i+1) {
          if (!silent) println(rule.exec[i])
          ok = 0 == exec_wait("sh", new Array {"-c", rule.exec[i]})
        }
      }
      if (!ok) {
        fprintln(stderr(), "** Failed to build target "+target)
      }
    }
    ok
  }
}

/* Parses makefile. */
def parse(r: Reader): Bool {
  var ok = true
  var lineno = 1
  var line = freadline(r)
  var rule: Rule;
  var commands = new_vector()
  while (ok && line != null) {
    if (strlen(line) == 0 || strchr(line, 0) == '#') {
      //skip this line
    } else if (strchr(line, 0) == ' ') {
      // add command to the target
      if (rule == null) {
        fprintln(stderr(), "makefile:"+lineno+": ** Commands before first target. Stop.")
        ok = false
      } else {
        v_add(commands, substvars(strtrim(line)))
      }
    } else if (strindex(line, '=') > 0) {
      // add variable
      var eq = strindex(line, '=')
      ht_put(vars, strtrim(substr(line, 0, eq)), strtrim(substr(line, eq+1, strlen(line))))
    } else if (strindex(line, ':') > 0) {
      // start new target
      if (rule != null) {
        rule.exec = v_toarray(commands)
        ht_put(rules, rule.target, rule)
        commands = new_vector()
        if (def_rule == null) def_rule = rule
      }
      var cl = strindex(line, ':')
      rule = new Rule(
        target = substr(line, 0, cl),
        deps = strsplit(substr(line, cl+1, strlen(line)), ' ')
      )
    } else {
      fprintln(stderr(), "makefile:"+lineno+": Syntax error")
      ok = false
    }
    line = freadline(r)
    lineno = lineno+1
  }
  if (rule != null) {
    rule.exec = v_toarray(commands)
    ht_put(rules, rule.target, rule)
    if (def_rule == null) def_rule = rule
  }
  ok
}

def main(args: Array): Int {
  // init
  rules = new_ht()
  vars = new_ht()
  var result = 0
  var exit = false
  // parse args
  var targets = new_vector()
  var todir = ""
  var silent = false
  var readdir = false
  for (var i=0, i < args.len, i=i+1) {
    if (readdir) {
      readdir = false
      todir = to_str(args[i])
    } else {
      var arg = to_str(args[i])
      if (arg == "-h") {
        println(HELP)
        exit = true
      } else if (arg == "-v") {
        println(VERSION)
        exit = true
      } else if (arg == "-s") {
        silent = true
      } else if (arg == "-C") {
        readdir = true
      } else if (strchr(arg, 0) == '-') {
        fprintln(stderr(), "make: Unknown option: "+arg)
        result = 2
        exit = true
      } else {
        v_add(targets, arg)
      }
    }
  }
  // apply args
  if (strlen(todir) > 0) set_cwd(todir)
  if (readdir) {
    fprintln(stderr(), "** -C must precede dir name")
    result = 2
    exit = true
  }
  // check makefile
  var fname = "Makefile"
  if (!exit) {
    if (!exists(fname)) {
      fname = "makefile"
      if (!exists(fname)) {
        fprintln(stderr(), "** Makefile not found")
        exit = true
        result = 2
      }
    }
  }
  // parse makefile
  if (!exit) {
    var in = fopen_r(fname)
    var r = utfreader(in)
    if (!parse(r)) {
      exit = true
      result = 2
    }
    fclose(in)
  }
  // build
  if (!exit) {
    var ok = true
    if (v_size(targets) == 0) {
      ok = build(def_rule.target, silent)
    } else for (var i=0, ok && i < v_size(targets), i=i+1) {
      ok = build(to_str(v_get(targets, i)), silent)
    }
    result = if (ok) 0 else 1
  }
  result
}