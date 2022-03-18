fb=fizzbuzz

OBJECTS=$(fb).o
BIN=$(fb)

ASM=nasm
LD=ld.lld

ASMFLAGS=-f elf64
LDFLAGS=

# --------

all: $(BIN)

clean:
	rm ./*.o || true

$(BIN): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<


