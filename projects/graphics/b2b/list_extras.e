// extra List routines

use "list"

use "defs.eh"

def List.lowest(): Int {
   var r = 0
   var s: Int = this[0]
   for (i=1, i<this.len(), i+=1) {
      if (s>cast(Int)this[i]) {
         s = this[i]
         r = i } }
   r }

def List.highest(): Int {
   var r = 0
   var s: Int = this[0]
   for (i=1, i<this.len(),  i+=1) {
      if (s<cast(Int)this[i]) {
         s = this[i]
         r = i } }
   r }

def List.fill(n: Int, v: Int) {
   this.clear()
   for (i=0, i<=n, i+=1) this.add(v) }

def List.increment(at: Int, amount: Int) {
   if (this[at] != null) {
      this.set(at, (cast(Int)(this[at])) + amount) }
   else {
      this[at] = 1 } }