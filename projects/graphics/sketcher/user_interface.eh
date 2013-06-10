/*
 * SKETCHER
 * User interface header
 */

use "dcm.eh"

def show_new_image(): DCMImage;
def show_edit_layers(image: DCMImage);
def show_save_image(image: DCMImage);
def show_shape_selector(current: Int): Int;