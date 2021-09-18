all: mul

mul: mul.o
	ld mul.o -m elf_i386 -o mul

mul.o: mul.s
	as mul.s --32 -o mul.o -g

clean: rm mul.o mul
