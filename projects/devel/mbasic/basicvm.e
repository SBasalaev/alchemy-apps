use "bytecode.eh"
use "basicvm_impl.eh"

use "list.eh"
use "io.eh"
use "error.eh"
use "math.eh"
use "string.eh"
use "dl.eh"

def new_basicvm(usestd: Bool): BasicVM {
  var vm = new BasicVM {
    tokenizer = new_tokenizer(),
    usestd = usestd
  }
  vm.reset()
  vm
}

/* Resets VM to the initial state. */
def BasicVM.reset() {
  this.size = 0
  this.current = 0
  this.state = VM_IDLE
  this.modules = new_list()
  this.constants = new_list()
  this.labels = new [Int](16)
  this.forframes = new_dict()
  this.program = new [BArray](16)
  this.stack = new [Any](256)
  this.stackpos = 0
  this.varnames = new [String](256)
  this.varvalues = new [Array](256)
  this.varcount = 0
  this.commands = new_list()
  this.functions = new_list()
  if (this.usestd) this.addstdfunctions()
}

/* Executes bytecoded expression that starts at the specified offset.
 * Returns position after last expression code.
 */
def BasicVM.execexpr(command: BArray, ofs: Int, stackpos: Int): Int {
  var stack = this.stack
  ofs += 1
  switch (command[ofs-1]) {
    PARENS: {
      ofs = this.execexpr(command, ofs, stackpos)
    }
    LDBYTE: {
      stack[stackpos] = command[ofs]
      ofs += 1
    }
    LDSHORT: {
      stack[stackpos] = (command[ofs] << 8) | (command[ofs+1] & 0xff)
      ofs += 2
    }
    LDFLOAT, LDINT, LDSTRING: {
      stack[stackpos] = this.constants[((command[ofs] & 0xff) << 8) | (command[ofs+1] & 0xff)]
      ofs += 2
    }
    IADD: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) + (cast (Int) stack[stackpos+1])
    }
    FADD: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Double) stack[stackpos]) + (cast (Double) stack[stackpos+1])
    }
    ISUB: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) - (cast (Int) stack[stackpos+1])
    }
    FSUB: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Double) stack[stackpos]) - (cast (Double) stack[stackpos+1])
    }
    IMUL: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) * (cast (Int) stack[stackpos+1])
    }
    FMUL: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Double) stack[stackpos]) * (cast (Double) stack[stackpos+1])
    }
    IDIV: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) / (cast (Int) stack[stackpos+1])
    }
    FDIV: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Double) stack[stackpos]) / (cast (Double) stack[stackpos+1])
    }
    INEG: {
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = -(cast (Int) stack[stackpos])
    }
    FNEG: {
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = -(cast (Double) stack[stackpos])
    }
    BITAND: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) & (cast (Int) stack[stackpos+1])      
    }
    BITOR: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) | (cast (Int) stack[stackpos+1])      
    }
    BITXOR: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = (cast (Int) stack[stackpos]) ^ (cast (Int) stack[stackpos+1])      
    }
    INOT: {
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = if (stack[stackpos] == 0) 1 else 0      
    }
    IAND: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] =
        if (stack[stackpos] == 0) 0
        else if (stack[stackpos+1] == 0) 0
        else 1
    }
    IOR: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] =
        if (stack[stackpos] != 0) 1
        else if (stack[stackpos+1] != 0) 1
        else 0
    }
    I2F: {
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = cast (Double) cast (Int) stack[stackpos]
    }
    F2I: {
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = cast (Int) cast (Double) stack[stackpos]
    }
    IEQ, FEQ, SEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (stack[stackpos] == stack[stackpos+1]) 1 else 0
    }
    INOTEQ, FNOTEQ, SNOTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (stack[stackpos] != stack[stackpos+1]) 1 else 0
    }
    ILT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Int) stack[stackpos]) < (cast (Int) stack[stackpos+1])) 1 else 0
    }
    FLT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Double) stack[stackpos]) < (cast (Double) stack[stackpos+1])) 1 else 0
    }
    ILTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Int) stack[stackpos]) <= (cast (Int) stack[stackpos+1])) 1 else 0
    }
    FLTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Double) stack[stackpos]) <= (cast (Double) stack[stackpos+1])) 1 else 0
    }
    IGT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Int) stack[stackpos]) > (cast (Int) stack[stackpos+1])) 1 else 0
    }
    FGT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Double) stack[stackpos]) > (cast (Double) stack[stackpos+1])) 1 else 0
    }
    IGTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Int) stack[stackpos]) >= (cast (Int) stack[stackpos+1])) 1 else 0
    }
    FGTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if ((cast (Double) stack[stackpos]) >= (cast (Double) stack[stackpos+1])) 1 else 0
    }
    SLT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (`String.cmp`(cast(String)stack[stackpos], cast(String)stack[stackpos+1]) < 0) 1 else 0
    }
    SLTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (`String.cmp`(cast(String)stack[stackpos], cast(String)stack[stackpos+1]) <= 0) 1 else 0
    }
    SGT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (`String.cmp`(cast(String)stack[stackpos], cast(String)stack[stackpos+1]) > 0) 1 else 0
    }
    SGTEQ: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = if (`String.cmp`(cast(String)stack[stackpos], cast(String)stack[stackpos+1]) >= 0) 1 else 0
    }
    GETIVAR: {
      stack[stackpos] = (cast ([Int]) this.varvalues[command[ofs] & 0xff])[0]
      stackpos += 1
      ofs += 1
    }
    GETFVAR: {
      stack[stackpos] = (cast ([Double]) this.varvalues[command[ofs] & 0xff])[0]
      ofs += 1
    }
    GETSVAR: {
      stack[stackpos] = (cast ([String]) this.varvalues[command[ofs] & 0xff])[0]
      ofs += 1
    }
    IFUNC0, FFUNC0, SFUNC0: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( () : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      stack[stackpos] = func()
    }
    IFUNC1, FFUNC1, SFUNC1: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      stack[stackpos] = func(stack[stackpos])
    }
    IFUNC2, FFUNC2, SFUNC2: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1])
    }
    IFUNC3, FFUNC3, SFUNC3: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      ofs = this.execexpr(command, ofs, stackpos+2)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1], stack[stackpos+2])
    }
    IFUNC4, FFUNC4, SFUNC4: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any,Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      ofs = this.execexpr(command, ofs, stackpos+2)
      ofs = this.execexpr(command, ofs, stackpos+3)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1], stack[stackpos+2],
              stack[stackpos+3])
    }
    IFUNC5, FFUNC5, SFUNC5: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any,Any,Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      ofs = this.execexpr(command, ofs, stackpos+2)
      ofs = this.execexpr(command, ofs, stackpos+3)
      ofs = this.execexpr(command, ofs, stackpos+4)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1], stack[stackpos+2],
              stack[stackpos+3], stack[stackpos+4])
    }
    IFUNC6, FFUNC6, SFUNC6: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any,Any,Any,Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      ofs = this.execexpr(command, ofs, stackpos+2)
      ofs = this.execexpr(command, ofs, stackpos+3)
      ofs = this.execexpr(command, ofs, stackpos+4)
      ofs = this.execexpr(command, ofs, stackpos+5)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1], stack[stackpos+2],
              stack[stackpos+3], stack[stackpos+4], stack[stackpos+5])
    }
    IFUNC7, FFUNC7, SFUNC7: {
      var idx = command[ofs] & 0xff
      ofs += 1
      var func = cast ( (Any,Any,Any,Any,Any,Any,Any) : Any )
                 (cast (BasicFunc) this.functions[idx]).impl
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      ofs = this.execexpr(command, ofs, stackpos+2)
      ofs = this.execexpr(command, ofs, stackpos+3)
      ofs = this.execexpr(command, ofs, stackpos+4)
      ofs = this.execexpr(command, ofs, stackpos+5)
      ofs = this.execexpr(command, ofs, stackpos+6)
      stack[stackpos] = func(stack[stackpos], stack[stackpos+1], stack[stackpos+2],
              stack[stackpos+3], stack[stackpos+4], stack[stackpos+5], stack[stackpos+6])
    }
    STRCAT: {
      ofs = this.execexpr(command, ofs, stackpos)
      ofs = this.execexpr(command, ofs, stackpos+1)
      stack[stackpos] = stack[stackpos].tostr().concat(stack[stackpos+1].tostr())
    }
    else: error(ERR_ILL_ARG, "Not implemented")
  }
  ofs
}

