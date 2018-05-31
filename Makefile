CC=gcc
CFLAGS64=`pkg-config --cflags allegro-5 allegro_main-5 allegro_color-5 allegro_dialog-5 allegro_font-5 allegro_image-5 allegro_memfile-5 allegro_primitives-5 allegro_ttf-5`
CFLAGS32=-m32 $(CFLAGS64)
LIBS= `pkg-config --libs allegro-5 allegro_main-5 allegro_color-5 allegro_dialog-5 allegro_font-5 allegro_image-5 allegro_memfile-5 allegro_primitives-5 allegro_ttf-5`

ASM=nasm
AFLAGS32=-f elf32
AFLAGS64=-f elf64

all: 64

main32.o: main.c
	$(CC) $(CFLAGS32) -c main.c -o main32.o
func32.o: func.asm
	$(ASM) $(AFLAGS32) func.asm -o func32.o
32: main32.o func32.o
	$(CC) $(CFLAGS32) main32.o func32.o -o result $(LIBS)

main64.o: main.c
	$(CC) $(CFLAGS64) -c main.c -o main64.o
func64.o: func.asm
	$(ASM) $(AFLAGS64) func.asm -o func64.o
64: main64.o func64.o
	$(CC) $(CFLAGS64) main64.o func64.o -o result $(LIBS)

clean:
	rm *.o
	rm result*
