use "complex.eh"
use "math.eh"

type Complex {
  r: Double,
  i: Double
}

def Complex.new(re: Double, im: Double) {
  this.r = re
  this.i = im
}

def Complex.re(): Double = this.r
def Complex.im(): Double = this.i

def Complex.abs(): Double {
  sqrt(this.r*this.r + this.i*this.i)
}

def Complex.add(c: Complex): Complex {
  new Complex(this.r + c.r, this.i + c.i)
}

def Complex.sub(c: Complex): Complex {
  new Complex(this.r - c.r, this.i - c.i)
}

def Complex.mul(c: Complex): Complex {
  new Complex(
    this.r * c.r - this.i * c.i,
    this.r * c.i + this.i * c.r)
}

def Complex.div(c: Complex): Complex {
  var scale = c.r * c.r + c.i * c.i
  var cinv = new Complex(c.r / scale, -c.i / scale)
  this.mul(cinv)
}

def Complex.minus(): Complex {
  new Complex(-this.r, -this.i)
}

def Complex.tostr(): String {
  if (this.i == 0.0)
    "" + this.r
  else if (this.r == 0.0)
    "" + this.i + 'i'
  else if (this.i < 0)
    "" + this.r + this.i + 'i'
  else
    "" + this.r + '+' + this.i + 'i'
}
