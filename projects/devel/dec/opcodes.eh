/* Alchemy assembler opcodes. */

const LFLAG_SONAME = 1;  /* Library has soname. */
const LFLAG_DEPS = 2;    /* Library has dependencies. */

const FFLAG_SHARED = 1;  /* Function is shared. */
const FFLAG_RELOCS = 2;  /* Function has relocation table. */
const FFLAG_LNUM   = 4;  /* Function has line number table. */
const FFLAG_ERRTBL = 8;  /* Function has error table. */

const NOP         = 0x00;
const ACONST_NULL = 0x01;
const ICONST_M1   = 0x02;
const ICONST_0    = 0x03;
const ICONST_1    = 0x04;
const ICONST_2    = 0x05;
const ICONST_3    = 0x06;
const ICONST_4    = 0x07;
const ICONST_5    = 0x08;
const LCONST_0    = 0x09;
const LCONST_1    = 0x0A;
const FCONST_0    = 0x0B;
const FCONST_1    = 0x0C;
const FCONST_2    = 0x0D;
const DCONST_0    = 0x0E;
const DCONST_1    = 0x0F;
const IADD        = 0x10;
const ISUB        = 0x11;
const IMUL        = 0x12;
const IDIV        = 0x13;
const IMOD        = 0x14;
const INEG        = 0x15;
const ICMP        = 0x16;
const ISHL        = 0x17;
const ISHR        = 0x18;
const IUSHR       = 0x19;
const IAND        = 0x1A;
const IOR         = 0x1B;
const IXOR        = 0x1C;
const I2B         = 0x1D;
const RET_NULL    = 0x1E;
const RETURN      = 0x1F;
const LADD        = 0x20;
const LSUB        = 0x21;
const LMUL        = 0x22;
const LDIV        = 0x23;
const LMOD        = 0x24;
const LNEG        = 0x25;
const LCMP        = 0x26;
const LSHL        = 0x27;
const LSHR        = 0x28;
const LUSHR       = 0x29;
const LAND        = 0x2A;
const LOR         = 0x2B;
const LXOR        = 0x2C;
const DUP         = 0x2D;
const DUP2        = 0x2E;
const SWAP        = 0x2F;
const FADD        = 0x30;
const FSUB        = 0x31;
const FMUL        = 0x32;
const FDIV        = 0x33;
const FMOD        = 0x34;
const FNEG        = 0x35;
const FCMP        = 0x36;
const I2L         = 0x37;
const I2F         = 0x38;
const I2D         = 0x39;
const L2F         = 0x3A;
const L2D         = 0x3B;
const L2I         = 0x3C;
const LOAD        = 0x3D;
const STORE       = 0x3E;
const LDC         = 0x3F;
const DADD        = 0x40;
const DSUB        = 0x41;
const DMUL        = 0x42;
const DDIV        = 0x43;
const DMOD        = 0x44;
const DNEG        = 0x45;
const DCMP        = 0x46;
const F2D         = 0x47;
const F2I         = 0x48;
const F2L         = 0x49;
const D2I         = 0x4A;
const D2L         = 0x4B;
const D2F         = 0x4C;
const CALL        = 0x4D;
const CALV        = 0x4E;
const ACMP        = 0x4F;
const LOAD_0      = 0x50;
const LOAD_1      = 0x51;
const LOAD_2      = 0x52;
const LOAD_3      = 0x53;
const LOAD_4      = 0x54;
const LOAD_5      = 0x55;
const LOAD_6      = 0x56;
const LOAD_7      = 0x57;
const STORE_0     = 0x58;
const STORE_1     = 0x59;
const STORE_2     = 0x5A;
const STORE_3     = 0x5B;
const STORE_4     = 0x5C;
const STORE_5     = 0x5D;
const STORE_6     = 0x5E;
const STORE_7     = 0x5F;
const POP         = 0x60;
const IFEQ        = 0x61;
const IFNE        = 0x62;
const IFLT        = 0x63;
const IFGE        = 0x64;
const IFGT        = 0x65;
const IFLE        = 0x66;
const GOTO        = 0x67;
const IFNULL      = 0x68;
const IFNNULL     = 0x69;
const IF_ICMPLT   = 0x6A;
const IF_ICMPGE   = 0x6B;
const IF_ICMPGT   = 0x6C;
const IF_ICMPLE   = 0x6D;
const BIPUSH      = 0x6E;
const SIPUSH      = 0x6F;
const CALL_0      = 0x70;
const CALL_1      = 0x71;
const CALL_2      = 0x72;
const CALL_3      = 0x73;
const CALL_4      = 0x74;
const CALL_5      = 0x75;
const CALL_6      = 0x76;
const CALL_7      = 0x77;
const CALV_0      = 0x78;
const CALV_1      = 0x79;
const CALV_2      = 0x7A;
const CALV_3      = 0x7B;
const CALV_4      = 0x7C;
const CALV_5      = 0x7D;
const CALV_6      = 0x7E;
const CALV_7      = 0x7F;

const IINC        = 0xD3;
const JSR         = 0xD4;
const RET         = 0xD5;
const IF_ACMPEQ   = 0xD6;
const IF_ACMPNE   = 0xD7;
const NEWZA       = 0xD8;
const ZALOAD      = 0xD9;
const ZASTORE     = 0xDA;
const ZALEN       = 0xDB;
const NEWSA       = 0xDC;
const SALOAD      = 0xDD;
const SASTORE     = 0xDE;
const SALEN       = 0xDF;
const NEWIA       = 0xE0;
const IALOAD      = 0xE1;
const IASTORE     = 0xE2;
const IALEN       = 0xE3;
const NEWLA       = 0xE4;
const LALOAD      = 0xE5;
const LASTORE     = 0xE6;
const LALEN       = 0xE7;
const NEWFA       = 0xE8;
const FALOAD      = 0xE9;
const FASTORE     = 0xEA;
const FALEN       = 0xEB;
const NEWDA       = 0xEC;
const DALOAD      = 0xED;
const DASTORE     = 0xEE;
const DALEN       = 0xEF;
const NEWAA       = 0xF0;
const AALOAD      = 0xF1;
const AASTORE     = 0xF2;
const AALEN       = 0xF3;
const NEWBA       = 0xF4;
const BALOAD      = 0xF5;
const BASTORE     = 0xF6;
const BALEN       = 0xF7;
const NEWCA       = 0xF8;
const CALOAD      = 0xF9;
const CASTORE     = 0xFA;
const CALEN       = 0xFB;
const TABLESWITCH = 0xFC;
const LOOKUPSWITCH= 0xFD;
const I2C         = 0xFE;
const I2S         = 0xFF;