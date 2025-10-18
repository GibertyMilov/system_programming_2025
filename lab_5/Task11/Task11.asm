format elf64
public _start

include 'func.asm'

section '.bss' writable
    buffer rb 100

section '.text' executable

_start:
    pop rcx 
    cmp rcx, 1 
    je .exit_program

    ;; Открываем файл на запись
    mov rdi, [rsp+8]
    mov rax, 2                  ; sys_open
    mov rsi, 577                ; O_WRONLY | O_TRUNC | O_CREAT
    mov rdx, 777o               ; права доступа
    syscall
    cmp rax, 0
    jl .exit_program
    mov r8, rax                 ; сохраняем файловый дескриптор

    ;; Читаем число N из аргумента
    mov rsi, [rsp+16]
    call str_number
    mov r9, rax                 ; N в r9

    ;; Цикл по числам от 2 до N
    mov rbx, 1
.loop:
    inc rbx
    cmp rbx, r9
    jg .close_file

    ;; Проверяем, простое ли число
    mov rax, rbx
    call is_prime
    cmp rdi, 1
    jne .loop                   ; если не простое — дальше

    ;; Проверяем, оканчивается ли на 1
    mov rax, rbx
    mov rcx, 10
    xor rdx, rdx
    div rcx
    cmp rdx, 1
    jne .loop                   ; если не оканчивается на 1 — дальше

    ;; Преобразуем число в строку
    mov rax, rbx
    mov rsi, buffer
    call number_str

    ;; Узнаём длину строки
    mov rax, buffer
    call len_str
    mov rdx, rax
    mov byte [buffer+rdx], 0x0A
    inc rdx

    ;; Пишем в файл
    mov rax, 1
    mov rdi, r8
    mov rsi, buffer
    syscall

    jmp .loop

.close_file:
    mov rdi, r8
    mov rax, 3
    syscall

.exit_program:
    call exit