type ForFrame {
  cmdindex: Int,
  forcmd: BArray,
  dataofs: Int
}

/* Executes bytecoded command. */
def BasicVM.exec(command: BArray) {
  var ofs = 0
  var stack = this.stack
  var stackpos = this.stackpos
  while (ofs < command.len) {
    ofs += 1
    switch (command[ofs-1]) {
      REM: { // just skip the comment
        ofs += 3
      }
      LIST_ALL: {
        this.list(0, 65535)
      }
      LIST_LINE: {
        ofs = this.execexpr(command, ofs, stackpos)
        var lnum = cast (Int) stack[stackpos]
        this.list(lnum, lnum)
      }
      LIST_FROMTO: {
        ofs = this.execexpr(command, ofs, stackpos)
        ofs = this.execexpr(command, ofs, stackpos+1)
        this.list(cast (Int) stack[stackpos], cast (Int) stack[stackpos+1])
      }
      PRINT: {
        ofs = this.execexpr(command, ofs, stackpos)
        println(stack[stackpos])
      }
      INPUTI: {
        ofs = this.execexpr(command, ofs, stackpos)
        println(stack[stackpos])
        var ivar = cast ([Int]) this.varvalues[command[ofs] & 0xff]
        ofs += 1
        var input = readline()
        try {
          ivar[0] = input.todouble()
        } catch {
          println("Bad number: " + input)
          this.state = VM_IDLE
        }
      }
      INPUTF: {
        ofs = this.execexpr(command, ofs, stackpos)
        println(stack[stackpos])
        var fvar = cast ([Double]) this.varvalues[command[ofs] & 0xff]
        ofs += 1
        var input = readline()
        try {
          fvar[0] = input.todouble()
        } catch {
          println("Bad number: " + input)
          this.state = VM_IDLE
        }
      }
      INPUTS: {
        ofs = this.execexpr(command, ofs, stackpos)
        println(stack[stackpos])
        var svar = cast ([String]) this.varvalues[command[ofs] & 0xff]
        ofs += 1
        var input = readline()
        svar[0] = input
      }
      SETIVAR: {
        var idx = command[ofs] & 0xff
        ofs = this.execexpr(command, ofs+1, stackpos);;
        (cast ([Int]) this.varvalues[idx])[0] = cast (Int) stack[stackpos];
      }
      SETFVAR: {
        var idx = command[ofs] & 0xff
        ofs = this.execexpr(command, ofs+1, stackpos);;
        (cast ([Double]) this.varvalues[idx])[0] = cast (Double) stack[stackpos];
      }
      SETSVAR: {
        var idx = command[ofs] & 0xff
        ofs = this.execexpr(command, ofs+1, stackpos);;
        (cast ([String]) this.varvalues[idx])[0] = cast (String) stack[stackpos];
      }
      GOTO: {
        ofs = this.execexpr(command, ofs, stackpos)
        this.run(cast (Int) stack[stackpos])
      }
      GOSUB: {
        stack[stackpos] = this.current
        stackpos += 1
        this.stackpos = stackpos
        ofs = this.execexpr(command, ofs, stackpos)
        this.run(cast (Int) stack[stackpos])
      }
      RETURN: {
        stackpos -= 1
        this.stackpos = stackpos
        this.current = cast (Int) stack[stackpos]
      }
      IF: {
        ofs = this.execexpr(command, ofs, stackpos)
        if (stack[stackpos] == 0) ofs = command.len
      }
      RUN: {
        this.run(0)
        ofs = command.len
      }
      END: {
        this.state = VM_IDLE
      }
      EXIT: {
        this.state = VM_EXIT
      }
      STOP: {
        println("Stopped at line " + this.labels[this.current])
        this.state = VM_IDLE
      }
      POP: {
        stackpos -= 1
        this.stackpos = stackpos
      }
      FOR: {
        var idx = command[ofs] & 0xff
        ofs = this.execexpr(command, ofs+1, stackpos)
        this.forframes[idx] = new ForFrame(this.current, command, ofs);;
        (cast ([Int]) this.varvalues[idx])[0] = cast (Int) stack[stackpos]
        ofs = this.execexpr(command, ofs, stackpos)
        ofs = this.execexpr(command, ofs, stackpos)
      }
      NEXT: {
        var varidx = command[ofs] & 0xff
        ofs += 1
        var forframe = cast (ForFrame) this.forframes[varidx]
        if (forframe == null)
          error(ERR_ILL_STATE, "NEXT before FOR")
        var forofs = this.execexpr(forframe.forcmd, forframe.dataofs, stackpos)
        this.execexpr(forframe.forcmd, forofs, stackpos+1)
        var to = cast (Int) stack[stackpos]
        var step = cast (Int) stack[stackpos+1]
        var ivar = cast ([Int]) this.varvalues[varidx]
        ivar[0] += step
        if (step >= 0 && ivar[0] <= to) {
          this.current = forframe.cmdindex
        } else if (step <= 0 && ivar[0] >= to) {
          this.current = forframe.cmdindex
        } else {
          this.forframes.remove(varidx)
        }
      }
      COM0: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var func = cast ( () )
                 (cast (BasicFunc) this.commands[idx]).impl
        func()
      }
      COM1: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any) ) bf.impl
        if ("IFS".indexof(bf.args[0]) >= 0) {
          stack[stackpos] = this.varvalues[command[ofs] & 0xff]
          ofs += 1
        } else {
          ofs = this.execexpr(command, ofs, stackpos)
        }
        func(stack[stackpos])
      }
      COM2: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any) ) bf.impl
        for (var i=0, i<2, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1])
      }
      COM3: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any,Any) ) bf.impl
        for (var i=0, i<3, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1], stack[stackpos+2])
      }
      COM4: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any,Any,Any) ) bf.impl
        for (var i=0, i<4, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1], stack[stackpos+2], stack[stackpos+3])
      }
      COM5: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any,Any,Any,Any) ) bf.impl
        for (var i=0, i<5, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1], stack[stackpos+2], stack[stackpos+3],
                stack[stackpos+4])
      }
      COM6: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any,Any,Any,Any,Any) ) bf.impl
        for (var i=0, i<6, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1], stack[stackpos+2], stack[stackpos+3],
                stack[stackpos+4], stack[stackpos+5])
      }
      COM7: {
        var idx = command[ofs] & 0xff
        ofs += 1
        var bf = cast (BasicFunc) this.commands[idx]
        var func = cast ( (Any,Any,Any,Any,Any,Any,Any) ) bf.impl
        for (var i=0, i<7, i+=1) {
          if ("IFS".indexof(bf.args[i]) >= 0) {
            stack[stackpos+i] = this.varvalues[command[ofs] & 0xff]
            ofs += 1
          } else {
            ofs = this.execexpr(command, ofs, stackpos+i)
          }
        }
        func(stack[stackpos], stack[stackpos+1], stack[stackpos+2], stack[stackpos+3],
                stack[stackpos+4], stack[stackpos+5], stack[stackpos+6])
      }
      NEW: {
        this.reset()
      }
      REQUIRE: {
        ofs = this.execexpr(command, ofs, stackpos)
        var modulename = cast (String) stack[stackpos]
        if (this.modules.indexof(modulename) < 0) {
          if (modulename.indexof('/') >= 0) {
            println("Illegal module name")
          } else try {
            var module = loadlibrary("/lib/mbasic/" + modulename + ".so")
            var initfunc = cast ((BasicVM)) module.getfunc("Init_" + modulename)
            initfunc(this)
            this.modules.add(modulename)
          } catch (var e) {
            println("Failed to load module " + modulename)
            println("Reason: " + e)
          }
        }
      }
      else: error(ERR_ILL_ARG, "Not implemented")
    }
  }
}

