def rmitm(fm: Screen, rsltno: Int)
{
  var fs = form_size(fm)
  for (fs=fs-1, fs > rsltno-1, fs=fs-1)
    form_remove(fm,fs)
}