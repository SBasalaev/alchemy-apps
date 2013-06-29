// libraw2wav
// RAW to WAV converter library

use "io"
use "dataio"

def OStream.writebytes(i: Long, b: Byte) {
    while (b>0) {
        this.writebyte(i & 0xFF)
        b -= 1
        i = i >> 8 } }

def raw2wav(in: String, out: String, channels: Byte, samplerate: Int, bitdepth: Int) {
    var datasize = fsize(in)
    var filesize = datasize + 36 // this may be wrong...
    var inf = fopen_r(in)
    var outf = fopen_w(out)
    outf.writebytes(0x46464952L, 4) // "RIFF"
    outf.writebytes(filesize, 4)
    outf.writebytes(0x45564157L, 4) // "WAVE"
    outf.writebytes(0x20746D66L, 4) // "fmt "
    outf.writebytes(16, 4) // header above size
    outf.writebytes(1, 2) // data type (PCM)
    outf.writebytes(channels, 2)
    outf.writebytes(samplerate, 4)
    outf.writebytes((samplerate*bitdepth*channels)/8, 4)
    outf.writebytes((bitdepth*channels)/8, 2)
    outf.writebytes(bitdepth, 2)
    outf.writebytes(0x61746164L, 4) // "data"
    outf.writebytes(datasize, 4)
    var d: Byte = 0
    var c = true
    while (c) {
        try {
            outf.writebyte(inf.readubyte()) }
        catch {
            c = false } }
    outf.close()
    inf.close() }