/* The local file header */
const LOCHDR = 30;
const LOCSIG = 'P'|('K'<<8)|(3<<16)|(4<<24);

const LOCVER =  4;
const LOCFLG =  6;
const LOCHOW =  8;
const LOCTIM = 10;
const LOCCRC = 14;
const LOCSIZ = 18;
const LOCLEN = 22;
const LOCNAM = 26;
const LOCEXT = 28;

/* The Data descriptor */
const EXTSIG = 'P'|('K'<<8)|(7<<16)|(8<<24);
const EXTHDR = 16;

const EXTCRC =  4;
const EXTSIZ =  8;
const EXTLEN = 12;

/* The central directory file header */
const CENSIG = 'P'|('K'<<8)|(1<<16)|(2<<24);
const CENHDR = 46;

const CENVEM =  4;
const CENVER =  6;
const CENFLG =  8;
const CENHOW = 10;
const CENTIM = 12;
const CENCRC = 16;
const CENSIZ = 20;
const CENLEN = 24;
const CENNAM = 28;
const CENEXT = 30;
const CENCOM = 32;
const CENDSK = 34;
const CENATT = 36;
const CENATX = 38;
const CENOFF = 42;

/* The entries in the end of central directory */
const ENDSIG = 'P'|('K'<<8)|(5<<16)|(6<<24);
const ENDHDR = 22;

const ENDNRD =  4;
const ENDSUB =  8;
const ENDTOT = 10;
const ENDSIZ = 12;
const ENDOFF = 16;
const ENDCOM = 20;
