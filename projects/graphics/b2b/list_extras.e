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

def List.lowest_positive(): Int {
   var r = 0
   var t = 0
   var s: Int = this[0]
   for (i=1, i<this.len(), i+=1) {
      t = this[i]
      if (s>t && t>0) {
         s = this[i]
         r = i } }
   r }

def List.next_lower(start: Int): Int {
   var di = new_list()
   for (i=0, i<this.len(), i+=1) {
      di.add(start-(cast(Int)this[i])) }
   di.lowest_positive() }

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
      this[at] = (cast(Int)(this[at])) + amount }
   else {
      this[at] = 1 } }