/*ex main.e -o libmp3.1.so -slibmp3.1.so*/ 
use "dataio"
use "list"
use "io"
use "string"
 
type Metadata
{
COMMENT:String,
LINK:String,
MUSIC_CD_ID:String,
ALBUM:String,
BITSPERMIN:String,
COMPOSER:String,
GENRE:String,
COPYRIGHT:String,
DATE:String,
DELAY:String,
ENCODED_BY:String,
LYRICIST:String,
FILE_TYPE:String,
TIME:String,
CONTENT_GROUP_DESCRIPTION:String,
TITLE:String,
SUBTITLE:String,
MEDIA_TYPE:String,
ORIGINAL_ALBUM:String,
ORIGINAL_FILENAME:String,
ORIGINAL_LYRICIST:String,
ORIGINAL_ARTIST:String,
TRACK_NO:String,
SIZE:String,
YEAR:String,
SETTING_FOR_ENCODING:String,
URL:String,
AUTHOR:String,
BAND:String,
PERFORMER:String,
POSITION:String,
MODIFIED_BY:String,
RADIO_STATION_NAME:String,
PUBLISHER:String,
AUDIO_WEBPAGE:String,
ARTIST_WEBPAGE:String,
RADIO_STATION_OWNER:String,
SYNC_LINK:String,
AUDIO_ENC:String,
COMMERCIAL_FRAME:String,
ENC_METHOD:String,
EQUALIZATION:String,
EVENT_TIMING_CODES:String,
GENERAL_ENC_OBJ:String,
GROUP_ID_REGISTRATION:String,
INVOLVED_PEOPLES:String,
MPEG_LUT:String,
OWNERSHIP_FRAME:String,
PRIVATE_FRAME:String,
PLAY_COUNTER:String,
POPULARIMETER:String,
POSITION_SYNC_FRAME:String,
RECOM_BUFFER:String,
REVERB:String,
RELATIVE_VOLUME_ADJ:String,
SYNC_TEMPO_CODES:String,
INITIAL_KEY:String,
LANGUAGE:String,
LENGTH:String,
ORG_RELEASED_YEAR:String,
LICENCES:String,
REC_DATES:String,
INT_STD_REC_CODES:String,
USER_DEFINE_INFO:String,
UNIQUE_FILE_ID:String,
TERMS_OF_USE:String,
UNSYNC_LYRICS:String,
COMMERCIAL_INFO:String,
COPYRIGHT_INFO:String,
AUDIO_SOURCE_WEBPAGE:String,
INTERNET_RADIO_STATION_WEBPAGE:String,
PAYMENT:String
}
 
