use "basicvm_impl.eh"
use "bytecode.eh"
use "exprtree.eh"

use "io.eh"
use "string.eh"
use "sys.eh"
use "dict.eh"

def BasicVM.addconst(val: Any): Int {
  var index = this.constants.indexof(val)
  if (index < 0) {
    index = this.constants.len()
    this.constants.add(val)
  }
  index
}

def BasicVM.write_ldint(out: BArrayOStream, value: Int) {
  if (value >= -128 && value <= 127) {
    out.write(LDBYTE)
    out.write(value)
  } else if (value >= -32768 && value <= 32767) {
    out.write(LDSHORT)
    out.write(value >> 8)
    out.write(value)
  } else {
    var idx = this.addconst(value)
    out.write(LDINT)
    out.write(idx >> 8)
    out.write(idx)
  }
}

def BasicVM.get_varindex(name: String, create: Bool): Int {
  var idx = this.varcount - 1
  while (idx >= 0 && this.varnames[idx] != name)
    idx -= 1
  if (create && idx < 0) {
    idx = this.varcount
    this.varcount += 1
    this.varnames[idx] = name
    if (name[name.len()-1] == '$') {
      this.varvalues[idx] = [""]
    } else if (name[name.len()-1] == '%') {
      this.varvalues[idx] = [0]
    } else {
      this.varvalues[idx] = [0.0]
    }
  }
  idx
}

/* Operator categories/priorities. */
const OP_OR = 1
const OP_AND = 2
const OP_CMP = 3
const OP_BIT = 4
const OP_ADD = 5
const OP_MUL = 6
const OP_PWR = 7
var operators: Dict;

def BasicVM.parseexpr(stackpos: Int): Expr;

def BasicVM.parseintexpr(stackpos: Int): Expr {
  var expr = this.parseexpr(stackpos)
  if (expr == null) null
  else switch (expr.rettype()) {
    ET_INT:
      expr;
    ET_FLOAT:
      new UnaryExpr(F2I, expr);
    else: {
      println("Numeric expression expected")
      null
    }
  }
}

def BasicVM.parsefloatexpr(stackpos: Int): Expr {
  var expr = this.parseexpr(stackpos)
  if (expr == null) null
  else switch (expr.rettype()) {
    ET_INT:
      new UnaryExpr(I2F, expr);
    ET_FLOAT:
      expr;
    else: {
      println("Numeric expression expected")
      null
    }
  }
}

def BasicVM.parsestringexpr(stackpos: Int): Expr {
  var expr = this.parseexpr(stackpos)
  if (expr == null) {
    null
  } else if (expr.rettype() == ET_STRING) {
    expr
  } else {
    println("String expression expected")
    null
  }
}

