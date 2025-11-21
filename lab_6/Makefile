ASM = fasm
ASM_SRC = lab6.asm
ASM_OBJ = lab6.o

C_SRC = delay.c
C_OBJ = delay.o

OUT = lab6

all: $(OUT)

$(ASM_OBJ): $(ASM_SRC)
	fasm $(ASM_SRC)

$(C_OBJ): $(C_SRC)
	gcc -c $(C_SRC) -o $(C_OBJ)

$(OUT): $(ASM_OBJ) $(C_OBJ)
	gcc -no-pie $(ASM_OBJ) $(C_OBJ) -lncurses -o $(OUT)

run:
	./$(OUT)

clean:
	rm -f $(ASM_OBJ) $(C_OBJ) $(OUT)
