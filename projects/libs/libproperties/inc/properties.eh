use "dict.eh";
type Properties < Dict;

def new_properties(): Properties;
def Properties.get(key: String): String;
def Properties.set(key: String, data: Any);

def Properties.getList(): [Any];

def String.ws(): String;
def String.parse(): [String];
def String.parseBool(): Bool;

def getProperties(conf: String): Properties;
def getLocale(): String; 
def setProperties(prop: Properties,file: String); 