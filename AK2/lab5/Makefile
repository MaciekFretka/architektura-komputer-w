all: main

main: main.c filter.s
	gcc -g -m32 filter.s main.c -lm -o main

clean:
	rm main
