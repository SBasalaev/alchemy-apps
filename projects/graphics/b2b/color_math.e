// color comparison/matching

use "list"
use "math"

use "color_math.eh"
use "defs.eh"
use "list_extras.e"

def difference(c1: Color, c2: Color): Color {
   var rs = abs(c1.r - c2.r)
   var gs = abs(c1.g - c2.g)
   var bs = abs(c1.b - c2.b)
   new Color { r=rs, g=gs, b=bs } }

def Color.intensity(): Int {
   sqrt((this.r*this.r)+(this.g*this.g)+(this.b*this.b))*4 }

def Color.tostr(): String {
   "["+this.r+", "+this.g+", "+this.b+"]" }

def Color.rgb(): Int {
   if (this != null) {
     (this.r << 16) + (this.g << 8) + this.b }
   else {
      this = new Color {r=0, g=0, b=0}
      0 } }

def Color.closest(p: List): Int {
   var diffs = new_list()
   for (i=0, i<p.len(), i+=1) {
      diffs.add(difference(this, p[i]).intensity()) }
   diffs.lowest()
}

def top_votes(votes: List, basis: List, amount: Int): List {
   var r: List = new_list()
   var most_votes = votes[votes.highest()]
   for (i=most_votes, (i>0) && (r.len() < amount), i-=1) {
      for (j=0, j<votes.len(), j+=1) {
         if (votes[j] == i) r.add(basis[j]) } }
   r }