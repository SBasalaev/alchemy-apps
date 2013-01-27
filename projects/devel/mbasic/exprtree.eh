use "bytecode.eh"

type Expr {
  code: Int
}

type LiteralExpr < Expr {
  idx: Int
}

type VarExpr < Expr {
  idx: Int
}

type UnaryExpr < Expr {
  sub: Expr
}

type BinaryExpr < Expr {
  left: Expr,
  right: Expr
}

type FuncExpr < Expr {
  idx: Int,
  args: [Expr]
}

/* writes tree bytecode to the output */
type OStream;
def Expr.writeto(out: OStream);

/* Returns type of the expression. */
const ET_INT = 1
const ET_FLOAT = 2
const ET_STRING = 3

def Expr.rettype(): Int;
