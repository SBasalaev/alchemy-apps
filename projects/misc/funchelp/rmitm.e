def rmitm(fm: Form, rsltno: Int)
{
  var fs = fm.size()
  for (fs=fs-1, fs > rsltno-1, fs-=1)
    fm.remove(fs)
}