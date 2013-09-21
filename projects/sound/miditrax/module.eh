// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Module definitions
  * OrderList - [0, 1, ...] numbers that points to Patterns
  *               |
  *              Patterns - [pat0, pat1, ...] contains Patterns
  * A step is [Byte] { note, instrument, volume, effect1, arg1, effect2, arg2 }
 **/
 
use "list.eh"

def get_insts(): [String];
def get_drums(): [String];

type NoteReference {
    midi2word: [String] = null }

def NoteReference.new();
def NoteReference.tonote(i: Byte): String;

// Pattern setter constants
const PAT_NOTE: Byte       = 0
const PAT_INSTRUMENT: Byte = 1
const PAT_VOLUME: Byte     = 2
const PAT_EFFECT1: Byte    = 3
const PAT_ARG1: Byte       = 4
const PAT_EFFECT2: Byte    = 5
const PAT_ARG2: Byte       = 6    

type Pattern {
    name: String = null,
    data:     [Byte] = null,
    channels: Byte   = 0,
    steps:    Int    = 0 }

def Pattern.new(name: String, channels: Byte, steplen: Int = 64);
def Pattern.set(channel: Int, step: Int, part: Int, val: Byte);
def Pattern.get(channel: Int, step: Int, part: Int): Byte;
 
type Module {
    title:       String = "",
    author:      String = "",
    composer:    String = "",
    comments:    String = "",
    channels:    Byte   = 0,
    tempo: Int = 0,
    ticks:       Int   = 0,
    steps:       Int    = 0,
    orderlist:   List   = null,
    patterns:    List   = null }

def Module.new();