format elf64
public _start

include 'func.asm'

section '.bss' writable
    buffer rb 4096           ; буфер чтения из файла
    line_ptrs rq 512         ; указатели на начало строк
    lens rq 512              ; длины строк
    newline db 0x0A          ; символ новой строки

section '.text' executable

_start:
    ; === Проверка количества аргументов ===
    pop rcx
    cmp rcx, 3
    jne .exit_program

    ; === Открываем входной файл ===
    mov rdi, [rsp+8]         ; argv[1]
    mov rax, 2               ; sys_open
    mov rsi, 0               ; O_RDONLY
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .exit_program
    mov r8, rax              ; fd_in

    ; === Открываем выходной файл ===
    mov rdi, [rsp+16]        ; argv[2]
    mov rax, 2               ; sys_open
    mov rsi, 577             ; O_WRONLY | O_TRUNC | O_CREAT
    mov rdx, 777o            ; права доступа
    syscall
    cmp rax, 0
    jl .exit_program
    mov r9, rax              ; fd_out

    ; === Читаем весь входной файл ===
    mov rax, 0               ; sys_read
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 4096
    syscall
    mov r10, rax             ; количество считанных байт

    ; === Закрываем входной файл ===
    mov rax, 3
    mov rdi, r8
    syscall

    ; === Разделяем на строки ===
    xor rbx, rbx             ; счётчик строк
    xor rcx, rcx             ; индекс в буфере
    mov r11, 0               ; начало текущей строки

.find_lines:
    cmp rcx, r10
    jge .after_split

    mov al, [buffer + rcx]
    cmp al, 0x0A
    jne .next_char

    ; нашли конец строки
    mov rax, buffer
    add rax, r11
    mov [line_ptrs + rbx*8], rax
    mov rax, rcx
    sub rax, r11
    mov [lens + rbx*8], rax
    inc rbx

    inc rcx
    mov r11, rcx
    jmp .find_lines

.next_char:
    inc rcx
    jmp .find_lines

.after_split:
    cmp rcx, r11
    je .write_reverse

    ; если последняя строка не заканчивалась \n
    mov rax, buffer
    add rax, r11
    mov [line_ptrs + rbx*8], rax
    mov rax, rcx
    sub rax, r11
    mov [lens + rbx*8], rax
    inc rbx

.write_reverse:
    dec rbx                 ; последний индекс строки
.write_loop:
    cmp rbx, -1
    jl .close_files

    mov rsi, [line_ptrs + rbx*8]
    mov rdx, [lens + rbx*8]
    mov rax, 1
    mov rdi, r9
    syscall

    ; записываем перевод строки
    mov rax, 1
    mov rdi, r9
    mov rsi, newline
    mov rdx, 1
    syscall

    dec rbx
    jmp .write_loop

.close_files:
    mov rax, 3
    mov rdi, r9
    syscall

.exit_program:
    call exit