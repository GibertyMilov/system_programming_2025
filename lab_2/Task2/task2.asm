format ELF64
public _start

section '.data' writable
    M       dq 6          ; символов в строке
    K       dq 11          ; количество строк
    N       dq 66         ; всего символов для заполнения
    symbol  db '+'        ; символ заполнения
    newline db 0x0A       ; '\n'
    ; резервируем память для хранения символов (достаточно большой буфер)
    mem     rb 1024       ; буфер для N символов (N <= 1024 в этом примере)

section '.text' executable
_start:
    ; ---------------------------
    ; Загружаем параметры в регистры
    ; ---------------------------
    mov     rbx, [N]      ; rbx = N (кол-во символов всего)
    mov     r10, [M]      ; r10 = M (длина строки)
    mov     r11, [K]      ; r11 = K (число строк)

    ; ---------------------------
    ; 1) Заполняем mem первыми N символами = symbol
    ; ---------------------------
    xor     r13, r13      ; r13 = idx = 0
.fill_mem:
    cmp     r13, rbx
    je      .filled
    mov     al, [symbol]
    mov     [mem + r13], al
    inc     r13
    jmp     .fill_mem

.filled:
    ; сбросим индекс для печати
    xor     r13, r13      ; r13 = idx = 0 (будет индекс текущего символа при печати)

    ; ---------------------------
    ; 2) Печатаем до K строк по M символов, но не больше чем N символов всего
    ; ---------------------------
.print_rows:
    cmp     r11, 0        ; если строк осталось 0 -> выход
    je      .exit
    cmp     r13, rbx      ; если индекс >= N -> всё напечатано -> выход
    jae     .exit

    ; remaining = N - idx  (в rax)
    mov     rax, rbx
    sub     rax, r13

    ; вычисляем len = min(M, remaining), сохраним в r14
    mov     rdx, r10      ; rdx := M (по умолчанию)
    cmp     rax, r10
    jb      .use_remaining
    ; rax >= r10 -> rdx = M остаётся
    jmp     .len_ready
.use_remaining:
    mov     rdx, rax      ; rdx = remaining (меньше M)
.len_ready:
    mov     r14, rdx      ; r14 = длина текущей подстроки (len)

    ; write(1, mem + idx, len)
    lea     rsi, [mem + r13]
    mov     rax, 1        ; sys_write
    mov     rdi, 1        ; fd = stdout
    mov     rdx, r14      ; len
    syscall

    ; напишем перевод строки '\n'
    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall

    ; обновим индекс и счётчик строк
    add     r13, r14      ; idx += len
    dec     r11           ; одна строка напечатана
    jmp     .print_rows

.exit:
    mov     rax, 60       ; sys_exit
    xor     rdi, rdi
    syscall
