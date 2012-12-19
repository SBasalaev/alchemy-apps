use "string"
use "textio"
use "properties.eh"


def main(args: [String]){
var prop = getProperties("prop")
var ls=prop.getList() 
var l=0
while (l!=ls.len){
println(ls[l])
l+=1}
prop.set("help","2")
setProperties(prop,"prop")
}