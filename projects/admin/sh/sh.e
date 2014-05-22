/* 
 * This is a shell with the most basic capatibilities.
 * Copyright (C) 2011-2014, Sergey Basalaev <sbasalaev@gmail.com>
 * License: GPL-3
 */

use "list"
use "io"
use "strbuf"
use "bufferio"
use "textio"
use "term"
use "process"

const VERSION = "Shell v2.2"
const HELP =
  "Basic command line\n" +
  "Usage:\n" +
  " sh [file]\n" +
  " sh -c <cmd> <args>..."

type ShellCommand {
  cmd: String,
  args: [String],
  inp: String,
  out: String,
  appendout: Bool,
  err: String,
  appenderr: Bool
}

const MODE_CMD = 0
const MODE_ARG = 1
const MODE_QARG = 2
const MODE_IN = 3
const MODE_OUT_W = 4
const MODE_OUT_A = 5
const MODE_ERR_W = 6
const MODE_ERR_A = 7

def split(line: String): ShellCommand {
  var cc = new ShellCommand { }
  var argv = new List()
  var mode = MODE_CMD
  while (line.len() > 0) {
    var end = 0
    var token = ""
    if (line[0] == '\'') {
      end = line.indexof('\'', 1)
      if (end < 0)
        throw(ERR_ILL_ARG, "Unclosed '")
      token = line[1:end]
      line = line[end+1:].trim()
      if (mode == MODE_ARG)
        mode = MODE_QARG
    } else if (line[0] == '"') {
      end = line.indexof('"', 1)
      if (end < 0)
        throw(ERR_ILL_ARG, "Unclosed \"")
      token = line[1:end]
      line = line[end+1:].trim()
      if (mode == MODE_ARG)
        mode = MODE_QARG
    } else if (line[0] == '#') {
      break
    } else {
      end = line.indexof(' ')
      if (end < 0) end = line.len()
      token = line[:end]
      line = line[end:].trim()
    }
    if (token.len() == 0) {
      continue
    }
    switch (mode) {
      MODE_CMD: {
        cc.cmd = token
        mode = MODE_ARG
      }
      MODE_IN: {
        cc.inp = token
        mode = MODE_ARG
      }
      MODE_OUT_W: {
        cc.out = token
        cc.appendout = false
        mode = MODE_ARG
      }
      MODE_OUT_A: {
        cc.out = token
        cc.appendout = true
        mode = MODE_ARG
      }
      MODE_ERR_W: {
        cc.err = token
        cc.appenderr = false
        mode = MODE_ARG
      }
      MODE_ERR_A: {
        cc.err = token
        cc.appenderr = true
        mode = MODE_ARG
      }
      MODE_ARG:
        switch (token) {
          ">", "1>": mode = MODE_OUT_W
          ">>", "1>>": mode = MODE_OUT_A
          "2>": mode = MODE_ERR_W
          "2>>": mode = MODE_ERR_A
          "<": mode = MODE_IN
          else: argv.add(token)
        }
      MODE_QARG: {
        argv.add(token)
        mode = MODE_ARG
      }
    }
  }
  var args = new [String](argv.len())
  argv.copyInto(0, args)
  cc.args = args
  return cc
}

def main(args: [String]): Int {
  try {
    var exitcode = 0
    var scriptinput: IStream
    if (args.len == 0) {
      scriptinput = stdin()
    } else if (args[0] == "-h") {
      println(HELP)
      return 0
    } else if (args[0] == "-v") {
      println(VERSION)
      return 0
    } else if (args[0] == "-c") {
      if (args.len < 2) {
        stderr().println(HELP)
        return -1
      }
      var cmdline = new StrBuf().append(args[1])
      for (var i in 2 .. args.len-1) {
        cmdline.append(' ').append(args[i])
      }
      scriptinput = new BufferIStream(cmdline.tostr().utfbytes())
    } else {
      var file = abspath(args[0])
      var inp = fread(file)
      var buf = inp.readFully()
      inp.close()
      scriptinput = new BufferIStream(buf)
    }
    if (isTerm(stdin())) {
      stdin().cast(TermIStream).setPrompt(getCwd() + '>')
    }
    var r = utfreader(scriptinput)
    var lineno = 0
    while (true) try {
      var line = r.readLine()
      lineno += 1
      if (line == null) break
      line = line.trim()
      if (line.len() == 0) continue
      if (line[0] == '#') continue
      var cc: ShellCommand
      try { cc = split(line) }
      catch (var e) {
        stderr().println(lineno.tostr() + ':' + e.msg())
        if (isTerm(scriptinput)) continue
        else return 1
      }
      if (cc.cmd == "exit") {
        if (cc.args.len > 0) {
          try {
            exitcode = cc.args[0].toint()
          } catch (var e) {
            stderr().println("exit: Not a number: " + cc.args[0])
            exitcode = 1
          }
        } else {
          exitcode = 0
        }
        return exitcode
      } else if (cc.cmd == "cd") {
        if (cc.args.len > 0) {
          var newdir = abspath(cc.args[0])
          setCwd(newdir)
          if (isTerm(stdin())) {
            stdin().cast(TermIStream).setPrompt(getCwd() + '>')
          }
          exitcode = 0
        } else {
          stderr().println("cd: no directory specified")
          exitcode = 1
        }
      } else if (cc.cmd == "cls") {
        if (isTerm(stdin())) {
          stdin().cast(TermIStream).clear()
        }
        exitcode = 0
      } else {
        var child = new Process(cc.cmd, cc.args)
        var childin: IStream
        if (cc.inp != null) {
          childin = fread(cc.inp)
          child.setIn(childin)
        }
        var childout: OStream
        if (cc.out != null) {
          var outfile = abspath(cc.out)
          childout = (if (cc.appendout) fappend else fwrite)(outfile)
          child.setOut(childout)
        }
        var childerr: OStream
        if (cc.err != null) {
          var errfile = abspath(cc.err)
          childerr = (if (cc.appenderr) fappend else fwrite)(errfile)
          child.setErr(childerr)
        }
        if (isTerm(stdin())) {
          stdin().cast(TermIStream).setPrompt("")
        }
        exitcode = child.start().waitFor()
        if (childin != null) childin.close()
        if (childout != null) childout.close()
        if (childerr != null) childerr.close()
        if (child.getError() != null) {
          stderr().println(child.getError())
        }
        if (isTerm(stdin())) {
          stdin().cast(TermIStream).setPrompt(getCwd() + '>')
        }
      }
    } catch (var t) {
      stderr().println(errstring(t.code()) + ": " + t.msg())
      if (isTerm(stdin())) {
        stdin().cast(TermIStream).setPrompt(getCwd() + '>')
      }
    }
    return exitcode
  } catch (var e) {
    stderr().println(e)
    return FAIL
  }
}
