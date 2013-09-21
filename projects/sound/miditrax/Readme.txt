MidiTrax -- the MIDI tracker for Alchemy OS!

Started as a very ambitious software synthesizer tracker, MidiTrax is now a humble MIDI composer based on a tracker-style interface.

Why the name "MidiTrax"? Well, it is a "tracker" for MIDI, and MIDI files are arranged into chunks called "tracks" (identified in the file by the keyword "MTrk").

Why another MIDI composer? There's already MidEdit, sure. But since MidEdit is piano-roll based, and MidiTrax is tracker-based, MidiTrax can offer more control to your song. Right now, you have complete control on your song's channel volume, note trigger delay, note length, pitch offset, and tempo, most using the "tick" measure of time. REMEMBER: there are 96 ticks per beat.

Currently, there is no help system built into MidiTrax, so it is kind of important that I help users a bit when it comes to this.

In MidiTrax, a song is made up of "patterns". Let's say your song has this patterns:
0 - intro
1 - chorus
2 - ad lib
3 - closing
You arrange your song into "orders". For example, your order may be,
0 - 0 - intro
1 - 1 - chorus
2 - 2 - ad lib
3 - 1 - chorus
4 - 3 - closing

A pattern is made up of "channels". Each channel can play 1 sound at a time.
A channel is made up of "steps", where each step is 1/16 of a beat. In the default setting, each channel in a pattern has 4 beats.
A step is made up of 5 parts:

The note, if it contains data, plays a note. The instrument determines what kind of instrument is used to play the note. The volume, is obvious. Max is 127, min is 0. Playing a note with 0 volume is equivalent to a note OFF. The effect activates an effect, and the argument is the setting for that effect.

Playing note C3 with the piano at max volume is:
C3 0 127 -- --

Playing c3 then d3 with a piano, followed by g3 with a celesta at max volume is:
C3 0 127 -- --
D3 --- --- -- --
G3 9 --- -- --

Note that you don't have to specify repeated data :)

Now, the controls. You may enter notes using '1' (C) to '7' (B). You can lower or higher the octave with '8' and '9'. You can change a note to a sharp by using '#'. For example, pressing '#' on
C3 --- --- --
will give you
C#3 --- --- --

Clear notes and other data with '*'.
If a note is already cleared, and you press '*', it will put an 'OFF' note, which is like stopping the note.
If you press '#' outside of a note, you can choose the skip size of the cursors. Press For example, press '#' then '4' to skip 4 steps every scroll (default).

Here are the effects:
00 xx: set the channel's MIDI output channel to xx. Only use this for drums. REMEMBER: to make a channel output drums, set that channel to MIDI channel 9, as in 00 09. (max 15!)
1x xx: Detune a note down xxx units (max 199).
2x xx: Detune a note up xxx unites (max 199).
30 xx: Delay note xx ticks.
40 xx: Set delay after last note.
5x xx: Set tempo (beats per minute)
60 xx: Cut note after xx ticks
90 00: End pattern, and continue to next order.

Examples: (1 step is 6 ticks)
Detune a note 65 unites after 6 ticks, then stop note after 6 ticks.
C3 0 --- -- --
--- --- --- 10 60
OFF --- --- -- --

Play C3, then D3 after 7 ticks.
C3 0 --- -- --
D3 --- --- 30 01

Play C3 for 9 ticks
C3 0 --- 60 09

There are two ways to save music:
Saving an MTM file is important for continuing your work.
Saving a MIDI file is for making a playable song.
REMEMBER: MIDI files CANNOT BE EDITED (yet).

Okay. I think this is enough. It's possible that I forgot something, though. Feel free to ask me questions!

- Kyle 