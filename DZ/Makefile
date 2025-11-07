all: main

main: main.o queue.o
	gcc -no-pie -o main main.o queue.o

main.o: main.c
	gcc -c main.c -o main.o

queue.o: queue.asm
	fasm queue.asm queue.o

clean:
	rm -f *.o main