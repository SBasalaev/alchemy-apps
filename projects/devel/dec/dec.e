/* Ether decompiler.
 * Copyright (c) 2012-2013 Sergey Basalaev
 * Licensed under GPL-3
 */

use "eobj.eh"
use "opcodes.eh"
use "io.eh"

def main(args: [String]) {
  var in = fopen_r(args[0]);
  var obj = read_eobj(in);
  in.close();
  print("Ether object");
  println(", format version "+(obj.vmversion>>8)+"."+(obj.vmversion & 0xff));
  if ((obj.lflags & LFLAG_SONAME) != 0) {
    println("  SONAME = "+obj.soname);
  }
  if ((obj.lflags & LFLAG_DEPS) != 0) {
    for (var i=0, i < obj.libs.len, i+=1) {
      println("  NEEDED = "+obj.libs[i]);
    }
  }
  for (var idx=0, idx < obj.cpool.len, idx+=1) {
    var item = obj.cpool[idx]
    print("\n#"+idx+" ");
    switch (item.t) {
      T_INT:
        println("Int = "+item.value);
      T_LONG:
        println("Long = "+item.value);
      T_FLOAT:
        println("Float = "+item.value);
      T_DOUBLE:
        println("Double = "+item.value);
      T_STRING:
        println("String = "+item.value);
      T_UNRESOLVED: {
        var u = cast (Unresolved) item.value;
        println("Unresolved function = "+u.name);
      }
      T_EXTERNAL: {
        var e = cast (External) item.value;
        println("External function = "+obj.libs[e.libref]+":"+e.name);
      }
      T_FUNCTION: {
        var f = cast (EFunction) item.value;
        println(if ((f.flags & FFLAG_SHARED) != 0)
          "Public function = "+f.name
          else "Private function = "+f.name);
        println("  Stack size: "+f.stacksize);
        println("  Local vars: "+f.varcount);
        println("  Code:");
        var addr = 0;
        while (addr < f.code.len) {
          print("    "+addr+": ");
          switch (f.code[addr] & 0xff) {
            NOP: println("nop");
            ACONST_NULL:
              println("aconst_null");
            ICONST_M1:
              println("iconst_m1");
            ICONST_0:
              println("iconst_0");
            ICONST_1:
              println("iconst_1");
            ICONST_2:
              println("iconst_2");
            ICONST_3:
              println("iconst_3");
            ICONST_4:
              println("iconst_4");
            ICONST_5:
              println("iconst_5");
            LCONST_0:
              println("lconst_0");
            LCONST_1:
              println("lconst_1");
            FCONST_0:
              println("fconst_0");
            FCONST_1:
              println("fconst_1");
            FCONST_2:
              println("fconst_2");
            DCONST_0:
              println("dconst_0");
            DCONST_1:
              println("dconst_1");
            I2L:
              println("i2l");
            I2F:
              println("i2f");
            I2D:
              println("i2d");
            L2F:
              println("l2f");
            L2D:
              println("l2d");
            L2I:
              println("l2i");
            F2D:
              println("f2d");
            F2I:
              println("f2i");
            F2L:
              println("f2l");
            D2I:
              println("d2i");
            D2L:
              println("d2l");
            D2F:
              println("d2f");
            I2B:
              println("i2b");
            I2S:
              println("i2s");
            I2C:
              println("i2c");
            IADD:
              println("iadd");
            ISUB:
              println("isub");
            IMUL:
              println("imul");
            IDIV:
              println("idiv");
            IMOD:
              println("imod");
            INEG:
              println("ineg");
            ICMP:
              println("icmp");
            ISHL:
              println("ishl");
            ISHR:
              println("ishr");
            IUSHR:
              println("iushr");
            IAND:
              println("iand");
            IOR:
              println("ior");
            IXOR:
              println("ixor");
            LADD:
              println("ladd");
            LSUB:
              println("lsub");
            LMUL:
              println("lmul");
            LDIV:
              println("ldiv");
            LMOD:
              println("lmod");
            LNEG:
              println("lneg");
            LCMP:
              println("lcmp");
            LSHL:
              println("lshl");
            LSHR:
              println("lshr");
            LUSHR:
              println("lushr");
            LAND:
              println("land");
            LOR:
              println("lor");
            LXOR:
              println("lxor");
            FADD:
              println("fadd");
            FSUB:
              println("fsub");
            FMUL:
              println("fmul");
            FDIV:
              println("fdiv");
            FMOD:
              println("fmod");
            FNEG:
              println("fneg");
            FCMP:
              println("fcmp");
            DADD:
              println("dadd");
            DSUB:
              println("dsub");
            DMUL:
              println("dmul");
            DDIV:
              println("ddiv");
            DMOD:
              println("dmod");
            DNEG:
              println("dneg");
            DCMP:
              println("dcmp");
            LOAD_0:
              println("load_0");
            LOAD_1:
              println("load_1");
            LOAD_2:
              println("load_2");
            LOAD_3:
              println("load_3");
            LOAD_4:
              println("load_4");
            LOAD_5:
              println("load_5");
            LOAD_6:
              println("load_6");
            LOAD_7:
              println("load_7");
            STORE_0:
              println("store_0");
            STORE_1:
              println("store_1");
            STORE_2:
              println("store_2");
            STORE_3:
              println("store_3");
            STORE_4:
              println("store_4");
            STORE_5:
              println("store_5");
            STORE_6:
              println("store_6");
            STORE_7:
              println("store_7");
            IFEQ: {
              print("ifeq ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFNE: {
              print("ifne ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFLT: {
              print("iflt ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFGE: {
              print("ifge ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFGT: {
              print("ifgt ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFLE: {
              print("ifle ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            GOTO: {
              print("goto ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            JSR: {
              print("jsr ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            RET:
              println("ret");
            IFNULL: {
              print("ifnull ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IFNNULL: {
              print("ifnnull ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ICMPLT: {
              print("if_icmplt ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ICMPGE: {
              print("if_icmpge ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ICMPGT: {
              print("if_icmpgt ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ICMPLE: {
              print("if_icmple ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ACMPEQ: {
              print("if_acmpeq ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            IF_ACMPNE: {
              print("if_acmpne ");
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println(tmp);
            }
            CALL_0:
              println("call_0");
            CALL_1:
              println("call_1");
            CALL_2:
              println("call_2");
            CALL_3:
              println("call_3");
            CALL_4:
              println("call_4");
            CALL_5:
              println("call_5");
            CALL_6:
              println("call_6");
            CALL_7:
              println("call_7");
            CALL: {
              addr += 1
              println("call "+(f.code[addr] & 0xff));
            }
            CALV_0:
              println("calv_0");
            CALV_1:
              println("calv_1");
            CALV_2:
              println("calv_2");
            CALV_3:
              println("calv_3");
            CALV_4:
              println("calv_4");
            CALV_5:
              println("calv_5");
            CALV_6:
              println("calv_6");
            CALV_7:
              println("calv_7");
            CALV: {
              addr += 1
              println("calv "+(f.code[addr] & 0xff));
            }
            NEWAA:
              println("newaa");
            NEWBA:
              println("newba");
            NEWCA:
              println("newca");
            NEWSA:
              println("newsa");
            NEWZA:
              println("newza");
            NEWIA:
              println("newia");
            NEWLA:
              println("newla");
            NEWFA:
              println("newfa");
            NEWDA:
              println("newda");
            AALOAD:
              println("aaload");
            BALOAD:
              println("baload");
            CALOAD:
              println("caload");
            ZALOAD:
              println("zaload");
            SALOAD:
              println("saload");
            IALOAD:
              println("iaload");
            LALOAD:
              println("laload");
            FALOAD:
              println("faload");
            DALOAD:
              println("daload");
            AASTORE:
              println("aastore");
            BASTORE:
              println("bastore");
            CASTORE:
              println("castore");
            ZASTORE:
              println("zastore");
            SASTORE:
              println("sastore");
            IASTORE:
              println("iastore");
            LASTORE:
              println("lastore");
            FASTORE:
              println("fastore");
            DASTORE:
              println("dastore");
            AALEN:
              println("aalen");
            BALEN:
              println("balen");
            CALEN:
              println("calen");
            ZALEN:
              println("zalen");
            SALEN:
              println("salen");
            IALEN:
              println("ialen");
            LALEN:
              println("lalen");
            FALEN:
              println("falen");
            DALEN:
              println("dalen");
            ACMP:
              println("acmp");
            RET_NULL:
              println("ret_null");
            RETURN:
              println("return");
            DUP:
              println("dup");
            DUP2:
              println("dup2");
            SWAP:
              println("swap");
            LOAD: {
              addr += 1
              println("load "+(f.code[addr] & 0xff));
            }
            STORE: {
              addr += 1
              println("store "+(f.code[++addr] & 0xff));
            }
            LDC: {
              addr += 1
              var tmp = (f.code[addr] & 0xff) << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              print("ldc #" + tmp + "   //")
              var ld = obj.cpool[tmp]
              switch (ld.t) {
                T_UNRESOLVED:
                  println((cast(Unresolved)ld.value).name)
                T_EXTERNAL:
                  println((cast(External)ld.value).name)
                T_FUNCTION:
                  println((cast(EFunction)ld.value).name)
                else:
                  println(ld.value)
              }
            }
            BIPUSH: {
              addr+=1
              println("bipush "+f.code[addr]);
            }
            SIPUSH: {
              addr += 1
              var tmp = f.code[addr] << 8;
              addr += 1
              tmp |= f.code[addr] & 0xff;
              println("sipush "+tmp);
            }
            IINC: {
              addr += 1
              var index = f.code[addr] & 0xff;
              addr += 1
              var add = f.code[addr];
              println("iinc " + index + ", " + add)
            }
            POP:
              println("pop");
            TABLESWITCH: {
              addr += 1;
              var dflt = (f.code[addr] & 0xff) << 8;
              addr += 1;
              dflt |= f.code[addr] & 0xff;
              print("tableswitch from ");
              addr += 1;
              var min = (f.code[addr] & 0xff) << 24;
              addr += 1;
              min |= (f.code[addr] & 0xff) << 16;
              addr += 1;
              min |= (f.code[addr] & 0xff) << 8;
              addr += 1;
              min |= f.code[addr] & 0xff;
              print(min);
              print(" to ");
              addr += 1;
              var max = (f.code[addr] & 0xff) << 24;
              addr += 1;
              max |= (f.code[addr] & 0xff) << 16;
              addr += 1;
              max |= (f.code[addr] & 0xff) << 8;
              addr += 1;
              max |= f.code[addr] & 0xff;
              print(max);
              println(" {");
              for (var j=min, j<=max, j+=1) {
                print("        "+j+": ");
                addr += 1;
                var jump = (f.code[addr] & 0xff) <<8;
                addr += 1;
                jump |= f.code[addr] & 0xff;
                println(jump);
              }
              println("        else: "+dflt);
              println("    }");
            }
            LOOKUPSWITCH: {
              addr += 1;
              var dflt = (f.code[addr] & 0xff) << 8;
              addr += 1;
              dflt |= f.code[addr] & 0xff;
              println("lookupswitch {");
              addr += 1;
              var count = (f.code[addr] & 0xff) << 8;
              addr += 1;
              count |= f.code[addr] & 0xff;
              for (var j=0, j<count, j+=1) {
                addr += 1;
                var key = (f.code[addr] & 0xff) << 24;
                addr += 1;
                key |= (f.code[addr] & 0xff) << 16;
                addr += 1;
                key |= (f.code[addr] & 0xff) << 8;
                addr += 1;
                key |= f.code[addr] & 0xff;
                addr += 1;
                var jump = (f.code[addr] & 0xff) << 8;
                addr += 1;
                jump |= f.code[addr] & 0xff;
                println("        "+key+": "+jump);
              }
              println("        else: "+dflt);
              println("    }");
            }
            else:
              println("UNKNOWN OPCODE");
          }
          addr += 1;
        }
        if ((f.flags & FFLAG_RELOCS) != 0) {
          print("  Relocations:");
          for (var j=0, j < f.relocations.len, j+= 1) {
            print(" @"+f.relocations[j]);
          }
          write('\n');
        }
        if ((f.flags & FFLAG_LNUM) != 0) {
          println("  Source: "+obj.cpool[f.lnumtable[0]]);
          println("  Line number table:");
          for (var j=1, j<f.lnumtable.len, j += 2) {
            println("    line "+f.lnumtable[j]+": "+f.lnumtable[j+1]);
          }
        }
        if ((f.flags & FFLAG_ERRTBL) != 0) {
          println("  Error catching table:");
          for (var j=0, j<f.errtable.len, j += 4) {
            println("    from "+f.errtable[j]+" to "+f.errtable[j+1]+" catch "+f.errtable[j+2]+" head "+f.errtable[j+3]);
          }
        }
      }
      else:
        println("Unknown entry");
    }
  }
}