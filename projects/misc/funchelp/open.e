def open(file: String): String
{
  var strm = fopen_r(file)
  var r = utfreader(strm)
  var txt=freadstr(r, 2000)
  fclose(strm)
  txt
}