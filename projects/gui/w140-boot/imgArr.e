use "dataio.eh"
use "image"
use "noi.e"

def imgArr(): [Image] {
var file = utfreader(fopen_r("/res/w140-boot/boot"))
var line =file.readline()
var ar =new [Image] (numOfImg())
var count=0
line =file.readline()
try {
while (line !=null){
ar[count]=image_from_file("/res/w140-boot/"+line)
count=count+1
line = file.readline()
}
}
catch {ar=null}
ar
}