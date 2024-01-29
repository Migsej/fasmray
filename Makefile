main: main.o
	ld -o main -dynamic-linker /lib64/ld-linux-x86-64.so.2 main.o -lraylib -lm -ldl -lpthread -lc

main.o: main.asm
	fasm main.asm

