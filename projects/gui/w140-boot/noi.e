use "string" 
use "textio"

def numOfImg() : Int
{
var file = utfreader(fopen_r("/res/w140-boot/boot"))
var line =file.readline()
//print( "Linia:"+ line)

var l =line.split('=')
l[1].toint()
}

