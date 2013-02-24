use "io.eh"
use "complex.eh"

def main(args: [String]) {
  var a = new Complex(2.0, 3.0);
  var b = new Complex(-3.0, 4.0);

  println("a       = " + a);
  println("b       = " + b);
  println("Re(a)   = " + a.re());
  println("Im(a)   = " + a.im());
  println("b + a   = " + (b + a));
  println("a - b   = " + (a - b));
  println("a * b   = " + (a * b));
  println("b * a   = " + (b * a));
  println("a / b   = " + (a / b));
  println("(a/b)*b = " + (a / b * b));
  println("|a|     = " + a.abs());
}