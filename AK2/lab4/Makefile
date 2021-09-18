all: main

main: main.c qdbmp.c read.s steganography.s
	gcc -g -m32 steganography.s read.s main.c -lm -o main

clean:
	rm main