def cmpr(test: String, query: String, ch1: Int, ch2: Int): String
{
  var in = strindex(test, ch2)
  var len = strlen(test)
  if(ch2 == '0')
    in=len
  if (in != -1) {
    var result = substr(test, in, len)
    var rin = 1
    while (rin != 0 && ch1 != '0')
    {
      in = in-1
      result = substr(test, in, len)
      rin = strindex(result, ch1)
    }
    if (ch1 == '0')
    result = " " + test
    var cmp = substr(result, 1, 1+strlen(query))
    if (cmp == query) {"*"+result}
    else {""}
  }
  else {""}
}