/* Runs program stored in VM. */
def BasicVM.run(label: Int): Int {
  this.current = this.indexof(label)
  switch (this.state) {
    VM_IDLE: {
      this.state = VM_RUN
      while (this.state == VM_RUN && this.current < this.size) {
        this.exec(this.program[this.current])
        this.current += 1
      }
      if (this.state == VM_RUN)
        this.state = VM_IDLE
    }
    VM_RUN: {
      this.current -= 1
    }
    VM_EXIT: {
      error(ERR_ILL_STATE, "Cannot RUN after EXIT")
    }
  }
  this.state
}

/* Returns index of the first command with label >= argument. */
def BasicVM.indexof(label: Int): Int {
  var i = 0
  while (i < this.size && this.labels[i] < label) {
    i += 1
  }
  i
}

def BasicVM.functionindex(name: String): Int {
  var functions = this.functions
  var idx = functions.len()-1
  while (idx >= 0 && (cast (BasicFunc) functions[idx]).name != name)
    idx -= 1
  idx
}

def BasicVM.commandindex(name: String): Int {
  var commands = this.commands
  var idx = commands.len()-1
  while (idx >= 0 && (cast (BasicFunc) commands[idx]).name != name)
    idx -= 1
  idx
}

/* Registers new function. */
def BasicVM.addfunction(name: String, args: String, rettype: Int, impl: Function): Bool {
  var ok = true
  if (this.functionindex(name) >= 0) {
    println("Function already exists: " + name)
    ok = false
  } else if (this.get_varindex(name, false) >= 0) {
    println("Variable already exists: " + name)
    ok = false
  } else if ("ifs".indexof(rettype) < 0) {
    println("Cannot import function " + name + ", wrong return type")
    ok = false
  } else if (args.len() > 6) {
    println("Cannot import function " + name + ", wrong signature")
    ok = false
  } else {
    for (var i=args.len()-1, ok && i>=0, i-=1) {
      ok = "iafs".indexof(args[i]) >= 0
    }
    if (ok) {
      this.functions.add(new BasicFunc(name, args, rettype, impl))
    } else {
      println("Cannot import function " + name + ", wrong signature")
    }
  }
  ok
}

