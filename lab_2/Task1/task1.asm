format ELF64
public _start

section '.data' writable
    S       db 'AMVtdiYVETHnNhuYwnWDVBqL',0   ; исходная строка
    len     dq $-S-1                          ; длина (без нулевого байта)
    buf     rb 256                             ; буфер для перевёрнутой строки
    newline db 0x0A

section '.text' executable
_start:
    ; rbx = длина строки
    mov     rbx, [len]

    ; rsi -> S (начало исходной строки)
    lea     rsi, [S]

    ; rdi -> buf (куда писать в обратном порядке)
    lea     rdi, [buf]

    ; rcx = rbx (счётчик символов)
    mov     rcx, rbx

.rev_loop:
    cmp     rcx, 0
    je      .done
    dec     rcx
    mov     al, [rsi + rcx]   ; берём символ с конца
    mov     [rdi], al
    inc     rdi
    jmp     .rev_loop

.done:
    ; write(1, buf, len)
    mov     rax, 1        ; sys_write
    mov     rdi, 1        ; stdout
    lea     rsi, [buf]
    mov     rdx, rbx      ; длина исходной строки
    syscall

    ; перевод строки
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
