def open(file: String): String
{
  var r = utfreader(fopen_r(file))
  var txt=r.readstr(2000)
  r.close()
  txt
}