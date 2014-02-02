type MessageScreen;

def MessageScreen.new(title: String);
def MessageScreen.setMessage(str: String);
def MessageScreen.show();
def MessageScreen.hide();

type ProgressScreen < MessageScreen;

def ProgressScreen.new(title: String);
def ProgressScreen.setProgress(current: Int, max: Int, package: String, version: String);
