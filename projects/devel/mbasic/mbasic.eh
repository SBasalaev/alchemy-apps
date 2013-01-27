 
type BasicVM;

/* VM states. */
const VM_IDLE = 0
const VM_RUN = 1
const VM_EXIT = 2

def new_basicvm(usestd: Bool): BasicVM;
def BasicVM.reset();
def BasicVM.run(label: Int): Int;
def BasicVM.parse(text: String): Bool;
def BasicVM.get_state(): Int;
def BasicVM.set_ivar(name: String, value: Int);
def BasicVM.set_fvar(name: String, value: Double);
def BasicVM.set_svar(name: String, value: String);
def BasicVM.get_ivar(name: String): Int;
def BasicVM.get_fvar(name: String): Double;
def BasicVM.get_svar(name: String): String;

/* Registers new function. */
def BasicVM.addfunction(name: String, args: String, rettype: Int, impl: Function): Bool;
/* Registers new command. */
def BasicVM.addcommand(name: String, args: String, impl: Function): Bool;
