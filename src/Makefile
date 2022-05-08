GLIB_CFLAGS=$(shell pkg-config --cflags glib-2.0)
  GLIB_LIBS=$(shell pkg-config --libs   glib-2.0)

XLIB_CFLAGS=-I /usr/X11R6/include

XLIB_LIBS=-L /usr/X11R6/lib -lX11

GD_LIBS=-lgd

LIBS=${GLIB_LIBS} ${XLIB_LIBS} ${GD_LIBS}

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
BINNAME=xseticon-pmb
MAINBFN=xseticon-pmb

all: $(MAINBFN).elf

$(MAINBFN).o: $(MAINBFN).c
	# auto-generate include files:
	./usage.gen.sed ../README.md >auto-generated/usage.h
	# gcc: $@
	gcc ${GLIB_CFLAGS} ${XLIB_CFLAGS} -c $^ -o $@
	# done: $@
	#

$(MAINBFN).elf: $(MAINBFN).o
	# gcc: $@
	gcc $^ ${LIBS} -o $@
	# done: $@
	#

.PHONY: clean
clean:
	rm --verbose -- auto-generated/*.h *.elf  *.o || true

.PHONY: install
install: $(MAINBFN).elf
	install --directory -- "$(BINDIR)"
	install --no-target-directory -- $(MAINBFN).elf "$(BINDIR)/$(BINNAME)"
