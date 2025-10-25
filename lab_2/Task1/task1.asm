format ELF64
public _start

section '.data' writable
    S       db 'AMVtdiYVETHnNhuYwnWDVBqL',0  
    len     dq $-S-1                     
    buf     rb 256                           
    newline db 0x0A

section '.text' executable
_start:
    mov     rbx, [len]
    lea     rsi, [S]
    lea     rdi, [buf]
    mov     rcx, rbx

.rev_loop:
    cmp     rcx, 0
    je      .done
    dec     rcx
    mov     al, [rsi + rcx] 
    mov     [rdi], al
    inc     rdi
    jmp     .rev_loop

.done:
    ; write(1, buf, len)
    mov     rax, 1  
    mov     rdi, 1   
    lea     rsi, [buf]
    mov     rdx, rbx     
    syscall

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall
