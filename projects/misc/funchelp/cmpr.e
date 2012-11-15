def cmpr(test: String, query: String, ch1: Int, ch2: Int): String
{
  var in = test.indexof(ch2)
  var len = test.len()
  if(ch2 == '0')
    in=len
  if (in != -1) {
    var result = test[in:len]
    var rin = 1
    while (rin != 0 && ch1 != '0')
    {
      in = in-1
      result = test[in:len]
      rin = result.indexof(ch1)
    }
    if (ch1 == '0')
    result = " " + test
    var cmp = result[1: 1+query.len()]
    if (cmp == query) {"*"+result}
    else {""}
  }
  else {""}
}