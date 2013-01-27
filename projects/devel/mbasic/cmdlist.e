use "basicvm_impl.eh"
use "bytecode.eh"
use "io.eh"
use "string.eh"

/* Prints bytecoded expression at the given offset.
 * Returns offset after last expression bytecode.
 */
def BasicVM.listexpr(command: BArray, offset: Int): Int {
  offset += 1
  switch (command[offset-1]) {
    PARENS: {
      write('(')
      offset = this.listexpr(command, offset)
      write(')')
    }
    LDBYTE: {
      print(command[offset])
      offset += 1
    }
    LDSHORT: {
      print((command[offset] << 8) | (command[offset+1] & 0xff))
      offset += 2
    }
    LDINT, LDFLOAT: {
      var idx = ((command[offset] << 8) & 0xff) | (command[offset+1] & 0xff)
      print(this.constants[idx])
      offset += 2
    }
    LDSTRING: {
      var idx = ((command[offset] << 8) & 0xff) | (command[offset+1] & 0xff)
      var str = this.constants[idx].tostr()
      offset += 2
      write('"')
      for (var i=0, i < str.len(), i += 1) {
        var ch = str[i]
        switch (ch) {
          '\n': print("\\n");
          '\t': print("\\t");
          '\r': print("\\r");
          '\f': print("\\f");
          else: if (ch >= 32 && ch < 127) {
            write(ch)
          } else if (ch <= 0xff) {
            print("\\x")
            var n = ch >> 4
            write(if (n < 10) n+'0' else n+'a')
            n = ch & 0xf
            write(if (n < 10) n+'0' else n+'a')
          } else {
            print("\\u")
            var n = (ch >> 12) & 0xf
            write(if (n < 10) n+'0' else n+'a')
            n = (ch >> 8) & 0xf
            write(if (n < 10) n+'0' else n+'a')
            n = (ch >> 4) & 0xf
            write(if (n < 10) n+'0' else n+'a')
            n = ch & 0xf
            write(if (n < 10) n+'0' else n+'a')
          }
        }
      }
      write('"')
    }
    I2F, F2I: {
      offset = this.listexpr(command, offset)
    }
    IADD, FADD, STRCAT: {
      offset = this.listexpr(command, offset)
      print("+")
      offset = this.listexpr(command, offset)
    }
    ISUB, FSUB: {
      offset = this.listexpr(command, offset)
      print("-")
      offset = this.listexpr(command, offset)
    }
    IMUL, FMUL: {
      offset = this.listexpr(command, offset)
      print("*")
      offset = this.listexpr(command, offset)
    }
    IDIV, FDIV: {
      offset = this.listexpr(command, offset)
      print("/")
      offset = this.listexpr(command, offset)
    }
    IPWR, FPWR: {
      offset = this.listexpr(command, offset)
      print("^")
      offset = this.listexpr(command, offset)
    }
    IEQ, FEQ, SEQ: {
      offset = this.listexpr(command, offset)
      print("=")
      offset = this.listexpr(command, offset)
    }
    INOTEQ, FNOTEQ, SNOTEQ: {
      offset = this.listexpr(command, offset)
      print("<>")
      offset = this.listexpr(command, offset)
    }
    ILT, FLT, SLT: {
      offset = this.listexpr(command, offset)
      print("<")
      offset = this.listexpr(command, offset)
    }
    ILTEQ, FLTEQ, SLTEQ: {
      offset = this.listexpr(command, offset)
      print("<=")
      offset = this.listexpr(command, offset)
    }
    IGT, FGT, SGT: {
      offset = this.listexpr(command, offset)
      print(">")
      offset = this.listexpr(command, offset)
    }
    IGTEQ, FGTEQ, SGTEQ: {
      offset = this.listexpr(command, offset)
      print(">=")
      offset = this.listexpr(command, offset)
    }
    GETIVAR, GETFVAR, GETSVAR: {
      print(this.varnames[command[offset] & 0xff])
      offset += 1
    }
    IFUNC0, FFUNC0, SFUNC0: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      print(bf.name)
      write('(')
      write(')')
      offset += 1
    }
    IFUNC1, FFUNC1, SFUNC1: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      print(bf.name)
      write('(')
      offset = this.listexpr(command, offset+1)
      write(')')
    }
    IFUNC2, FFUNC2, SFUNC2: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      print(bf.name)
      write('(')
      offset = this.listexpr(command, offset+1)
      print(", ")
      offset = this.listexpr(command, offset)
      write(')')
    }
    IFUNC3, FFUNC3, SFUNC3: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      print(bf.name)
      write('(')
      offset = this.listexpr(command, offset+1)
      print(", ")
      offset = this.listexpr(command, offset)
      print(", ")
      offset = this.listexpr(command, offset)
      write(')')
    }
    IFUNC4, FFUNC4, SFUNC4: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      offset += 1
      print(bf.name)
      write('(')
      for (var j=0, j<4, j+=1) {
        if (j != 0) print(", ")
        offset = this.listexpr(command, offset)
      }
      write(')')
    }
    IFUNC5, FFUNC5, SFUNC5: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      offset += 1
      print(bf.name)
      write('(')
      for (var j=0, j<5, j+=1) {
        if (j != 0) print(", ")
        offset = this.listexpr(command, offset)
      }
      write(')')
    }
    IFUNC6, FFUNC6, SFUNC6: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      offset += 1
      print(bf.name)
      write('(')
      for (var j=0, j<6, j+=1) {
        if (j != 0) print(", ")
        offset = this.listexpr(command, offset)
      }
      write(')')
    }
    IFUNC7, FFUNC7, SFUNC7: {
      var bf = cast (BasicFunc) this.functions[command[offset] & 0xff]
      offset += 1
      print(bf.name)
      write('(')
      for (var j=0, j<7, j+=1) {
        if (j != 0) print(", ")
        offset = this.listexpr(command, offset)
      }
      write(')')
    }
  }
  offset
}

