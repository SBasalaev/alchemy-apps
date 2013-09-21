// libmidifile0 - MIDI 1.0 file reader & writer
// August 13 2013
// Kyle Alexander Buan

use "list.eh"

type MidiTrack {
    data: List,
    length: Int }

def MidiTrack.new();
def MidiTrack.note_off(delay: Int, channel: Byte, note: Byte, velocity: Byte);
def MidiTrack.note_on(delay: Int, channel: Byte, note: Byte, velocity: Byte);
def MidiTrack.key_aftertouch(delay: Int, channel: Byte, note: Byte, velocity: Byte);
def MidiTrack.control_change(delay: Int, channel: Byte, control: Byte, value: Byte);
def MidiTrack.patch_change(delay: Int, channel: Byte, patch: Byte);
def MidiTrack.channel_aftertouch(delay: Int, channel: Byte);
def MidiTrack.pitchwheel(delay: Int, channel: Byte, change: Int);
def MidiTrack.set_sequence(delay: Int, sequence: Short);
def MidiTrack.text(delay: Int, text: String);
def MidiTrack.copyright(delay: Int, text: String);
def MidiTrack.track_name(delay: Int, text: String);
def MidiTrack.instrument_name(delay: Int, text: String);
def MidiTrack.lyric(delay: Int, text: String);
def MidiTrack.marker(delay: Int, text: String);
def MidiTrack.cue_point(delay: Int, text: String);
def MidiTrack.end_track(delay: Int);
def MidiTrack.set_tempo(delay: Int, microseconds: Int);
def MidiTrack.time_signature(delay: Int, numerator: Byte, denominator: Byte, ticks: Int);
def MidiTrack.key_signature(delay: Int, count: Byte, flats: Bool, minor: Bool);
def MidiTrack.add_data(delay: Int, data: [Byte]);

type MidiFile {
    format: Byte,
    ticks: Int,
    tracks: List }

def MidiFile.new(format: Byte, ticks: Int);
def MidiFile.add_track(t: MidiTrack);
def MidiFile.save(path: String);