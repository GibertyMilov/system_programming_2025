format ELF64
public _start

section '.data' writable
    N       dq 21        ; всего символов
    symbol  db '8'       ; какой символ печатать
    newline db 0x0A      ; '\n'
    mem     rb 1024      ; буфер для N символов (N <= 1024)

section '.text' executable
_start:
    ; -------- Заполняем память символами --------
    mov     rbx, [N]      ; rbx = N
    xor     rcx, rcx      ; rcx = индекс
.fill:
    cmp     rcx, rbx
    jae     .filled
    mov     al, [symbol]
    mov     [mem + rcx], al
    inc     rcx
    jmp     .fill
.filled:

    ; -------- Печать лесенкой --------
    xor     r13, r13      ; r13 = сколько уже выведено
    mov     r14, 1        ; r14 = длина следующей строки (начинаем с 1)

.next_line:
    cmp     r13, rbx
    jae     .exit         ; всё напечатано

    ; remaining = N - printed
    mov     rax, rbx
    sub     rax, r13

    ; len = min(r14, remaining)
    mov     r15, r14      ; r15 = длина текущей строки (локальная копия)
    cmp     rax, r14
    jae     .len_ok
    mov     r15, rax
.len_ok:

    ; write(1, mem + printed, len)
    mov     rax, 1        ; sys_write
    mov     rdi, 1        ; stdout
    lea     rsi, [mem + r13]
    mov     rdx, r15
    syscall

    ; перевод строки
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall

    ; обновляем счётчики
    add     r13, r15      ; увеличиваем общее число выведенных символов
    inc     r14           ; длина следующей строки +1
    jmp     .next_line

.exit:
    mov     rax, 60       ; sys_exit
    xor     rdi, rdi
    syscall
