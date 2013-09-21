// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/**
 * Module save and load
 * -
 * This part saves and loads modules into files.
 * No UI is included.
 */

use "dataio.eh"
use "list.eh"
use "string.eh"
use "error.eh"

use "module.eh"

const MODFILE_VERSION = "__MidiTrax_2__"

def Module.writepattern(f: OStream, i: Int) {
    var g = this.patterns[i].cast(Pattern)
    f.writeutf(g.name)
    f.writebyte(g.channels)
    f.writeint(g.steps)
    for (var step=0, step<g.steps, step+=1) {
        for (var channel=0, channel<g.channels, channel+=1) {
            for (var part=0, part<PAT_EFFECT2, part+=1) {
                f.writebyte(g.get(channel, step, part)) } } } }

def Module.loadpattern(f: IStream) {
    var g = new Pattern(f.readutf(), f.readubyte(), f.readint())
    for (var step=0, step<g.steps, step+=1) {
        for (var channel=0, channel<g.channels, channel+=1) {
            for (var part=0, part<PAT_EFFECT2, part+=1) {
                g.set(channel, step, part, f.readubyte()) } } }
    this.patterns.add(g) }

def Module.save(path: String) {
    var f = fopen_w(path)
    f.writeutf(MODFILE_VERSION)
    f.writeutf(this.title)
    f.writeutf(this.author)
    f.writeutf(this.composer)
    f.writeutf(this.comments)
    f.writebyte(this.channels)
    f.writeint(this.tempo)
    f.writeint(this.ticks)
    f.writeint(this.steps)
    // order
    f.writebyte(this.orderlist.len())
    for (var i=0, i<this.orderlist.len(), i+=1) f.writeshort(this.orderlist[i].cast(Int))
    // patterns
    f.writebyte(this.patterns.len())
    for (var i=0, i<this.patterns.len(), i+=1) this.writepattern(f, i)
    f.writeutf("EOF")
    f.close() }

def Module.load(path: String) {
    var f = fopen_r(path)
    var continue = f.readutf() == MODFILE_VERSION
    if (!continue) error(FAIL, "File is not a valid MidiTrax module")
    this.title = f.readutf()
    this.author = f.readutf()
    this.composer = f.readutf()
    this.comments = f.readutf()
    this.channels = f.readubyte()
    this.tempo = f.readint()
    this.ticks = f.readint()
    this.steps = f.readint()
    // order
    this.orderlist = new List()
    var orderlist_len = f.readubyte()
    for (var i=0, i<orderlist_len, i+=1) this.orderlist.add(f.readushort())
    // patterns
    this.patterns = new List()
    var pat_len = f.readubyte()
    for (var i=0, i<pat_len, i+=1) this.loadpattern(f)
    if (f.readutf() != "EOF") error(FAIL, "Module file is corrupted!")
    f.close() }