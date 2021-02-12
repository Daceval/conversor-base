all: run clean
build: conversor.asm
	nasm conversor.asm -f elf64

linkeditor: build
	gcc conversor.o -o conversor -no-pie

run: linkeditor
	clear
	./conversor
