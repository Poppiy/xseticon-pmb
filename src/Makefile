GLIB_CFLAGS=$(shell pkg-config --cflags glib-2.0)
  GLIB_LIBS=$(shell pkg-config --libs   glib-2.0)

XLIB_CFLAGS=-I /usr/X11R6/include

XLIB_LIBS=-L /usr/X11R6/lib -lX11

GD_LIBS=-lgd

LIBS=${GLIB_LIBS} ${XLIB_LIBS} ${GD_LIBS}

PREFIX  = /usr/local
BINDIR  = $(PREFIX)/bin
BINNAME = xseticon-pmb
MAINBFN = $(BINNAME)

define CLEANUP_FILES
    auto-generated/*.h
    ../bin/$(BINNAME)
    *.elf
    *.o
endef
CLEANUP_FILES_SPACED = $(strip $(shell \
    echo "$(CLEANUP_FILES)" | tr -s '\n ' ' '))


all: ../bin/$(BINNAME)

$(MAINBFN).o: $(MAINBFN).c
	# auto-generate include files:
	./usage.gen.sed ../README.md >auto-generated/usage.h
	# gcc: $@
	gcc ${GLIB_CFLAGS} ${XLIB_CFLAGS} -c $< -o $@
	# done: $@
	#

$(MAINBFN).debug.elf: $(MAINBFN).o
	# gcc: $@
	gcc $< ${LIBS} -o $@
	# done: $@
	#

../bin/$(BINNAME): $(MAINBFN).debug.elf
	mkdir --verbose --parents -- ../bin
	strip -o $@ -- $<
	du --bytes -- $< $@

.PHONY: clean
clean:
	chmod --changes u+w -- $(CLEANUP_FILES_SPACED) || true
	rm --verbose -- $(CLEANUP_FILES_SPACED) || true

.PHONY: install
install: ../bin/$(BINNAME)
	$(SUDO) install --directory -- "$(BINDIR)"
	$(SUDO) install --no-target-directory -- $< "$(BINDIR)/$(BINNAME)"










# scroll
