use "textio"
use "dict"
use "string"
use "sys"

type Properties < Dict;
var local: String

def new_properties(): Properties =cast (Properties) new_dict();

def Properties.get(key : String): String {
`Dict.get`(this, key).tostr()
}

def Properties.set (key: String, data: Any) = `Dict.set` (this, key, data);

def Properties.remove(key : String) = `Dict.remove`(this, key);

def Properties.getList (): [Any]= `Dict.keys` (this)

def String.ws(): String {
var char=this.chars()
var pstr =""
var len = 0
while (len <char.len){
if (char[len] !=' '||char[len] !='\t'){pstr=pstr 
 +chstr(char[len]) 
len +=1} else {len +=1}
}
pstr
}

def String.parse(): [String] {
var split =new [String]{"",""}
try {
this.split('=')
} catch {
split
}
}


def String.parseBool(): Bool {
if(this =="true") {
true
}
else {
false
}
}

def getProperties(conf: String): Properties {
var file =utfreader(fopen_r(conf))
var prop =new_properties()
var line = file.readline()
var confl: [String]
while (line != "#end"){
if (line.get(0)=='#') {
line =file.readline()
}
else {
confl=line.parse()
prop.set(confl[0].ws(),confl[1])
line =file.readline()}
}
file.close()
prop
}

def getLocale(): String {
try {
local =utfreader(fopen_r("/cfg/locale")).readline()
if (local==null) local=""
}
catch {
print("File \"locale\" not found")
local=""
}
local
}

def setProperties(prop: Properties, file: String) {
var out =utfwriter(fopen_w(file))
var list =prop.getList()
for (var i=0,i<list.len,i+=1){
var val =prop.get(list[i])
out.println(""+list[i]+"="+val)
}
out.println("#end")
out.close()
}