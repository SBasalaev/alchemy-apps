use "dict.eh"

const TEST_OK = 0
const TEST_WARN = 1
const TEST_ERR = 2

def get_spec(): Dict;

def report(msg: String, text: String, level: Int);
def get_errlevel(): Int;
def set_errlevel(level: Int);

def check_spec();
def check_dirs();
def check_libs();