/* Parses expression without operators. */
def BasicVM.parseexpratom(stackpos: Int): Expr {
  var t = this.tokenizer
  switch (t.next()) {
    TT_INT: {
      var i = t.value.toint()
      if (i >= -128 && i <= 127) {
        new LiteralExpr(LDBYTE, i)
      } else if (i >= -32768 && i <= 32767) {
        new LiteralExpr(LDSHORT, i)
      } else {
        var idx = this.addconst(i)
        new LiteralExpr(LDINT, idx)
      }
    }
    TT_FLOAT: {
      var f = t.value.todouble()
      var idx = this.addconst(f)
      new LiteralExpr(LDFLOAT, idx)
    }
    TT_STRING: {
      var idx = this.addconst(t.value)
      new LiteralExpr(LDSTRING, idx)
    }
    TT_OPERATOR: {
      var op = t.value
      if (op == "-") {
        var sub = this.parseexpratom(stackpos)
        if (sub == null) {
          null
        } else {
          switch (sub.rettype()) {
            ET_STRING: {
              println("Operator " + op + " cannot be applied to string")
              null
            }
            ET_FLOAT:
              new UnaryExpr(FNEG, sub)
            else:
              new UnaryExpr(INEG, sub)
          }
        }
      } else if (op == "(") {
        var sub = this.parseexpr(stackpos)
        t.next()
        if (t.value == ")") {
          if (sub != null)
            new UnaryExpr(PARENS, sub)
          else
            null
        } else {
          println("No closing )")
          null
        }
      } else {
        println("Failed to parse expression around " + t.value)
        null
      }
    }
    TT_WORD: {
      var name = t.value
      if (name == "NOT") {
        var sub = this.parseexpratom(stackpos)
        var rettype = sub.rettype()
        if (sub == null) {
          null
        } else if (rettype == ET_STRING) {
          println("Operator " + name + " cannot be applied to a string")
          null
        } else {
          if (rettype == ET_FLOAT) sub = new UnaryExpr(F2I, sub)
          new UnaryExpr(INOT, sub)
        }
      } else {
        var idx = this.functionindex(name)
        if (idx >= 0) {
          // function call
          var bf = cast (BasicFunc) this.functions[idx]
          var fe = new FuncExpr { idx=idx }
          if (t.next() != TT_OPERATOR || t.value != "(") {
            println("( expected after " + name)
            fe = null
          }
          var arglen = bf.args.len()
          fe.args = new [Expr](arglen)
          for (var i=0, fe != null && i < arglen, i+=1) {
            if (i != 0 && (t.next() != TT_OPERATOR || t.value != ",")) {
              println(", expected before " + t.value)
              fe = null
            } else {
              var ex = switch (bf.args[i]) {
                'i': this.parseintexpr(stackpos)
                'f': this.parsefloatexpr(stackpos)
                's': this.parsestringexpr(stackpos)
                'a': this.parseexpr(stackpos)
                else: null
              }
              if (ex == null) fe = null
              else fe.args[i] = ex
            }
          }
          if (t.next() != TT_OPERATOR || t.value != ")") {
            println(") expected")
            fe = null
          }
          switch (bf.rettype) {
            'i': fe.code = IFUNC0 + arglen
            'f': fe.code = FFUNC0 + arglen
            's': fe.code = SFUNC0 + arglen
          }
          fe
        } else {
          // variable
          idx = this.get_varindex(name, true)
          switch (name[name.len()-1]) {
            '%': new VarExpr(GETIVAR, idx)
            '$': new VarExpr(GETSVAR, idx)
            else: new VarExpr(GETFVAR, idx)
          }
        }
      }
    }
    else: {
      println("Failed to parse expression around " + t.value)
      null
    }
  }
}

/* Reads tokens and builds expression. */
def BasicVM.parseexpr(stackpos: Int): Expr {
  var stack = this.stack
  var t = this.tokenizer
  var expr = this.parseexpratom(stackpos)
  if (expr == null) {
    null
  } else {
    // reading expressions and operators into stack
    stack[stackpos] = expr
    var count = 1
    var ok = true
    while (ok && expr != null) {
      t.next()
      var op = t.value
      if (operators[op] != null) {
        expr = this.parseexpratom(stackpos + 2*count)
        if (expr == null) {
          // println("Failed to parse expression around " + t.value)
          ok = false
        } else {
          stack[stackpos + 2*count-1] = op
          stack[stackpos + 2*count] = expr
          count += 1
        }
      } else {
        t.pushback()
        expr = null
      }
    }
    // building expression
    while (ok && count > 1) {
      // searching operator with highest priority
      var idx = 0
      var priority = 0
      for (var i=1, i<count, i+=1) {
        var pr = cast (Int) operators[stack[stackpos + 2*i-1]]
        if (pr > priority) {
          idx = i
          priority = pr
        }
      }
      // checking operand types
      var op = stack[stackpos + 2*idx - 1]
      var left = cast (Expr) stack[stackpos + 2*idx-2]
      var ltype = left.rettype()
      var right = cast (Expr) stack[stackpos + 2*idx]
      var rtype = right.rettype()
      if (priority != OP_CMP && op != "+" && (ltype == ET_STRING || rtype == ET_STRING)) {
        println("Operator "+op+" cannot be applied to a string")
        ok = false
      }
      // making number conversions
      if (ltype != rtype) {
        if (priority == OP_OR || priority == OP_AND || priority == OP_BIT) {
          if (ltype == ET_FLOAT) {
            left = new UnaryExpr(F2I, left)
            ltype = ET_INT
          }
          if (rtype == ET_FLOAT) {
            right = new UnaryExpr(F2I, right)
            rtype = ET_INT
          }
        } else {
          if (ltype == ET_INT) {
            left = new UnaryExpr(I2F, left)
            ltype = ET_FLOAT
          }
          if (rtype == ET_INT) {
            right = new UnaryExpr(I2F, right)
            rtype = ET_FLOAT
          }
        }
      }
      if (ltype != rtype) {
        println("Operands of " + op + " have different types")
        ok = false
      }
      // making binary
      var opcode =
        if (op == "AND") IAND
        else if (op == "OR") IOR
        else if (op == "BITAND") BITAND
        else if (op == "BITOR") BITOR
        else if (op == "BITXOR") BITXOR
        else if (op == "=") {
          if (ltype == ET_STRING) SEQ else
          if (ltype == ET_FLOAT) FEQ else IEQ
        } else if (op == "<>") {
          if (ltype == ET_STRING) SNOTEQ else
          if (ltype == ET_FLOAT) FNOTEQ else INOTEQ
        } else if (op == "<") {
          if (ltype == ET_STRING) SLT else
          if (ltype == ET_FLOAT) FLT else ILT
        } else if (op == "<=") {
          if (ltype == ET_STRING) SLTEQ else
          if (ltype == ET_FLOAT) FLTEQ else ILTEQ
        } else if (op == ">") {
          if (ltype == ET_STRING) SGT else
          if (ltype == ET_FLOAT) FGT else IGT
        } else if (op == ">=") {
          if (ltype == ET_STRING) SGTEQ
          else if (ltype == ET_FLOAT) FGTEQ
          else IGTEQ
        } else if (op == "+") {
          if (ltype == ET_FLOAT) FADD
          else if (ltype == ET_STRING) STRCAT
          else IADD
        } else if (op == "-") {
          if (ltype == ET_FLOAT) FSUB else ISUB
        } else if (op == "*") {
          if (ltype == ET_FLOAT) FMUL else IMUL
        } else if (op == "/") {
          if (ltype == ET_FLOAT) FDIV else IDIV
        } else if (op == "^") {
          if (ltype == ET_FLOAT) FPWR else IPWR
        } else -1
      stack[stackpos + idx*2-2] = new BinaryExpr(opcode, left, right)
      // shifting tail
      count -= 1
      if (idx < count) {
        acopy(stack, stackpos + idx*2+1, stack, stackpos + idx*2-1, 2*(count-idx))
      }
    }
    if (ok) stack[stackpos] else null
  }
}

