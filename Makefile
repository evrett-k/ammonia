CC := clang
CFLAGS := -Wall -O2
OBJCFLAGS := $(CFLAGS) -fobjc-arc -ObjC
ARCHS := -arch x86_64 -arch arm64e
INCLUDES := -I.
LIBFRIDA := libfrida-gum-x86_64-arm64e-arm64.a

AMMONIA_SOURCES := ammonia/main.m
LIBINFECT_SOURCES := libinfect/libinfect.m libinfect/envbuf.c
OPENER_SOURCES := $(wildcard opener/*.m)

AMMONIA_OBJS := $(AMMONIA_SOURCES:.m=.o)
LIBINFECT_OBJS := $(patsubst %.m,%.o,$(filter %.m,$(LIBINFECT_SOURCES))) $(patsubst %.c,%.o,$(filter %.c,$(LIBINFECT_SOURCES)))
OPENER_OBJS := $(patsubst %.m,%.o,$(OPENER_SOURCES))

FRAMEWORKS := -framework Cocoa -framework CoreFoundation -framework Foundation

all: ammonia libinfect.dylib opener.dylib

ammonia: $(AMMONIA_OBJS)
	$(CC) $(ARCHS) $(OBJCFLAGS) $(INCLUDES) -o $@ $^ $(FRAMEWORKS)

libinfect.dylib: $(LIBINFECT_OBJS)
	$(CC) $(ARCHS) -dynamiclib -o $@ $^ $(LIBFRIDA) $(FRAMEWORKS)

opener.dylib: $(OPENER_OBJS)
	$(CC) $(ARCHS) -dynamiclib -o $@ $^ $(LIBFRIDA) -framework Foundation -framework Security

# Pattern rules
%.o: %.m
	$(CC) $(ARCHS) $(OBJCFLAGS) $(INCLUDES) -c $< -o $@

%.o: %.c
	$(CC) $(ARCHS) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(AMMONIA_OBJS) $(LIBINFECT_OBJS) $(OPENER_OBJS) ammonia libinfect.dylib opener.dylib

.PHONY: all clean
