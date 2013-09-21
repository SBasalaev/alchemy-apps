// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Pattern editor
 **/
 
use "ui.eh"
use "canvas.eh"
use "graphics.eh"
use "font.eh"
use "string.eh"
use "io.eh"
use "media.eh"

use "module.eh"
use "easy_menu.eh"
use "mod_renderer.eh"

//  [       C#3  0 100 01 30 -- --    ]

const KEY_UP:    Int = -1
const KEY_DOWN:  Int = -2
const KEY_LEFT:  Int = -3
const KEY_RIGHT: Int = -4

def step_is_drum(p: Pattern, c: Int, s: Int): Bool {
    var d = false
    s += 1
    for (var i=0, i<s, i+=1) {
        if (p.get(c, i, PAT_EFFECT1) == 0) {
            if (p.get(c, i, PAT_ARG1) == 9) d = true else d = false } }
    d }

def draw_step(d: Graphics, note: String, inst: String, vol: String, effect: String, arg: String, x: Int, y: Int, cw: Int, sw: Int, sh: Int) {
    if (y>30 && y<sh) {
        var d_note = x >= -(cw*3) && x < sw
        var d_inst = x+(cw*3) >= -(cw*3) && x < sw
        var d_vol = x+(cw*6) >= -(cw*3) && x < sw
        var d_effect = x+(cw*9) >= -(cw*3) && x < sw
        var d_arg = x+(cw*11) >= -(cw*3) && x < sw
        if (d_note) {
            d.color = 0x00FF00
            d.draw_string(note, x, y) }
        if (d_inst) {
            d.color = 0xFFFF00
            d.draw_string(inst, x+(cw*3), y) }
        if (d_vol) {
            d.color = 0x00AA00
            d.draw_string(vol, x+(cw*6), y) }
        d.color = 0xFF0000
        if (d_effect) {
            d.draw_string(effect, x+(cw*9), y) }
        if (d_arg) {
            d.draw_string(arg, x+(cw*11), y) } } }

def display_msg(d: Canvas, g: Graphics, msg: String, sh: Int, ch: Int) {
    g.color = 0
    g.fill_rect(0, sh-ch, 500, ch)
    g.color = 0x00FF00
    g.draw_string(msg, 0, sh-ch) }

def refresh_screen(d: Graphics, p: Pattern, part: Int, channel: Int, step: Int, cw: Int, ch: Int, sw: Int, sh: Int, octave: Byte) {
    var drums = false
    var center_x = (sw / 2) - cw
    var center_y = ((sh - 30) / 2 + 30) - (ch/2)
    var cur_x = center_x - (14*cw*channel)
    var cur_y = center_y - (ch*step)
    switch (part) {
        PAT_INSTRUMENT: cur_x -= cw * 3
        PAT_VOLUME: cur_x -= cw * 6
        PAT_EFFECT1: cur_x -= cw * 9
        PAT_ARG1: cur_x -= cw * 11 }
    var noteref = new NoteReference()
    d.color = 0
    d.fill_rect(0, 0, sw, sh-ch)
    var dat: [Byte] = new [Byte](5)
    var res: [String] = new [String](5)
    d.color = 0x0000FF
    d.fill_rect(center_x, center_y, if (part < PAT_EFFECT1) cw*3 else cw*2, ch)
    for (var chan=0, chan<p.channels, chan+=1) {
        if (cur_x+(cw*14*chan)+(cw*13) >= 0 && cur_x+(cw*14*chan) < sw) {
            drums = false
            for (var s=0, s<p.steps, s+=1) {
                if (cur_y+(s*ch) < (sh-ch) && cur_y+(s*ch) >= 30) {
                    if (s%16==0) {
                        d.color = 0x008800
                        d.fill_rect(cur_x+(cw*14*chan), cur_y+(s*ch), cw*13, ch) }
                    else if (s%4==0) {
                        d.color = 0x004400
                        d.fill_rect(cur_x+(cw*14*chan), cur_y+(s*ch), cw*13, ch) }
                    dat[0] = p.get(chan, s, PAT_NOTE)
                    dat[1] = p.get(chan, s, PAT_INSTRUMENT)
                    dat[2] = p.get(chan, s, PAT_VOLUME)
                    dat[3] = p.get(chan, s, PAT_EFFECT1)
                    dat[4] = p.get(chan, s, PAT_ARG1)
                    drums = step_is_drum(p, chan, s)
                    if (chan==channel && s==step) {
                        d.color = 0x0000FF
                        d.fill_rect(center_x, center_y, if (part<PAT_EFFECT1) cw*3 else cw*2, ch) }
                    if (dat[0] ==  -1) res[0] = "---"
                    else if (dat[0] == -56) {
                        res[0] = "OFF" }
                    else {
                        if (drums) {
                            res[0] = dat[0].tostr() }
                        else res[0] = noteref.tonote(dat[0]) }
                    if (dat[1] == -1) res[1] = "---" else res[1] = dat[1].tostr()
                    if (dat[2] == -1) res[2] = "---" else res[2] = dat[2].tostr()
                    if (dat[3] == -1) res[3] = "--" else res[3] = dat[3].tostr()
                    if (dat[4] == -1) res[4] = "--" else res[4] = dat[4].tostr()
                    draw_step(d, res[0], res[1], res[2], res[3], res[4], cur_x+(cw*14*chan), cur_y+(s*ch), cw, sw, sh) } } } }
    d.color = 0x00FF00
    d.draw_string("Oct " + octave.tostr(), 0, 0)
    d.draw_string("Drums " + step_is_drum(p, channel, step).tostr(), 0, ch)
    d.draw_string("Chan " + channel.tostr(), center_x, 0)
    d.draw_string("Step " + step.tostr(), center_x, ch) }

