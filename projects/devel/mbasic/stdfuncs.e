use "mbasic.eh"

use "math.eh"
use "rnd.eh"
use "string.eh"
use "sys.eh"

var useradians: Bool;

def mb_deg() = {useradians = false}
def mb_rad() = {useradians = true}

def mb_sin(d: Double): Double = sin(if (useradians) d else deg2rad(d))
def mb_cos(d: Double): Double = cos(if (useradians) d else deg2rad(d))
def mb_tan(d: Double): Double = tan(if (useradians) d else deg2rad(d))

def mb_asin(d: Double): Double = if (useradians) asin(d) else rad2deg(asin(d))
def mb_acos(d: Double): Double = if (useradians) asin(d) else rad2deg(acos(d))
def mb_atan(d: Double): Double = if (useradians) asin(d) else rad2deg(atan(d))

def mb_mod(a: Int, b: Int): Int = a % b

def mb_asc(str: String): Int = str[0]
def mb_left(str: String, n: Int): String = str[0:n]
def mb_right(str: String, n: Int): String = str[str.len()-n: str.len()]
def mb_mid(str: String, from: Int, n: Int): String = str[from:from+n]

def BasicVM.addstdfunctions() {
  // math commands
  useradians = true
  this.addcommand("DEG", "", mb_deg)
  this.addcommand("RAD", "", mb_rad)
  // math functions
  this.addfunction("ABS", "f", 'f', abs);
  this.addfunction("EXP", "f", 'f', exp);
  this.addfunction("LOG", "f", 'f', log);
  this.addfunction("SIN", "f", 'f', mb_sin);
  this.addfunction("COS", "f", 'f', mb_cos);
  this.addfunction("TAN", "f", 'f', mb_tan);
  this.addfunction("ASIN", "f", 'f', mb_asin);
  this.addfunction("ACOS", "f", 'f', mb_acos);
  this.addfunction("ATAN", "f", 'f', mb_atan);
  this.addfunction("MOD", "ii", 'i', mb_mod);
  this.addfunction("SQR", "f", 'f', sqrt);
  // string functions
  this.addfunction("ASC", "s", 'i', mb_asc);
  this.addfunction("CHR$", "i", 's', chstr);
  this.addfunction("LEFT$", "si", 's', mb_left);
  this.addfunction("RIGHT$", "si", 's', mb_right);
  this.addfunction("MID$", "sii", 's', mb_mid);
  this.addfunction("LEN", "s", 'i', `String.len`);
  this.addfunction("STR$", "a", 's', `Any.tostr`);
  this.addfunction("VAL", "s", 'f', `String.todouble`);
  this.addfunction("RND", "i", 'i', rnd);
  // other commands
  this.addcommand("SLEEP", "i", sleep)
}
