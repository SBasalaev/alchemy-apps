// color comparison/matching

use "list"
use "math"

use "color_math.eh"
use "defs.eh"
use "list_extras.e"

def Color.true_subtract(c2: Color): Color {
   new Color {r=this.r - c2.r, g=this.g - c2.g, b=this.b - c2.b } }

def Color.true_add(c2: Color): Color {
   var rr = this.r + c2.r
   var rg = this.g + c2.g
   var rb = this.b + c2.b
   if (rr>255) {
      rr= 255 }
   else if (rr<0) {
      rr=0 }
   if (rg>255) {
      rg=255 }
   else if (rg<0) {
      rg=0 }
   if (rb>255) {
      rb=255 }
   else if (rb<0) {
      rb=0 }
   new Color {r=rr, g=rg, b=rb} }

def Color.true_mult(l: Int, m: Int): Color {
   new Color {r=(this.r*l)/m, g=(this.g*l)/m, b=(this.b*l)/m } }

def difference(c1: Color, c2: Color): Color {
   new Color {r=abs(c1.r - c2.r), g=abs(c1.g - c2.g), b=abs(c1.b - c2.b) } }

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
   var current = votes.highest()
   var most_votes = votes[current]
/* ---new routine since 0.1.29---
   while (r.len() < amount) {
      r.add(basis[current])
      current = votes.next_lower(votes[current]) }
*/
/* --- OLD UNOPTIMIZED ROUTINE ---
   --- FROM V0.1.28 ---*/
   for (i=most_votes, (i>0) && (r.len() < amount), i-=1) {
      for (j=0, j<votes.len(), j+=1) {
         if (votes[j] == i) r.add(basis[j]) } }
   r }