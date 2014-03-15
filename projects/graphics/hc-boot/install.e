use "sys"
use "io"

def main(args:[String]) {
println("Installing...");
var f:OStream = fopen_a("/cfg/init.user");
f.println("");
f.println("hc-boot");
f.close();
println("Done!");
}