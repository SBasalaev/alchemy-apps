// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Module renderer
 **/

/* EFFECTS LIST
   00 nn Change module's channel to output to MIDI's nn channel (nn < 16)
   1n nn Detune note down nnn0 places
   2n nn Detune note up nnn0 places
   30 nn Delay note nn ticks (96 ticks per quarter note)
   40 nn Step ticks difference (96 ticks per quarter note)
   5n nn Set tempo (bpm)
   60 nn Cut note after nn ticks
   90 xx End pattern and continue to next order if any
  */

use "module.eh"

use "canvas.eh"
use "ui.eh"
use "midifile.eh"

const RENDERER = "MidiTracker v0.9 for Alchemy OS"

def Module.render(start: Int, end: Int, path: String, metadata: Bool = false) {
    var ticks_per_step = 96 / 16
    var midi_file = new MidiFile(1, 96)
    if (metadata) {
        var data_track = new MidiTrack()
        data_track.text(0, "Sequenced by "+RENDERER)
        data_track.copyright(0, this.composer)
        data_track.track_name(0, this.title + " by " + this.author)
        midi_file.add_track(data_track) }
    var midi_tracks = new [MidiTrack](this.channels)
    var active_notes = new [Int](this.channels)
    var last_note = new [Byte](this.channels)
    var tick_counter = new [Int](this.channels)
    var channel_volume = new [Byte](this.channels)
    var mc_of_c = new [Byte](this.channels)
    for (var i=0, i<this.channels, i+=1) {
        midi_tracks[i] = new MidiTrack()
        midi_tracks[i].set_tempo(0, 1000000/(this.tempo/60F))
        mc_of_c[i] = i
        active_notes[i] = 0
        tick_counter[i] = ticks_per_step*16
        channel_volume[i] = 127 }
    var p: Pattern
    var note: Byte
    var inst: Byte
    var vol: Byte
    var eff: Byte
    var arg: Byte
    for (var o=start, o<end, o+=1) {
        p = this.patterns[this.orderlist[o].cast(Int)].cast(Pattern)
        for (var s=0, s<this.steps, s+=1) {
            for (var c=0, c<this.channels, c+=1) {
                note = p.get(c, s, PAT_NOTE)
                inst = p.get(c, s, PAT_INSTRUMENT)
                vol = p.get(c, s, PAT_VOLUME)
                eff = p.get(c, s, PAT_EFFECT1)
                if (eff>=0) arg = p.get(c, s, PAT_ARG1)
                if (eff == 40) tick_counter[c] = arg
                if (note >= 0 && active_notes[c] > 0) {
                    midi_tracks[c].note_off(tick_counter[c], mc_of_c[c], last_note[c], 0)
                    tick_counter[c] = 0
                    active_notes[c] -= 1 }
                if (eff>=0) {
                    if (eff == 0) { mc_of_c[c] = arg }
                    else if (eff >= 10 && eff < 12) {
                        midi_tracks[c].pitchwheel(tick_counter[c], mc_of_c[c], (arg.cast(Int) * (-10)) - ((eff % 10)*1000))
                        tick_counter[c] = 0 }
                    else if (eff >= 20 && eff < 22) {
                        midi_tracks[c].pitchwheel(tick_counter[c], mc_of_c[c], (arg.cast(Int) * (10)) + ((eff % 10)*1000))
                        tick_counter[c] = 0 }
                    else if (eff == 30) tick_counter[c] += arg
                    else if (eff == 50) {
                        midi_tracks[c].set_tempo(tick_counter[c], 1000000/(((eff % 10)*100 + arg) / 60F))
                        tick_counter[c] = 0 }
                    else if (eff == 90) s = this.steps - 1 }
                if (inst >= 0) {
                    midi_tracks[c].patch_change(tick_counter[c], mc_of_c[c], inst)
                    tick_counter[c] = 0 }
                if (vol >= 0) {
                    if (active_notes[c] > 0) {
                        midi_tracks[c].control_change(tick_counter[c], mc_of_c[c], 7, vol)
                        tick_counter[c] = 0 }
                    else {
                        channel_volume[c] = vol } }
                if (note != -1) {
                    if (note == -56) {
                        midi_tracks[c].note_off(tick_counter[c], mc_of_c[c], last_note[c], 0)
                        tick_counter[c] = 0
                        active_notes[c] -= 1 }
                    else {
                        midi_tracks[c].note_on(tick_counter[c], mc_of_c[c], note, channel_volume[c])
                        last_note[c] = note
                        if (eff == 60) {
                            midi_tracks[c].note_off(arg, mc_of_c[c], note, 0)
                            tick_counter[c] = -(arg.cast(Int)) }
                        else {
                            tick_counter[c] = 0
                            active_notes[c] += 1 } } } }
            for (var i=0, i<this.channels, i+=1) {
                tick_counter[i] += ticks_per_step } } }
    for (var i=0, i<this.channels, i+=1) {
        if (active_notes[i] > 0) midi_tracks[i].note_off(ticks_per_step*64, mc_of_c[i], last_note[i], 0)
        midi_tracks[i].end_track(0)
        midi_file.add_track(midi_tracks[i]) }
    midi_file.save(path) }