def Module.edit_pattern(i: Int): Bool {
    var changed = false
    var pat = this.patterns[i].cast(Pattern)
    var scroll_step = 4
    var dat = new [Byte](5)
    var drums = false
    var instruments = get_insts()
    var drum_names = get_drums()
    var player: Player
    var disp = new Canvas(true)
    disp.title = "Edit pattern"
    disp.add_menu(new Menu("Render pattern", 0))
    disp.add_menu(new Menu("Close", 1))
    ui_set_screen(disp)
    var dg = disp.graphics()
    dg.font = 8 // small
    var scr_width = disp.width
    var scr_height = disp.height
    var char_height = font_height(8)
    var char_width = 0
    for (var j=0, j<19, j+=1) {
        if (char_width < str_width(8, "CDEFGABC#0123456789"[j].tostr())) char_width = str_width(8, "CDEFGABC#0123456789"[j].tostr()) }
    var cursor_channel = 0
    var cursor_step = 0
    var cursor_part = 0
    var oct = 3
    var received_keypress: [Any]
    var continue = true
    do {
        refresh_screen(dg, this.patterns[i].cast(Pattern), cursor_part, cursor_channel, cursor_step, char_width, char_height, scr_width, scr_height, oct)
        dat[0] = pat.get(cursor_channel, cursor_step, PAT_NOTE)
        dat[1] = pat.get(cursor_channel, cursor_step, PAT_INSTRUMENT)
        dat[2] = pat.get(cursor_channel, cursor_step, PAT_VOLUME)
        dat[3] = pat.get(cursor_channel, cursor_step, PAT_EFFECT1)
        dat[4] = pat.get(cursor_channel, cursor_step, PAT_ARG1)
        if (cursor_part == PAT_NOTE && drums) {
            if (dat[0] > 27 && dat[0] < 88) {
                display_msg(disp, dg, "Drum = " + drum_names[pat.get(cursor_channel, cursor_step, PAT_NOTE)], scr_height, char_height) }
            else if (dat[0] != -1) {
                display_msg(disp, dg, "WARNING! INVALID DRUM", scr_height, char_height) } }
        else if (cursor_part == PAT_INSTRUMENT && dat[1] >= 0) display_msg(disp, dg, "Inst = "+instruments[dat[1]], scr_height, char_height)
        else if (cursor_part == PAT_EFFECT1 && dat[3] >= 0) {
            if (dat[3] == 0) display_msg(disp, dg, "Set channel's MIDI channel", scr_height, char_height)
            else if (dat[3] >= 10 && dat[3] < 12) display_msg(disp, dg, "Detune down", scr_height, char_height)
            else if (dat[3] >= 20 && dat[3] < 22) display_msg(disp, dg, "Detune up", scr_height, char_height)
            else if (dat[3] == 30) display_msg(disp, dg, "Delay ticks", scr_height, char_height)
            else if (dat[3] == 40) display_msg(disp, dg, "Step ticks difference", scr_height, char_height)
            else if (dat[3] >= 50 && dat[3] < 60) display_msg(disp, dg, "Set tempo", scr_height, char_height)
            else if (dat[3] == 60) display_msg(disp, dg, "Cut note after", scr_height, char_height)
            else display_msg(disp, dg, "", scr_height, char_height) }
        else display_msg(disp, dg, "", scr_height, char_height) 
        disp.refresh()
        received_keypress = wait_menu_or_press()
        if (received_keypress[0].cast(Int) == 1) {
            switch (received_keypress[1].cast(Int)) {
                KEY_UP: {
                    cursor_step -= scroll_step
                    if (cursor_step < 0) cursor_step = 0
                    drums = step_is_drum(pat, cursor_channel, cursor_step) }
                KEY_DOWN: {
                    for (var k=0, k<scroll_step && cursor_step < (pat.steps-1), k+=1) {
                        cursor_step += 1
                        if (pat.get(cursor_channel, cursor_step, PAT_EFFECT1) == 0) {
                            if (pat.get(cursor_channel, cursor_step, PAT_ARG1) == 9) drums = true else drums = false } } }
                KEY_LEFT: {
                    if (cursor_part == 0) {
                        if (cursor_channel > 0) {
                            cursor_channel -= 1
                            cursor_part = PAT_ARG1 } }
                    else {
                        cursor_part -= 1 } }
                KEY_RIGHT: {
                    if (cursor_part == PAT_ARG1) {
                        if (cursor_channel < (this.channels - 1)) {
                            cursor_channel += 1
                            cursor_part = 0 } }
                    else {
                        cursor_part += 1 } }
                KEY_1: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+1 < 27 || (dat[0]*10)%100+1 > 87) {
                                dat[0] = 1 }
                            else pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+1) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 1 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 1) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+1) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 1) } }
                KEY_2: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+2 < 27 || (dat[0]*10)%100+2 > 87) {
                                dat[0] = 2 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+2) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+2) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 2 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 2) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+2) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 2) } }
                KEY_3: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+3 < 27 || (dat[0]*10)%100+3 > 87) {
                                dat[0] = 3 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+3) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+4) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 3 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 3) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+3) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 3) } }
                KEY_4: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+4 < 27 || (dat[0]*10)%100+4 > 87) {
                                dat[0] = 4 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+4) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+5) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 4 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 4) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+4) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 4) } }
                KEY_5: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+5 < 27 || (dat[0]*10)%100+5 > 87) {
                                dat[0] = 5 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+5) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+7) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 5 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 5) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+5) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 5) } }
                KEY_6: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+6 < 27 || (dat[0]*10)%100+6 > 87) {
                                dat[0] = 6 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+6) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+9) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 6 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 6) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+6) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 6) } }
                KEY_7: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+7 < 27 || (dat[0]*10)%100+7 > 87) {
                                dat[0] = 7 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+7) }
                        else pat.set(cursor_channel, cursor_step, PAT_NOTE, (oct)*12+11) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_channel] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 7 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 7) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+7) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 7) } }
                KEY_8: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+8 < 27 || (dat[0]*10)%100+8 > 87) {
                                dat[0] = 8 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+8) }
                        else if (oct > 0) oct -= 1 }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 8 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 8) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+8) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 8) } }
                KEY_9: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        if (drums) {
                            if ((dat[0]*10)%100+9 < 27 || (dat[0]*10)%100+9 > 87) {
                                dat[0] = 9 }
                            pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)+9) }
                        else if (oct < 7) oct += 1 }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 + 9 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 9) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10+9) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100 + 9) } }
                KEY_0: {
                    changed = true
                    if (cursor_part == PAT_NOTE && drums) {
                        if ((dat[0]*10)%100 < 27 || (dat[0]*10)%100 > 87) {
                            dat[0] = 0 }
                        pat.set(cursor_channel, cursor_step, PAT_NOTE, ((dat[0] * 10)%100)) }
                    else {
                        if (dat[cursor_part] == -1) {
                            dat[cursor_part] = 0 }
                        if (cursor_part < PAT_EFFECT1) {
                            if (dat[cursor_part] * 10 > 127) pat.set(cursor_channel, cursor_step, cursor_part, 0) else pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part]*10) }
                        else pat.set(cursor_channel, cursor_step, cursor_part, (dat[cursor_part] * 10) % 100) } }
                KEY_STAR: {
                    changed = true
                    if (dat[cursor_part] == -1 && cursor_part == PAT_NOTE) {
                        pat.set(cursor_channel, cursor_step, cursor_part, 200) }
                    else {
                        pat.set(cursor_channel, cursor_step, cursor_part, -1) } }
                KEY_HASH: {
                    changed = true
                    if (cursor_part == PAT_NOTE) {
                        pat.set(cursor_channel, cursor_step, cursor_part, dat[cursor_part] + 1) }
                    else {
                        display_msg(disp, dg, "Step size [1-9]:", scr_height, char_height)
                        disp.refresh()
                        received_keypress = wait_menu_or_press()
                        if (received_keypress[0].cast(Int) == 1) {
                            try {
                                scroll_step = ba2utf([received_keypress[1].cast(Byte)]).toint() }
                            catch { } }
                        display_msg(disp, dg, "Step size = " + scroll_step.tostr(), scr_height, char_height)
                        disp.refresh() } } } }
        else {
            if (received_keypress[1].cast(String) == "Render pattern") {
                this.render(0, this.orderlist.len(), "/tmp/render.mid")
                player = new Player(fopen_r("/tmp/render.mid"), "audio/midi")
                player.start() }
            else if (received_keypress[1].cast(String) == "Close") {
                continue = false 
                if (player != null) {
                    player.stop()
                    player.close() } } } }
    while (continue)
    changed }