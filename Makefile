NIHSERVER_SFILES := $(shell find src -type f -name '*.s' -and -not -wholename 'src/nihserver/start.s')

NIHSERVER_OBJFILES := $(NIHSERVER_SFILES:src/%.s=target/%.o)

all: target/nihserver/nihserver

target/%.o: src/%.s
	mkdir -p $(dir $@)
	nasm -f elf64 -g -F dwarf -i src/ $^ -o $@

target/nihserver/nihserver: $(NIHSERVER_OBJFILES) target/nihserver/start.o
	mkdir -p target/nihserver
	ld -o $@ $^

clean:
	rm -rf target
