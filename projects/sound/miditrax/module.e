// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Module functions
 **/

use "module.eh"

def get_insts(): [String] {
    ["Acoustic grand", "Bright acoustic", "Electric grand", "Honky-tonk", "Electric piano 1", "Electric piano 2", "Harpsichord", "Clav", "Celesta", "Glockenspiel", "Music box", "Vibraphone", "Marimba", "Xylophone", "Tubular bells", "Dulcimer", "Drawbar organ", "Percussive organ", "Rock organ", "Church organ", "Reed organ", "Accordian", "Harmonica", "Tango accordian", "Acoustic guitar (nylon)", "Acoustic guitar (steel)", "Electric guitar (jazz)", "Electric guitar (clean)", "Electric guitar (muted)", "Overdriven guitar", "Distortion guitar", "Guitar harmonics", "Acoustic bass", "Electric bass (finger)", "Electric bass (pick)", "Fretless bass", "Slap bass 1", "Slap bass 2", "Synth bass 1", "Synth bass 2", "Violin", "Viola",
    "Cello", "Contrabass", "Tremolo strings", "Pizzicato strings", "Orchestral strings", "Timpani", "String ensemble 1", "String ensemble 2", "Synth strings 1", "Synth strings 2", "Choir 'aaah'", "Voice 'oooh'", "Synth voice", "Orchestra hit", "Trumpet", "Trombone", "Tuba",
     "Muted trumpet", "French horn", "Brass section", "Synth brass 1", "Synth brass 2",
     "Soprano sax", "Alto sax", "Tenor sax", "Baritone sax", "Oboe", "English horn", "Bassoon", "Clarinet",
     "Piccolo", "Flute", "Recorder", "Pan flute", "Blown bottle", "Shakuhachi", "Whistle", "Ocarina",
    "Square", "Sawtooth", "Calliope", "Chiff", "Charang", "Voice", "Fifths", "Bass+lead",
    "New age", "Warm", "Polysynth", "Choir", "Bowed", "Metallic", "Halo", "Sweep",
    "Rain", "Soundtrack", "Crystal", "Atmosphere", "Brightness", "Goblins", "Echoes", "Sci-fi",
    "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai",
    "Tinkle bell", "Agogo", "Steel drums", "Woodblock", "Taiko drum", "Melodic tom", "Synth drum", "Reverse cymbal",
    "Guitar fret noise", "Breath noise", "Seashore", "Bird tweet", "Telephone ring", "Helicopter", "Applause", "Gunshot"] }

def get_drums(): [String] {
    ["e", "e", "e", "e", "e", "e", "e", "e", "e", "e",
    "e", "e", "e", "e", "e", "e", "e", "e", "e", "e",
    "e", "e", "e", "e", "e", "e", "e", "HighQ", "Slap", "Scratch push",
    "Scratch pull", "Sticks", "Square click", "Metronome click", "Metronome bell", "Acoustic bass drum", "Bass drum 1", "Side stick", "Acoustic snare", "Hand clap",
    "Electric snare", "Low floor tom", "Closed hi-hat", "High floor tom", "Pedal hi-hat", "Low tom", "Open hi-hat", "Low-mid tom", "Hi-mid tom", "Crash cymbal 1",
    "Hi tom", "Ride cymbal 1", "Chinese cymbal", "Ride bell", "Tambourine", "Splash cymbal", "Cow bell", "Crash cymbal 2", "Vibraslap", "Ride cymbal 2",
    "Hi bongo", "Low bongo", "Mute hi conga", "Open hi conga", "Low conga", "High timbale", "Low timbale", "High agogo", "Low agogo", "Cabasa",
    "Maracas", "Short whistle", "Long whistle", "Short guiro", "Long guiro", "Claves", "Hi wood block", "Low wood block", "Mute cuica", "Open cuica",
    "Mute triangle", "Open triangle", "Shaker", "Jingle bells", "Belltree", "Castanets", "Mute surdo", "Open surdo"] }

def NoteReference.new() {
    // converts MIDI note codes to human-readable notation
    this.midi2word = new [String](128)
    var notearray = ["C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "]
    var octavecounter = 0
    var codecounter = 0
    for (codecounter = 0, codecounter < 128, codecounter+=1) {
        this.midi2word[codecounter] = notearray[codecounter%12] + octavecounter.tostr()
        if (codecounter%12 == 11) {
            octavecounter += 1 } } }

def NoteReference.tonote(i: Byte): String {
    if (i != -1) {
       this.midi2word[i] }
    else {
        "---" } }
    
def Pattern.new(name: String, channels: Byte, steplen: Int = 64) {
    this.name = name
    var s = 7 * channels * steplen
    this.data = new [Byte](s)
    for (var i = 0, i<s, i+=1) this.data[i] = -1
    this.channels = channels
    this.steps = steplen }
    
/*  
    [n1, i1, 0, 0, 0, 0, 0, n2, i2, 0, 0, 0, 0, 0, n3, i3, 0, 0, 0, 0, 0, n4, i4,...
    ---------------------------step 1-----------------------------------  ------------------------step 2 --------------------
    -----------chan 1----  --------chan 2--------  -------chan 3--------  ----------chan 1-------    
*/

def Pattern.set(channel: Int, step: Int, part: Int, val: Byte) {
    // part = X, channel = Y, step = Z
    this.data[part + (channel*7) + (step*7*this.channels)] = val }

def Pattern.get(channel: Int, step: Int, part: Int): Byte {
    // part = X, channel = Y, step = Z
    this.data[part + (channel*7) + (step*7*this.channels)] }
    
def Module.new() {
    this.title = "New"
    this.author = ""
    this.composer = ""
    this.tempo = 0
    this.ticks = 0
    this.orderlist = new List()
    this.patterns = new List() }