format ELF64
public _start

section '.data' writable
    N       dq 21       
    symbol  db '8'      
    newline db 0x0A      
    mem     rb 1024      

section '.text' executable
_start:
    mov     rbx, [N] 
    xor     rcx, rcx     
.fill:
    cmp     rcx, rbx
    jae     .filled
    mov     al, [symbol]
    mov     [mem + rcx], al
    inc     rcx
    jmp     .fill
.filled:
    xor     r13, r13     
    mov     r14, 1      

.next_line:
    cmp     r13, rbx
    jae     .exit        


    mov     rax, rbx
    sub     rax, r13

    mov     r15, r14      
    cmp     rax, r14
    jae     .len_ok
    mov     r15, rax
.len_ok:
    mov     rax, 1     
    mov     rdi, 1   
    lea     rsi, [mem + r13]
    mov     rdx, r15
    syscall


    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall

    add     r13, r15      
    inc     r14           
    jmp     .next_line

.exit:
    mov     rax, 60       
    xor     rdi, rdi
    syscall
