use "dict.eh"
use "list.eh"

// reporting functions
const TEST_OK = 0
const TEST_WARN = 1
const TEST_ERR = 2
const TEST_FATAL = 3

def report(msg: String, text: String, level: Int);
def get_errlevel(): Int;
def set_errlevel(level: Int);

// utility functions used by several checks
def get_spec(): Dict;
def get_depends(): List;

// implemented checks (called by main)
def check_spec();
def check_dirs();
def check_libs();