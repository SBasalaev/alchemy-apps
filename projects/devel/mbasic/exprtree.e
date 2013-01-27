use "exprtree.eh"
use "io.eh" 

def Expr.writeto(out: OStream) {
  out.write(this.code)
  switch (this.code) {
    LDBYTE: {
      var byte = (cast (LiteralExpr) this).idx
      out.write(byte)
    }
    LDSHORT, LDINT, LDFLOAT, LDSTRING: {
      var idx = (cast (LiteralExpr) this).idx
      out.write(idx >> 8)
      out.write(idx)
    }
    GETIVAR, GETFVAR, GETSVAR: {
      var idx = (cast (VarExpr) this).idx
      out.write(idx)
    }
    PARENS, I2F, F2I, INEG, FNEG, INOT: {
      var unary = cast (UnaryExpr) this
      unary.sub.writeto(out)
    }
    IFUNC0, IFUNC1, IFUNC2, IFUNC3,
    IFUNC4, IFUNC5, IFUNC6, IFUNC7,
    FFUNC0, FFUNC1, FFUNC2, FFUNC3,
    FFUNC4, FFUNC5, FFUNC6, FFUNC7,
    SFUNC0, SFUNC1, SFUNC2, SFUNC3,
    SFUNC4, SFUNC5, SFUNC6, SFUNC7: {
      var fe = cast (FuncExpr) this
      out.write(fe.idx)
      for (var i=0, i<fe.args.len, i+=1)
        fe.args[i].writeto(out)
    }
    else: {
      var binary = cast (BinaryExpr) this
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
    (cast (UnaryExpr) this).sub.rettype()
  }
  else:
    ET_INT;
}
