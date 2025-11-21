; lab6_ncurses.asm
; FASM, ELF64

format ELF64
public main

section '.bss' writable
    xmax    dq ?
    ymax    dq ?
    delay   dq ?
    col     dq ?

section '.text' executable

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn move
extrn addch
extrn refresh
extrn timeout
extrn getch
extrn endwin
extrn mydelay

COLOR_RED   equ 1
COLOR_BLUE  equ 4

main:
    push rbp
    mov rbp, rsp

    ; Инициализация ncurses
    call initscr
    call start_color

    ; Инициализация цветовых пар
    mov rdi, 1
    mov rsi, COLOR_RED
    mov rdx, COLOR_RED
    call init_pair

    mov rdi, 2
    mov rsi, COLOR_BLUE
    mov rdx, COLOR_BLUE
    call init_pair

    ; Получаем размеры экрана
    mov rdi, 0
    call getmaxx
    mov [xmax], rax

    mov rdi, 0
    call getmaxy
    mov [ymax], rax

    ; Начальные значения
    mov qword [delay], 50
    mov qword [col], 0

    ; Неблокирующий ввод
    mov rdi, 0
    call timeout

main_loop:
    ; Проверяем границы
    mov rax, [col]
    cmp rax, [xmax]
    jl process_column
    mov qword [col], 0
    jmp main_loop

process_column:
    ; Определяем направление по четности столбца
    mov rax, [col]
    test rax, 1
    jnz up_direction

down_direction:
    ; ВНИЗ - начинаем с y=0, идем до ymax-1
    mov r12, 0
down_loop:
    cmp r12, [ymax]
    jge next_column
    
    ; Рисуем красный символ
    mov rdi, r12        ; y
    mov rsi, [col]      ; x
    call move
    
    ; Создаем символ с красным цветом
    mov rdi, ' '        ; символ пробела
    mov rsi, 0x100      ; COLOR_PAIR(1)
    or rdi, rsi         ; объединяем
    call addch
    call refresh
    
    ; Задержка
    mov rdi, [delay]
    call mydelay
    
    ; Проверка клавиш
    call check_keys
    cmp rax, 1
    je exit_program
    
    inc r12
    jmp down_loop

up_direction:
    ; ВВЕРХ - начинаем с y=ymax-1, идем до y=0
    mov r12, [ymax]
    dec r12
up_loop:
    cmp r12, 0
    jl next_column
    
    ; Рисуем синий символ
    mov rdi, r12        ; y
    mov rsi, [col]      ; x
    call move
    
    ; Создаем символ с синим цветом
    mov rdi, ' '        ; символ пробела
    mov rsi, 0x200      ; COLOR_PAIR(2)
    or rdi, rsi         ; объединяем
    call addch
    call refresh
    
    ; Задержка
    mov rdi, [delay]
    call mydelay
    
    ; Проверка клавиш
    call check_keys
    cmp rax, 1
    je exit_program
    
    dec r12
    jmp up_loop

next_column:
    ; Переход к следующему столбцу
    mov rax, [col]
    inc rax
    mov [col], rax
    jmp main_loop

check_keys:
    push rbp
    mov rbp, rsp
    
    call getch
    cmp eax, 'q'
    je .exit
    cmp eax, 'u'
    jne .check_d
    
    ; Ускорить
    mov rax, [delay]
    cmp rax, 10
    jle .min
    sub rax, 10
    mov [delay], rax
.min:
    jmp .continue
    
.check_d:
    cmp eax, 'd'
    jne .continue
    
    ; Замедлить
    mov rax, [delay]
    add rax, 10
    cmp rax, 200
    jle .store
    mov rax, 200
.store:
    mov [delay], rax

.continue:
    mov rax, 0
    jmp .done
.exit:
    mov rax, 1
.done:
    mov rsp, rbp
    pop rbp
    ret

exit_program:
    call endwin
    mov rsp, rbp
    pop rbp
    mov rax, 0
    ret