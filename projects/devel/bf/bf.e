/* brainfuck interpreter
 * Version 1.0.1
 * (C) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io"

def main(args: [String]) {
  // reading program
  var file = args[0]
  var prog = new BArray(fsize(file))
  var in = fopen_r(file)
  in.readarray(prog, 0, prog.len)
  in.close()
  // executing
  var array = new BArray(4000)
  var pos = 0 // position in array
  var ct = 0  // program counter
  while (ct < prog.len) {
    switch (prog[ct]) {
      '<': pos -= 1
      '>': pos += 1
      '-': array[pos] = array[pos] - 1
      '+': array[pos] = array[pos] + 1
      '.': write(array[pos])
      ',': array[pos] = read()
      '[':
        if (array[pos] == 0) {
          var br = 1
          while (br != 0) {
            ct += 1
            if (prog[ct] == '[') br += 1
            else if (prog[ct] == ']') br -= 1
          }
        }
      ']':
        if (array[pos] != 0) {
          var br = 1
          while (br != 0) {
            ct -= 1
            if (prog[ct] == ']') br += 1
            else if (prog[ct] == '[') br -= 1
          }
        }
    }
    ct += 1
  }
  flush()
}
