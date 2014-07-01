 use"canvas"
 use"ui"
 use"graphics"
 use"sys"
 use"math"
 use"io"
 use"font"
 use"string"
 use"form"
 use"stdscreens"
 use"dialog"
 
 var font=FACE_SYSTEM|STYLE_PLAIN|SIZE_MED
 var can:Canvas
 var gra:Graphics
 var p:Point
 var form:Form
 var enter_eq:EditItem
 var menu1:Menu
 var back:Menu
 var im:Image
 var event:UIEvent
 var quit:Bool
 var app_title="Free Quadratic Equation Solver"
 var about="fqes v0.1\n\nAuthor: TANDAH Tiotsop Gildas Brice\n\ndate: June 20 2014\n\nContact: gildastandah@gmail.com"
 
 type coef{
 a:Int,
 b:Int,
 c:Int
 /*coef=a+b*sqrt(c)*/
 }
 def coef.new(a:Int,b:Int,c:Int){
 this.a=a
 this.b=b
 this.c=c
 }
 def coef.add(co:Int):coef{
 new coef(this.a+co,this.b,this.c)
 }
 type quotient{
 num:coef,
 deno:Int
 }
 def quotient.new(num:coef,deno:Int){
 this.num=new coef(num.a,num.b,num.c)
 this.deno=deno
 }
 type equation_f{
 a:Float,
 b:Float,
 c:Float
 }
 def equation_f.new(a:Float,b:Float,c:Float){
 this.a=a
 this.b=b
 this.c=c
 }
 type equation_i{
 a:Int,
 b:Int,
 c:Int
 }
 def equation_i.new(a:Int,b:Int,c:Int){
 this.a=a
 this.b=b
 this.c=c
 }
 def factorise_numb(numb:Int):[Int]{
 var fact_tab=[0,0,0,0,0]
 var tab=[2,3,5,7]
 var temp=numb
 if(numb==0) fact_tab
 else{
 for(var i=0,i<4,i+=1){
 while(temp%(tab[i])==0){
 fact_tab[i]+=1
 temp/=tab[i]
 }
 }
 fact_tab[4]=temp
 fact_tab
 }
 }
 def simplify_sqrt(co:coef){
 var tab2=[2,3,5,7]
 var tab=factorise_numb(co.c)
 for(var i=0,i<4,i+=1){
 while(tab[i]>=2){
 co.b*=tab2[i]
 co.c/=tab2[i]*tab2[i]
 tab[i]-=2
 }
 }
 if(co.c==1){
 co.a+=co.b
 co.b=0
 co.c=0
 }
 else
 if(co.b==0||co.c==0){
 co.b=0
 co.c=0
 }
 }
 def simplify_quotient(co:quotient){
 simplify_sqrt(co.num)
 var tab=[2,3,5,7]
 var tab_a=factorise_numb(co.num.a)
 var tab_b=factorise_numb(co.num.b)
 var tab_deno=factorise_numb(co.deno)
 if(co.num.a==0){
 for(var i=0,i<4,i+=1){
 while(tab_b[i]>0&&tab_deno[i]>0){
 co.deno/=tab[i]
 co.num.b/=tab[i]
 tab_deno[i]-=1
 tab_b[i]-=1
 }
 }
 }
 else
 if(co.num.b==0){
 for(var i=0,i<4,i+=1){
 while(tab_deno[i]>0&&tab_a[i]>0){
 co.deno/=tab[i]
 co.num.a/=tab[i]
 tab_deno[i]-=1
 tab_a[i]-=1
 }
 }
 }
 else
 for(var i=0,i<4,i+=1){
 while(tab_deno[i]>0&&tab_a[i]>0&&tab_b[i]>0){
 co.deno/=tab[i]
 co.num.a/=tab[i]
 co.num.b/=tab[i]
 tab_deno[i]-=1
 tab_a[i]-=1
 tab_b[i]-=1
 }
 }
 if(co.deno<0){
 co.deno=-co.deno
 co.num.a=-co.num.a
 co.num.b=-co.num.b
 }
 }
 def solve_humanly(eq:equation_i):[quotient]{
 var tab=[new quotient(new coef(0,0,0),0),new quotient(new coef(0,0,0),0)]
 var delta=new coef(0,1,eq.b*eq.b-4*eq.a*eq.c)
 var s1:quotient
 var s2:quotient
 delta+=-eq.b
 if(delta.c<0) tab
 else
 if(delta.c==0){
 s1=new quotient(delta,2*eq.a)
 simplify_quotient(s1)
 tab[0]=s1
 tab
 }
 else{
 s1=new quotient(delta,2*eq.a)
 delta.b=-delta.b
 s2=new quotient(delta,2*eq.a)
 simplify_quotient(s1)
 simplify_quotient(s2)
 tab[0]=s1
 tab[1]=s2
 tab
 }
 }
 def solve_normaly(eq:equation_f):[Float]{
 var tab:[Float]=[FNaN,FNaN]
 var delta=(eq.b*eq.b)-(4*eq.a*eq.c)
 if(delta<0) tab
 else
 if(delta==0){
 tab[0]=(0-eq.b)/2*eq.a
 tab
 }
 else{
 tab[0]=(0-eq.b+sqrt(delta))/(2*eq.a)
 tab[1]=(0-eq.b-sqrt(delta))/(2*eq.a)
 tab
 }
 }
 def draw_sqrt(gra:Graphics,start:Point,width:Int,height:Int){
 gra.draw_line(start.x,start.y,start.x+10,start.y+height)
 gra.draw_line(start.x+10,start.y+height,start.x+10,start.y)
 gra.draw_line(start.x+10,start.y,start.x+10+width,start.y)
 gra.draw_line(start.x+10+width,start.y,start.x+10+width,start.y+height/2)
 }
 def draw_normal_sols(gra:Graphics,tab:[Float],start:Point){
 if(tab[0]==FNaN) gra.draw_string("No solutions in R!",start.x,start.y)
 else
 if(tab[1]==FNaN) gra.draw_string(tab[0].tostr(),start.x,start.y)
 else{
 gra.draw_string(tab[0].tostr(),start.x,start.y)
 gra.draw_string(tab[1].tostr(),start.x,start.y+font_height(font)+5)
 }
 }
 def draw_numerator(gra:Graphics,num:coef,at:Point):Point{
 var h=font_height(font)
 var a_w=str_width(font,num.a.tostr())
 var b_w=str_width(font,num.b.tostr())
 var c_w=str_width(font,num.c.tostr())
 var sign=if(num.b>=0)"+"else"-"
 switch(num.b){
 0:{
 gra.draw_string(num.a.tostr(),at.x,at.y+3)
 new Point(at.x+a_w,at.y+h)
 }
 1,-1:{
 if(num.a==0){
 gra.draw_string((if(sign=="+")"  "else sign+" ")+num.c.tostr(),at.x,at.y+3)
 draw_sqrt(gra,new Point(at.x+3,at.y),c_w+3,h)
 new Point(at.x+c_w+3+if(sign=="+") str_width(font,"  ") else str_width(font,sign+" "),at.y+h)
 }
 else
 {
 gra.draw_string(num.a.tostr()+sign+" "+num.c.tostr(),at.x,at.y+3)
 draw_sqrt(gra,new Point(at.x+a_w+str_width(font,sign),at.y),c_w+3,h)
 new Point(at.x+a_w+str_width(font,sign+" ")+c_w+3,at.y+h)
 }
 }
 else:{
 if(num.a==0){
 gra.draw_string(num.b.tostr()+" "+num.c.tostr(),at.x,at.y+3)
 draw_sqrt(gra,new Point(at.x+b_w,at.y),c_w+3,h)
 new Point(at.x+b_w+str_width(font," ")+c_w+3,at.y+h)
 }
 else
 {
 gra.draw_string(num.a.tostr()+(if(sign=="+")sign else "")+num.b.tostr()+" "+num.c.tostr(),at.x,at.y+3)
 draw_sqrt(gra,new Point(at.x+a_w+if(sign=="+")str_width(font,sign)+b_w else b_w,at.y),c_w+3,h)
 new Point(at.x+a_w+3+b_w+c_w+str_width(font," "),at.y+h)
 }
 }
 }
 }
 def draw_deno(gra:Graphics,start:Point,end:Point,deno:Int){
 var w=str_width(font,deno.tostr())
 gra.draw_line(start.x,start.y,end.x,end.y)
 gra.draw_string(deno.tostr(),((end.x+start.x)/2)-(w/2),start.y)
 }
 def draw_human_sols(gra:Graphics,sols:[quotient],start:Point){
 if(sols[0].deno==0) gra.draw_string("No Solutions in R!",start.x,start.y)
 else
 {
 var font_h=font_height(font)
 var end=draw_numerator(gra,sols[0].num,start)
 var temp=start.y
 start.y=end.y
 if(!(sols[0].num.a==0&&sols[0].num.c==0)&&sols[0].deno!=1){
 draw_deno(gra,start,end,sols[0].deno)
 }
 if(sols[1].deno!=0){
 start.y+=if(sols[0].deno==1)font_h else 2*font_h
 end=draw_numerator(gra,sols[1].num,start)
 start.y=end.y
 if(!(sols[1].num.a==0&&sols[1].num.c==0)&&sols[1].deno!=1){
 draw_deno(gra,start,end,sols[1].deno)
 }
 }
 start.y=temp
 }
 }
 def extract_equation(str:String):equation_f{
 var ret=new equation_f(0.0,0.0,0.0)
 var temp=str
 var index=temp.indexof('X')
 if(temp.len()-index>=3&&temp.substr(index,index+3)=="X^2"){
 switch(index){
 -1:{}
 0:{ret.a=1}
 1:{
 if(temp.ch(0)=='-') ret.a=-1
 else
 {
 try
 {
 ret.a=temp.substr(0,index).tofloat()
 }
 catch{}
 }
 }
 else:{
 try
 {
 ret.a=temp.substr(0,index).tofloat()
 }
 catch{}
 }
 }
 if(index+3<=temp.len()){
 temp=str.substr(index+3,str.len())
 index=temp.indexof('X')
 switch(index){
 -1:{
 try
 {
 ret.c=if(temp.ch(0)=='-')0-temp.substr(1,temp.len()).tofloat() else temp.substr(1,temp.len()).tofloat()
 }
 catch{if(temp.len()==0) ret.c=0 else ret.c=null}
 }
 1:{
 ret.b=if(temp.ch(0)=='-') -1 else 1
 }
 else:{
 try
 {
 ret.b=if(temp.ch(0)=='-')0-temp.substr(1,index).tofloat() else temp.substr(1,index).tofloat()
 }
 catch{ret.b=null}
 }
 }
 if(index!=-1&&index+1<temp.len()){
 temp=temp.substr(index+1,temp.len())
 try
 {
 ret.c=if(temp.ch(0)=='-')0-temp.substr(1,temp.len()).tofloat() else temp.substr(1,temp.len()).tofloat()
 }
 catch{ret.c=null}
 }
 }
 }
 ret
 }
 
 def main(args:[String]){
 can=new Canvas(false)
 gra=can.graphics()
 gra.set_font(font)
 p=new Point(15,font_height(font)*3)
 form=new Form()
 enter_eq=new EditItem("enter equation","X^2-X-1")
 menu1=new Menu("Menu",5)
 back=new Menu("Back",5)
 im=null
 var eq_i=new equation_i(0,0,0)
 var eq_f:equation_f
 quit=false
 ui_set_app_title(app_title)
 can.title=app_title
 form.title=app_title
 form.add(enter_eq)
 form.add_menu(menu1)
 ui_set_screen(form)
 while(!quit){
 event=ui_wait_event()
 while(event.kind!=EV_MENU&&event.value.cast(Menu)!=menu1) event=ui_wait_event()
 switch(run_listbox(app_title,["Solve","Solve Normaly","About","Exit"])){
 -1:{}
 0:{
 eq_f=extract_equation(enter_eq.get_text().ucase())
 if(eq_f.a==0||eq_f.a==null||eq_f.b==null||eq_f.c==null) run_alert("Error","Invalid Equation",im,3000)
 else
 {
 gra.set_color(0xffffff)
 gra.fill_rect(0,0,can.width,can.height)
 gra.set_color(0)
 gra.draw_string(enter_eq.get_text()+"=0",0,0)
 gra.draw_string("Solutions",0,font_height(font)+5)
 if(eq_f.a.cast(Int)==eq_f.a&&eq_f.b.cast(Int)==eq_f.b&&eq_f.c.cast(Int)==eq_f.c){
 eq_i.a=eq_f.a.cast(Int)
 eq_i.b=eq_f.b.cast(Int)
 eq_i.c=eq_f.c.cast(Int)
 draw_human_sols(gra,solve_humanly(eq_i),p)
 }
 else
 {
 draw_normal_sols(gra,solve_normaly(eq_f),p)
 }
 ui_set_screen(can)
 can.add_menu(back)
 can.refresh()
 event=ui_wait_event()
 while(event.kind!=EV_MENU&&event.value.cast(Menu)!=back) event=ui_wait_event()
 ui_set_screen(form)
 }
 }
 1:{
 eq_f=extract_equation(enter_eq.get_text().ucase())
 if(eq_f.a==0||eq_f.a==null||eq_f.b==null||eq_f.c==null) run_alert("Error","Invalid Equation",im,3000)
 else
 {
 gra.set_color(0xffffff)
 gra.fill_rect(0,0,can.width,can.height)
 gra.set_color(0)
 gra.draw_string(enter_eq.get_text()+"=0",0,0)
 gra.draw_string("Solutions",0,font_height(font)+5)
 draw_normal_sols(gra,solve_normaly(eq_f),p)
 can.add_menu(back)
 ui_set_screen(can)
 can.refresh()
 event=ui_wait_event()
 while(event.kind!=EV_MENU&&event.value.cast(Menu)!=back) event=ui_wait_event()
 ui_set_screen(form)
 }
 }
 2: run_alert("About",about,im,-1)
 3: quit=true
 }
 }
 }