/* Parses input line. */
def BasicVM.parseline(line: String): Bool {
  // init operators on first use
  if (operators == null) {
    var ops = new_dict()
    ops["OR"] = OP_OR
    ops["AND"] = OP_AND
    ops["="] = OP_CMP
    ops["<>"] = OP_CMP
    ops["<"] = OP_CMP
    ops["<="] = OP_CMP
    ops[">"] = OP_CMP
    ops[">="] = OP_CMP
    ops["BITAND"] = OP_BIT
    ops["BITOR"] = OP_BIT
    ops["BITXOR"] = OP_BIT
    ops["+"] = OP_ADD
    ops["-"] = OP_ADD
    ops["*"] = OP_MUL
    ops["/"] = OP_MUL
    ops["^"] = OP_PWR
    operators = ops
  }
  
  var ok = true
  
  // setting tokenizer
  var t = this.tokenizer
  t.source = line

  // parsing line number
  var linenum = -1
  if (t.next() == TT_INT) {
    linenum = t.value.toint()
    if (linenum < 1 || linenum > 65535) {
      ok = false
      println("Wrong line number " + linenum)
    }
  } else {
    t.pushback()
  }

  // parsing commands and writing bytecode
  var bcode = new_baostream()
  var more = true
  var is_if = false
  var idx = -1
  while (ok && more) {
    more = false
    if (t.next() == TT_EOF) {
      // empty line, do nothing
    } else if (t.get_type() != TT_WORD) {
      println("Syntax error. Expected command, got " + t.value)
      ok = false
    } else {
      var cmdname = t.value
      if (cmdname == "REM") {
        // REM raw_data
        bcode.write(REM)
        t.set_raw()
        t.next()
        var comment = t.value
        if (comment == null) comment = ""
        var comidx = this.addconst(comment)
        bcode.write(LDSTRING)
        bcode.write(comidx >> 8)
        bcode.write(comidx)
      } else if (cmdname == "LIST") {
        // LIST from%, to%
        // LIST line%
        // LIST
        if (t.next() == TT_EOF || t.value == ":") {
          t.pushback()
          bcode.write(LIST_ALL)
        } else {
          t.pushback()
          var fromexpr = this.parseintexpr(this.stackpos)
          if (fromexpr == null) {
            ok = false
          } else if (t.next() == TT_EOF || t.value == ":") {
            t.pushback()
            bcode.write(LIST_LINE)
            fromexpr.writeto(bcode)
          } else if (t.value == ",") {
            var toexpr = this.parseintexpr(this.stackpos)
            if (toexpr == null) {
              ok = false
            } else {
              bcode.write(LIST_FROMTO)
              fromexpr.writeto(bcode)
              toexpr.writeto(bcode)
            }
          } else {
            println("':' or ',' expected in LIST")
            ok = false
          }
        }
      } else if (cmdname == "PRINT") {
        // PRINT expr
        bcode.write(PRINT)
        var expr = this.parseexpr(this.stackpos)
        if (expr == null) ok = false
        else expr.writeto(bcode)
      } else if (cmdname == "INPUT") {
        // INPUT msg, var
        var expr = this.parsestringexpr(this.stackpos)
        if (expr == null) ok = false
        if (ok && (t.next() != TT_OPERATOR || t.value != ",")) {
          println("Comma expected, got " + t.value)
          ok = false
        }
        if (ok && t.next() != TT_WORD) {
          println("Variable name expected, got " + t.value)
          ok = false
        }
        if (ok) {
          var varname = t.value
          var varidx = this.get_varindex(varname, true)
          switch (varname[varname.len()-1]) {
            '%': bcode.write(INPUTI)
            '$': bcode.write(INPUTS)
            else: bcode.write(INPUTF)
          }
          expr.writeto(bcode)
          bcode.write(varidx)
        }
      } else if (cmdname == "GOTO") {
        bcode.write(GOTO)
        var expr = this.parseintexpr(this.stackpos)
        if (expr == null) ok = false
        else expr.writeto(bcode)
      } else if (cmdname == "GOSUB") {
        bcode.write(GOSUB)
        var expr = this.parseintexpr(this.stackpos)
        if (expr == null) ok = false
        else expr.writeto(bcode)
      } else if (cmdname == "IF") {
        bcode.write(IF)
        var expr = this.parseintexpr(this.stackpos)
        if (expr == null) ok = false
        else expr.writeto(bcode)
        is_if = true
      } else if (cmdname == "FOR") {
        bcode.write(FOR)
        if (t.next() != TT_WORD || t.value[t.value.len()-1] != '%') {
          println("Integer variable expected in THEN")
          ok = false
        } else {
          bcode.write(this.get_varindex(t.value, true))
        }
        if (ok) {
          if (t.next() != TT_OPERATOR || t.value != "=") {
            println("= expected in FOR")
            ok = false
          } else {
            var fromexpr = this.parseintexpr(this.stackpos)
            if (fromexpr == null) ok = false
            else fromexpr.writeto(bcode)
          }
        }
        if (ok) {
          if (t.next() != TT_WORD || t.value != "TO") {
            println("TO expected in FOR")
            ok = false
          } else {
            var toexpr = this.parseintexpr(this.stackpos)
            if (toexpr == null) ok = false
            else toexpr.writeto(bcode)
          }
        }
        if (ok) {
          if (t.next() == TT_WORD && t.value == "STEP") {
            var stepexpr = this.parseintexpr(this.stackpos)
            if (stepexpr == null) ok = false
            else stepexpr.writeto(bcode)
          } else {
            t.pushback()
            new LiteralExpr(LDBYTE, 1).writeto(bcode)
          }
        }
      } else if (cmdname == "NEXT") {
        bcode.write(NEXT)
        if (t.next() != TT_WORD || t.value[t.value.len()-1] != '%') {
          println("Integer variable expected in THEN")
          ok = false
        } else {
          bcode.write(this.get_varindex(t.value, true))
        }
      } else if (cmdname == "RETURN") {
        bcode.write(RETURN)
      } else if (cmdname == "RUN") {
        bcode.write(RUN)
      } else if (cmdname == "END") {
        bcode.write(END)
      } else if (cmdname == "EXIT") {
        bcode.write(EXIT)
      } else if (cmdname == "STOP") {
        bcode.write(STOP)
      } else if (cmdname == "POP") {
        bcode.write(POP)
      } else if (cmdname == "NEW") {
        bcode.write(NEW)
      } else if (cmdname == "REQUIRE") {
        bcode.write(REQUIRE)
        var expr = this.parsestringexpr(this.stackpos)
        if (expr == null) ok = false
        else expr.writeto(bcode)
      } else if ({idx = this.commandindex(cmdname); idx >= 0}) {
        var bf = cast (BasicFunc) this.commands[idx]
        bcode.write(COM0 + bf.args.len())
        bcode.write(idx)
        for (var i=0, ok && i < bf.args.len(), i+=1) {
          if (i!=0 && (t.next() != TT_OPERATOR || t.value != ",")) {
            println("Expected comma, got " + t.value)
            ok = false
          }
          if (ok) switch (bf.args[i]) {
            'i': {
              var expr = this.parseintexpr(this.stackpos)
              if (expr == null) ok = false
              else expr.writeto(bcode)
            }
            'f': {
              var expr = this.parsefloatexpr(this.stackpos)
              if (expr == null) ok = false
              else expr.writeto(bcode)
            }
            's': {
              var expr = this.parsestringexpr(this.stackpos)
              if (expr == null) ok = false
              else expr.writeto(bcode)
            }
            'I': {
              if (t.next() != TT_WORD) {
                println("Integer variable expected, got " + t.value)
                ok = false
              } else {
                var varname = t.value
                var lastsym = varname[varname.len()-1]
                if (lastsym != '%') {
                  println("Integer variable expected, got " + varname)
                  ok = false
                } else {
                  bcode.write(this.get_varindex(varname, true))
                }
              }
            }
            'F': {
              if (t.next() != TT_WORD) {
                println("Float variable expected, got " + t.value)
                ok = false
              } else {
                var varname = t.value
                var lastsym = varname[varname.len()-1]
                if (lastsym == '%' || lastsym == '$') {
                  println("Float variable expected, got " + varname)
                  ok = false
                } else {
                  bcode.write(this.get_varindex(varname, true))
                }
              }
            }
            'S': {
              if (t.next() != TT_WORD) {
                println("String variable expected, got " + t.value)
                ok = false
              } else {
                var varname = t.value
                var lastsym = varname[varname.len()-1]
                if (lastsym != '$') {
                  println("String variable expected, got " + varname)
                  ok = false
                } else {
                  bcode.write(this.get_varindex(varname, true))
                }
              }
            }
          }
        }
      } else if (t.next() == TT_OPERATOR && t.value == "=") {
        // var = expr
        var varidx = this.get_varindex(cmdname, true)
        var expr = switch (cmdname[cmdname.len()-1]) {
          '%': this.parseintexpr(this.stackpos);
          '$': this.parsestringexpr(this.stackpos);
          else: this.parsefloatexpr(this.stackpos);
        }
        if (expr == null) {
          ok = false
        } else {
          bcode.write(
            switch (cmdname[cmdname.len()-1]) {
              '%': SETIVAR;
              '$': SETSVAR;
              else: SETFVAR;
            }
          )
          bcode.write(varidx)
          expr.writeto(bcode)
        }
      } else {
        println("Unknown command: " + cmdname)
        ok = false
      }
    }
    // reading next command in line
    if (is_if) {
      if (t.next() != TT_WORD || t.value != "THEN") {
        println("THEN expected after IF")
        ok = false
      } else {
        more = true
        is_if = false
      }
    } else if (t.next() == TT_OPERATOR && t.value == ":") {
      more = true
    } else if (t.get_type() != TT_EOF) {
      println("Syntax error: " + t.value + " unexpected")
    }
  }
  
  // processing parsed input
  if (ok) {
    var command = bcode.tobarray()
    if (linenum > 0) {
      var index = this.indexof(linenum)
      if (command.len > 0) {
        if (index < this.size && this.labels[index] == linenum) {
          // setting new contents to the line
        } else {
          // adding line to program
          if (this.size == this.labels.len) {
            var newlabels = new [Int](this.size * 2)
            acopy(this.labels, 0, newlabels, 0, index)
            acopy(this.labels, index, newlabels, index+1, this.size-index)
            this.labels = newlabels
            var newprog = new [BArray](this.size * 2)
            acopy(this.program, 0, newprog, 0, index)
            acopy(this.program, index, newprog, index+1, this.size-index)
            this.program = newprog
          } else {
            acopy(this.labels, index, this.labels, index+1, this.size-index)
            acopy(this.program, index, this.program, index+1, this.size-index)
          }
          this.size += 1
        }
        this.labels[index] = linenum
        this.program[index] = command
      } else {
        // removing line
        if (index < this.size && this.labels[index] == linenum) {
          acopy(this.labels, index+1, this.labels, index, this.size-index-1)
          acopy(this.program, index+1, this.program, index, this.size-index-1)
          this.size -= 1
        }
      }
    } else if (command.len > 0) {
      // executing line
      this.exec(command)
    }
  }
  ok
}

def BasicVM.parse(text: String): Bool {
  var ok = true
  while (ok && text.len() > 0) {
    var nl = text.indexof('\n')
    if (nl >= 0) {
      ok = this.parseline(text[:nl])
      text = text[nl+1:]
    } else {
      ok = this.parseline(text)
      text = ""
    }
  }
  ok
}
