use "exprtree.eh"
use "io.eh" 

def Expr.writeto(out: OStream) {
  out.write(this.code)
  switch (this.code) {
    LDBYTE: {
      var byte = this.cast(LiteralExpr).idx
      out.write(byte)
    }
    LDSHORT, LDINT, LDFLOAT, LDSTRING: {
      var idx = this.cast(LiteralExpr).idx
      out.write(idx >> 8)
      out.write(idx)
    }
    GETIVAR, GETFVAR, GETSVAR: {
      var idx = this.cast(VarExpr).idx
      out.write(idx)
    }
    PARENS, I2F, F2I, INEG, FNEG, INOT: {
      var unary = this.cast(UnaryExpr)
      unary.sub.writeto(out)
    }
    IFUNC0, IFUNC1, IFUNC2, IFUNC3,
    IFUNC4, IFUNC5, IFUNC6, IFUNC7,
    FFUNC0, FFUNC1, FFUNC2, FFUNC3,
    FFUNC4, FFUNC5, FFUNC6, FFUNC7,
    SFUNC0, SFUNC1, SFUNC2, SFUNC3,
    SFUNC4, SFUNC5, SFUNC6, SFUNC7: {
      var fe = this.cast(FuncExpr)
      out.write(fe.idx)
      for (var i=0, i<fe.args.len, i+=1)
        fe.args[i].writeto(out)
    }
    else: {
      var binary = this.cast(BinaryExpr)
      binary.left.writeto(out)
      binary.right.writeto(out)
    }
  }
}

def Expr.rettype(): Int = switch (this.code) {
  LDFLOAT, I2F, FADD, FSUB, FMUL, FDIV, FNEG, GETFVAR,
  FFUNC0, FFUNC1, FFUNC2, FFUNC3, FFUNC4, FFUNC5, FFUNC6, FFUNC7:
    ET_FLOAT;
  LDSTRING, GETSVAR,
  SFUNC0, SFUNC1, SFUNC2, SFUNC3, SFUNC4, SFUNC5, SFUNC6, SFUNC7:
    ET_STRING;
  PARENS: {
    this.cast(UnaryExpr).sub.rettype()
  }
  else:
    ET_INT;
}