def BasicVM.list(from: Int, to: Int) {
  var fromidx = this.indexof(from)
  var toidx = this.indexof(to)
  if (toidx == this.size || this.labels[toidx] > to) toidx -= 1
  for (var i = fromidx, i <= toidx, i += 1) {
    print(this.labels[i])
    write(' ')
    var cmd = this.program[i]
    var ofs = 0
    var is_if = false
    while (ofs < cmd.len) {
      if (ofs > 0) if (is_if) {
        write(' ')
        print("THEN")
        write(' ')
        is_if = false
      } else {
        print(" : ")
      }
      ofs += 1
      switch (cmd[ofs-1]) {
        REM: {
          print("REM")
          write(' ')
          ofs += 3
          print(this.constants[((cmd[ofs-2] << 8) & 0xff) | (cmd[ofs-1] & 0xff)])
        }
        LIST_ALL: {
          print("LIST")
        }
        LIST_LINE: {
          print("LIST")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
        LIST_FROMTO: {
          print("LIST")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
          print(", ")
          ofs = this.listexpr(cmd, ofs)
        }
        PRINT: {
          print("PRINT")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
        INPUTI, INPUTF, INPUTS: {
          print("INPUT")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
          print(", ")
          print(this.varvalues[cmd[ofs] & 0xff])
          ofs += 1
        }
        SETIVAR, SETFVAR, SETSVAR: {
          print(this.varnames[cmd[ofs]])
          print("=")
          ofs = this.listexpr(cmd, ofs+1)
        }
        GOTO: {
          print("GOTO")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
        GOSUB: {
          print("GOSUB")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
        RETURN: {
          print("RETURN")
        }
        IF: {
          print("IF")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
          is_if = true
        }
        RUN: {
          print("RUN")
        }
        END: {
          print("END")
        }
        EXIT: {
          print("EXIT")
        }
        STOP: {
          print("STOP")
        }
        POP: {
          print("POP")
        }
        NEW: {
          print("NEW")
        }
        FOR: {
          print("FOR")
          write(' ')
          print(this.varnames[cmd[ofs] & 0xff])
          ofs += 1
          write('=')
          ofs = this.listexpr(cmd, ofs)
          write(' ')
          print("TO")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
          write(' ')
          print("STEP")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
        NEXT: {
          print("NEXT")
          write(' ')
          print(this.varnames[cmd[ofs] & 0xff])
          ofs += 1
        }
        COM0: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
        }
        COM1: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          if ("IFS".indexof(bf.args[0]) >= 0) {
            print(this.varnames[cmd[ofs] & 0xff])
            ofs += 1
          } else {
            ofs = this.listexpr(cmd, ofs)
          }
        }
        COM2: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<2, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        COM3: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<3, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        COM4: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<4, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        COM5: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<5, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        COM6: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<6, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        COM7: {
          var bf = cast (BasicFunc) this.commands[cmd[ofs] & 0xff]
          print(bf.name)
          write(' ')
          ofs += 1
          for (var j=0, j<7, j+=1) {
            if (j != 0) print(", ")
            if ("IFS".indexof(bf.args[j]) >= 0) {
              print(this.varnames[cmd[ofs] & 0xff])
              ofs += 1
            } else {
              ofs = this.listexpr(cmd, ofs)
            }
          }
        }
        REQUIRE: {
          print("REQUIRE")
          write(' ')
          ofs = this.listexpr(cmd, ofs)
        }
      }
    }
    write('\n')
  }
}
