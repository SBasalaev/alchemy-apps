// libmidifile0 - MIDI 1.0 file reader & writer
// August 13 2013
// Kyle Alexander Buan

use "list.eh"
use "error.eh"
use "string.eh"
use "dataio.eh"

use "midifile.eh"

def to_any(array: [Byte]): [Any] {
    var any = new [Any](array.len)
    acopy(array, 0, any, 0, array.len)
    any }

def MidiTrack.encode_add(value: Int) {
    var data = new List()
    var c = true
    do {
        data.add((value & 0x7F).cast(Byte))
        value = value >> 7
        if (value == 0) c = false }
    while (c)
    var newdata = data.reverse().toarray()
    for (var i=0, i<(newdata.len-1), i+=1) newdata[i] = newdata[i].cast(Byte) | 0x80
    this.data.addall(newdata)
    this.length += newdata.len }

def MidiTrack.text_add(text: String) {
    this.encode_add(text.len())
    for (var i=0, i<text.len(), i+=1) {
        this.data.addall(to_any(text.utfbytes())) }
    this.length += text.len() }

def MidiTrack.new() {
    this.length = 0
    this.data = new List() }

def MidiTrack.note_off(delay: Int, channel: Byte, note: Byte, velocity: Byte) {
    this.encode_add(delay) // delta
    this.data.addall([0x80 | channel, note, velocity]) // event & args
    this.length += 3 }

def MidiTrack.note_on(delay: Int, channel: Byte, note: Byte, velocity: Byte) {
    this.encode_add(delay)
    this.data.addall([0x90 | channel, note, velocity])
    this.length += 3 }

def MidiTrack.key_aftertouch(delay: Int, channel: Byte, note: Byte, velocity: Byte) {
    this.encode_add(delay)
    this.data.addall([0xA0 | channel, note, velocity])
    this.length += 3 }

def MidiTrack.control_change(delay: Int, channel: Byte, control: Byte, value: Byte) {
    this.encode_add(delay)
    this.data.addall([0xB0 | channel, control, value])
    this.length += 3 }

def MidiTrack.patch_change(delay: Int, channel: Byte, patch: Byte) {
    this.encode_add(delay)
    this.data.addall([0xC0 | channel, patch])
    this.length += 2 }

def MidiTrack.channel_aftertouch(delay: Int, channel: Byte) {
    this.encode_add(delay)
    this.data.addall([0xD0 | channel, channel])
    this.length += 2 }

def MidiTrack.pitchwheel(delay: Int, channel: Byte, change: Int) {
    this.encode_add(delay)
    change += 0x2000
    this.data.addall([0xE0 | channel, change & 0x7F, (change & 0x3F80) >> 7])
    this.length += 3 }    

def MidiTrack.set_sequence(delay: Int, sequence: Short) {
    this.encode_add(delay)
    this.data.addall([0xFF, 0, 2, (sequence & 0xFF00) >> 8, sequence & 0xFF])
    this.length += 5 }

def MidiTrack.text(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 1])
    this.length += 2
    this.text_add(text) }

def MidiTrack.copyright(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 2])
    this.length += 2
    this.text_add(text) }

def MidiTrack.track_name(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 3])
    this.length += 2
    this.text_add(text) }

def MidiTrack.instrument_name(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 4])
    this.length += 2
    this.text_add(text) }

def MidiTrack.lyric(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 5])
    this.length += 2
    this.text_add(text) }

def MidiTrack.marker(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 6])
    this.length += 2
    this.text_add(text) }

def MidiTrack.cue_point(delay: Int, text: String) {
    this.encode_add(delay)
    this.data.addall([0xFF, 7])
    this.length += 2
    this.text_add(text) }

def MidiTrack.end_track(delay: Int) {
    this.encode_add(delay)
    this.data.addall([0xFF, 0x2F, 0])
    this.length += 3 }

def MidiTrack.set_tempo(delay: Int, microseconds: Int) {
    this.encode_add(delay)
    this.data.addall([0xFF, 0x51, 0x03, (microseconds & 0xFF0000) >> 16, (microseconds & 0x00FF00) >> 8, microseconds & 0x0000FF])
    this.length += 6 }

def MidiTrack.time_signature(delay: Int, numerator: Byte, denominator: Byte, ticks: Int) {
    this.encode_add(delay)
    var denom: Byte = 0
    var thirtysecond: Int = 0
    switch (denominator) {
        2: { denom = 1 thirtysecond = 16 }
        4: { denom = 2 thirtysecond = 8 }
        8: { denom = 3 thirtysecond = 4 }
        16: { denom = 4 thirtysecond = 2 }
        32: { denom = 5 thirtysecond = 1 }
        else: { error(ERR_ILL_ARG) } }
    this.data.addall([0xFF, 0x58, 0x04, numerator, denom, ticks, thirtysecond])
    this.length += 7 }

def MidiTrack.key_signature(delay: Int, count: Byte, flats: Bool, minor: Bool) {
    this.encode_add(delay)
    if (flats) count = -count
    this.data.addall([0xFF, 0x59, 0x02, count, if (minor) 1 else 0])
    this.length += 5 }

def MidiTrack.add_data(delay: Int, data: [Byte]) {
    this.encode_add(delay)
    this.encode_add(data.len)
    this.data.addall(to_any(data))
    this.length += data.len }

def MidiFile.new(format: Byte, ticks: Int) {
    this.format = format
    this.ticks = ticks
    this.tracks = new List() }

def MidiFile.add_track(t: MidiTrack) {
    this.tracks.add(t) } 

def MidiFile.save(path: String) {
    var f = fopen_w(path)
    f.writeint(0x4D546864) // "MThd"
    f.writeint(6) // header size
    f.writeshort(this.format)
    f.writeshort(this.tracks.len())
    f.writeshort(this.ticks)
    var t: MidiTrack = null
    for (var i=0, i<this.tracks.len(), i+=1) {
        t = this.tracks[i].cast(MidiTrack)
        f.writeint(0x4D54726B) // "MTrk"
        f.writeint(t.length)
        for (var j=0, j<t.length, j+=1) f.writebyte(t.data[j].cast(Byte)) }
    f.flush()
    f.close() }