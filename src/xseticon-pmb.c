resudents nz pensions
/*
 * Copyright (C) 2012, Paul Evans <leonerd@leonerd.org.uk>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <gd.h>

// usage.h is generated by usage.gen.sed from README.md
#include "auto-generated/usage.h"

typedef unsigned long int x11uint;
/* ^-- XChangeProperty expects a buffer of native unsigned longs ALWAYS,
  despite the fact that we tell it to load 32-bit (bits_per_pixel) data.
  Our choice of format seems to only specify how the image shall be
  stored in the X server, and has nothing to do with the input format.
*/

typedef gdImagePtr (*image_reader_fun_ptr)(FILE*);

const guchar bits_per_pixel = 32; // RGBA = 4 channels × 8 bits

gboolean verbose = FALSE;


void usage(int exitcode) {
  printf(README_USAGE);
  exit(exitcode);
}


// FROM programs/xlsfonts/dsimple.c
    // (This part is intentionally omitted in the PmB version.)
// END FROM


void failed(gchar* msg, ...) {
  va_list details;
  va_start(details, msg);
  fprintf(stderr, "E: Failed to %s", msg);
  vfprintf(stderr, " %s", details);
  fprintf(stderr, "\n");
  va_end(details);
  exit(1);
}


image_reader_fun_ptr decide_image_reader(gchar* type, gchar* path) {
  if (!strcmp(type, "GUESS")) {
    int fext_offset = strlen(path) - 4;
    if (fext_offset < 0) { failed("find filename extension in path", path); }
    gchar* fext = path + fext_offset;
    if ((*fext) != '.') { failed("find filename extension in path", path); }
    fext += 1;
    return decide_image_reader(fext, path);
  }
  if (!strcmp(type, "png")) { return &gdImageCreateFromPng; }
  failed("load image: Unsupported image type:", type);
  return NULL; // Won't ever be reached. Just to mute the warning.
}


void dump_hex(const guchar* bytes, const guchar offset, const guchar length) {
  guchar end = offset + length;
  guchar pos;
  for(pos = offset; pos < end; pos++) {
    printf(" %02X", bytes[pos]);
  }
}


void load_icon(gchar* img_type, gchar* img_path,
  x11uint* ndata, x11uint** data
) {
  image_reader_fun_ptr reader = decide_image_reader(img_type, img_path);

  FILE* iconfile = fopen(img_path, "r");
  if (!iconfile) { failed("open file for reading:", img_path); }

  gdImagePtr icon = (*reader)(iconfile);
  fclose(iconfile);
  if (!icon) { failed("parse data from icon file", img_path); }

  int width = gdImageSX(icon);
  int height = gdImageSY(icon);
  if (verbose) {
    printf("D: Icon dimensions: %d x %d pixels.\n", width, height);
  }

  (*ndata) = (width * height) + 2;
  (*data) = g_new0(x11uint, (*ndata));

  int i = 0;
  (*data)[i++] = width;
  (*data)[i++] = height;

  int x, y;
  for(y = 0; y < height; y++) {
    for(x = 0; x < width; x++) {
      // data is RGBA
      // We'll do some horrible data-munging here
      guint8* cols = (guint8*)&((*data)[i++]);

      int pixcolour = gdImageGetPixel(icon, x, y);

      cols[0] = gdImageBlue(icon, pixcolour);
      cols[1] = gdImageGreen(icon, pixcolour);
      cols[2] = gdImageRed(icon, pixcolour);

      /* Alpha is more difficult */
      int alpha = 127 - gdImageAlpha(icon, pixcolour); // 0 to 127

      // Scale it up to 0 to 255; remembering that 2*127 should be max
      if (alpha == 127)
        alpha = 255;
      else
        alpha *= 2;

      cols[3] = alpha;
    }
  }

  gdImageDestroy(icon);
}


gboolean str2ulong(gchar* s, unsigned long* u) {
  if (sscanf(s, "0x%lx", u)) { return TRUE; }
  if (sscanf(s, "%ld", u)) { return TRUE; }
  return FALSE;
}


int main(int argc, char* argv[]) {
  if (argc < 3) { usage(1); }
  if (!strcmp(argv[1], "-h")) { usage(0); }
  if (!strcmp(argv[1], "--help")) { usage(0); }

  guint argindex = 1;
  if (!strcmp(argv[argindex], "--verbose")) {
    verbose = TRUE;
    argindex++;
  }

  unsigned long tmpLong = 0;
  if (!str2ulong(argv[argindex], &tmpLong)) { failed("parse window ID"); }
  if (tmpLong < 1) { failed("invalid window ID, must be positive"); }
  Window window = tmpLong;
  if (verbose) { printf("D: Using window ID 0x%08lx\n", window); }
  argindex++;

  gchar* imType = argv[argindex];
  argindex++;
  gchar* imPath = argv[argindex];
  if (verbose) { printf("Loading %s image from file %s\n", imType, imPath); }
  x11uint nelements;
  x11uint* icondata;
  load_icon(imType, imPath, &nelements, &icondata);

  Display* display = XOpenDisplay(NULL); // NULL = use $DISPLAY env var
  XSynchronize(display, TRUE);
  if (!display) { failed("XOpenDisplay"); }
  Atom iconpropId = XInternAtom(display, "_NET_WM_ICON", 0);
  const Atom iconpropAtomType = XA_CARDINAL;
  if (!iconpropId) { failed("find XInternAtom _NET_WM_ICON"); }

  int result = XChangeProperty(display, window, iconpropId, iconpropAtomType,
    bits_per_pixel, PropModeReplace, (void*)icondata, nelements);

  if(!result) { failed("XChangeProperty"); }
  if(!XFlush(display)) { failed("XFlush"); }
  XSynchronize(display, FALSE);
  XCloseDisplay(display);
  return 0;
}
