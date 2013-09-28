type ActionList;

def ActionList.new(title: String);
def ActionList.start(useCancel: Bool = true);
def ActionList.clear();
def ActionList.add(text: String, icon: String, action: ());
def ActionList.set(index: Int, text: String, icon: String, action: ());