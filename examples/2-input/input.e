/* Simple program that asks your
 * name and then greets you.
 */

use "io"

def main(args: [String]) {
  println("What is your name?")
  var name = readline()
  println("Hello, "+name+"!")
}