def getMetadata(args:String):Metadata
{
var md=new Metadata(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
var tagname=new List()
tagname.addall(["COMM","LINK","MCDI","TALB","TBMP","TCOM","TCON","TCOP","TDAT","TDLY","TENC","TEXT","TFLT","TIME","TIT1","TIT2","TIT3","TMED","TOAL","TOFN","TOLY","TOPE","TRCK","TSIZ","TYER","TSSE","WXXX","TPE1","TPE2","TPE3","TPOS","TPE4","TRSN","TPUB","WOAF","WOAR","TRSO","SYLT","AENC","COMR","ENRC","EQUA","ETCO","GEOB","GRID","IPLS","MLLT","OWNE","PRIV","PCNT","POPM","POSS","RBUF","RVRB","RVAD","SYTC","TKEY","TLAN","TLEN","TORY","TOWN","TRDA","TSRC","TXXX","UFID","USER","USLT","WCOM","WCOP","WOAS","WORS","WPAY"])
var is = fopen_r(args)
var b=new [Byte](10)
is.readarray(b,0,10)
if(b[0]== 'I'&& b[1]== 'D'&& b[2]== '3')
{
var tagsize = (b[9]& 0xFF)|((b[8] & 0xFF) << 7 ) | ((b[7] & 0xFF) << 14 ) | ((b[6] & 0xFF) << 21 ) + 10
b=new [Byte](tagsize)
is.readarray(b,0,tagsize)
is.close()
is=istream_from_ba(b)
var vlu=""
try{
while(is.available()>4)
{
var b1=is.readbyte()
if((b1 > 64 && b1 < 91 ))
{
var b2=is.readbyte()
var b3=is.readbyte()
var b4=is.readbyte()
if((b2>64 && b2<91)&&(b3>64 && b3<91)&&(b4>47 && b4<91))
{
var tn=""
try
{
tn=""+chstr(b1)+chstr(b2)+chstr(b3)+chstr(b4)
}catch(var e){println(e.tostr())} 
if(tn=="APIC")
{
var imz=((is.readbyte()& 0xFF)<<24)|((is.readbyte() & 0xFF)<<16)|((is.readbyte()&0xFF)<<8)|(is.readbyte()&0xFF)
is.skip(imz)
}
else
{
var fsz = ((is.readbyte()& 0xFF)<<24)|((is.readbyte() & 0xFF)<<16)|((is.readbyte()&0xFF)<<8)|(is.readbyte()&0xFF)
if(fsz>0)
{ 
var tb=new [Byte](fsz+2)
is.readarray(tb,0,(fsz+2))
vlu=""
for(var i=0,i<tb.len,i+=1)
{
 if(tb[i]>7)
 {
  vlu=vlu+chstr(tb[i])
 }
} 
var indx=tagname.indexof(tn)
if(indx>=0)
{
 switch(indx)
 {
  0:
{
 if(vlu.startswith("eng"))
 {
  vlu=vlu.substr(3,vlu.len())
 }
 md.COMMENT=vlu
}
  1:md.LINK=vlu;
  2:md.MUSIC_CD_ID=vlu;
  3:md.ALBUM=vlu;
  4:md.BITSPERMIN=vlu;
  5:md.COMPOSER=vlu;
  6:
 {
  if(vlu.startswith("(",0)&&vlu.endswith(")"))
  {
    var ps=(vlu.substr(1,vlu.indexof(')'))).toint()
    try{
     if(ps>=0 && ps<(82)){var genres=["Blues","ClassicRock","Country","Dance","Disco","Funk","Grunge","HipHop","Jazz","Metal","NewAge","Oldies","Other","Pop","RnB","Rap","Reggae","Rock","Techno","Industrial","Alternative","Ska","DeathMetal","Pranks","Soundtrack","EuroTechno","Ambient","TripHop","Vocal","JazzFunk","Fusion","Trance","Classical","Instrumental","Acid","House","Game","SoundClip","Gospel","Noise","AlternRock","Bass","Soul","Punk","Space","Meditative","InstrumentalPop","InstrumentalRock","Ethnic","Gothic","Darkwave","TechnoIndustrial","Electronic","PopFolk","Eurodance","Dream","SouthernRock","Comedy","Cult","Gangsta","Top40","ChristianRap","PopFunk","Jungle","NativeAmerican","Cabaret","NewWave","Psychadelic","Rave","Showtunes","Trailer","LoFi","Tribal","AcidPunk","AcidJazz","Polka","Retro","Musical","RocknRoll","HardRock"];vlu=genres[ps]}
    }catch{}
  }
  md.GENRE=vlu
 }
  7:md.COPYRIGHT=vlu;
  8:md.DATE=vlu;
  9:md.DELAY=vlu;
  10:md.ENCODED_BY=vlu;
  11:md.LYRICIST=vlu;
  12:md.FILE_TYPE=vlu;
  13:md.TIME=vlu;
  14:md.CONTENT_GROUP_DESCRIPTION=vlu;
  15:md.TITLE=vlu;
  16:md.SUBTITLE=vlu;
  17:md.MEDIA_TYPE=vlu;
  18:md.ORIGINAL_ALBUM=vlu;
  19:md.ORIGINAL_FILENAME=vlu;
  20:md.ORIGINAL_LYRICIST=vlu;
  21:md.ORIGINAL_ARTIST=vlu;
  22:md.TRACK_NO=vlu;
  23:md.SIZE=vlu;
  24:md.YEAR=vlu;
  25:md.SETTING_FOR_ENCODING=vlu;
  26:md.URL=vlu;
  27:md.AUTHOR=vlu;
  28:md.BAND=vlu;
  29:md.PERFORMER=vlu;
  30:md.POSITION=vlu;
  31:md.MODIFIED_BY=vlu;
  32:md.RADIO_STATION_NAME=vlu;
  33:md.PUBLISHER=vlu;
  34:md.AUDIO_WEBPAGE=vlu;
  35:md.ARTIST_WEBPAGE=vlu;
  36:md.RADIO_STATION_OWNER=vlu;
  37:md.SYNC_LINK=vlu;
  38:md.AUDIO_ENC=vlu;
  39:md.COMMERCIAL_FRAME=vlu;
  40:md.ENC_METHOD=vlu;
  41:md.EQUALIZATION=vlu;
  42:md.EVENT_TIMING_CODES=vlu;
  43:md.GENERAL_ENC_OBJ=vlu;
  44:md.GROUP_ID_REGISTRATION=vlu;
  45:md.INVOLVED_PEOPLES=vlu;
  46:md.MPEG_LUT=vlu;
  47:md.OWNERSHIP_FRAME=vlu;
  48:md.PRIVATE_FRAME=vlu;
  49:md.PLAY_COUNTER=vlu;
  50:md.POPULARIMETER=vlu;
  51:md.POSITION_SYNC_FRAME=vlu;
  52:md.RECOM_BUFFER=vlu;
  53:md.REVERB=vlu;
  54:md.RELATIVE_VOLUME_ADJ=vlu;
  55:md.SYNC_TEMPO_CODES=vlu;
  56:md.INITIAL_KEY=vlu;
  57:md.LANGUAGE=vlu;
  58:md.LENGTH=vlu;
  59:md.ORG_RELEASED_YEAR=vlu;
  60:md.LICENCES=vlu;
  61:md.REC_DATES=vlu;
  62:md.INT_STD_REC_CODES=vlu;
  63:md.USER_DEFINE_INFO=vlu;
  64:md.UNIQUE_FILE_ID=vlu;
  65:md.TERMS_OF_USE=vlu;
  66:md.UNSYNC_LYRICS=vlu;
  67:md.COMMERCIAL_INFO=vlu;
  68:md.COPYRIGHT_INFO=vlu;
  69:md.AUDIO_SOURCE_WEBPAGE=vlu;
  70:md.INTERNET_RADIO_STATION_WEBPAGE=vlu;
  71:md.PAYMENT=vlu;
 }
}
}
}
}
}
}
}catch(var e){println("\nerror:"+e.tostr())}
}
is.close()
md
}
