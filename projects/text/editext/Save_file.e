def Save_file(args0:String)
{
    status = title
    title = "Saving file..."
    draw_status_area(g)
    var os = fopen_w(args0)
    var writer = utfwriter(os)
    for(var k = 0,k<listlen,k+=1)
    {
     writer.println(list.get(k).tostr())
    }
    writer.close()
    os.close()
    title = status
    draw_status_area(g)
}