/* Example of work with structures and methods.
 * Also demonstrates output using
 * concatenation and using printf.
 */

use "io"

/* Complex number */
type Complex {
  re: Double,
  im: Double
}

/* Sum of two complex numbers */
def Complex.add(c: Complex): Complex =
 new Complex(this.re + c.re, this.im + c.im)

def main(args: [String]) {
  var z1 = new Complex(1, 2)
  var z2 = new Complex(3, 4)
  var z3 = z1.add(z2)
  /* Printing using printf */
  printf("%0+%1i + %2+%3i", [z1.re, z1.im, z2.re, z2.im])
  /* Printing using concatenation */
  println(" = " + z3.re + "+" + z3.im + "i")
}