/* Registers new command. */
def BasicVM.addcommand(name: String, args: String, impl: Function): Bool {
  var ok = true
  if (this.commandindex(name) >= 0) {
    println("Command already exists: " + name)
    ok = false
  } else if (this.get_varindex(name, false) >= 0) {
    println("Variable already exists: " + name)
    ok = false
  } else if (args.len() > 6) {
    println("Cannot import command " + name + ", wrong signature")
    ok = false
  } else {
    for (var i=args.len()-1, ok && i>=0, i-=1) {
      ok = "IFSiafs".indexof(args[i]) >= 0
    }
    if (ok) {
      this.commands.add(new BasicFunc(name, args, 0, impl))
    } else {
      println("Cannot import command " + name + ", wrong signature")
    }
  }
  ok
}

def BasicVM.get_state(): Int {
  this.state
}

def BasicVM.set_ivar(name: String, value: Int) {
  if (name.len() < 2 || name[name.len()-1] != '%')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, true)
  var ivar = cast ([Int]) this.varvalues[idx]
  ivar[0] = value
}

def BasicVM.set_fvar(name: String, value: Double) {
  if (name.len() < 2 || name[name.len()-1] == '%' || name[name.len()-1] == '$')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, true)
  var fvar = cast ([Double]) this.varvalues[idx]
  fvar[0] = value
}

def BasicVM.set_svar(name: String, value: String) {
  if (name.len() < 2 || name[name.len()-1] != '$')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, true)
  var svar = cast ([String]) this.varvalues[idx]
  svar[0] = value
}

def BasicVM.get_ivar(name: String): Int {
  if (name.len() < 2 || name[name.len()-1] != '%')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, false)
  if (idx < 0) {
    0
  } else {
    var ivar = cast ([Int]) this.varvalues[idx]
    ivar[0]
  }
}

def BasicVM.get_fvar(name: String): Double {
  if (name.len() < 2 || name[name.len()-1] == '%' || name[name.len()-1] == '$')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, false)
  if (idx < 0) {
    0.0
  } else {
    var fvar = cast ([Double]) this.varvalues[idx]
    fvar[0]
  }
}

def BasicVM.get_svar(name: String): String {
  if (name.len() < 2 || name[name.len()-1] != '$')
    error(ERR_ILL_ARG, "Wrong variable name: " + name)
  var idx = this.get_varindex(name, false)
  if (idx < 0) {
    ""
  } else {
    var svar = cast ([String]) this.varvalues[idx]
    svar[0]
  }
}
