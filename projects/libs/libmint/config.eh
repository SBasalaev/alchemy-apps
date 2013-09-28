use "dict.eh"

def readCfgFile(file: String): Dict;

type Config {
  iconTheme: String = "",
  listIconSize: Int = 16,
  dialogIconSize: Int = 32,
  dialogFont: Int = 0
}

def getConfig(): Config;
