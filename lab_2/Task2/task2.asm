format ELF64
public _start

section '.data' writable
    M       dq 6      
    K       dq 11      
    N       dq 66        
    symbol  db '+'    
    newline db 0x0A      
    mem     rb 1024       

section '.text' executable
_start:
    mov     rbx, [N]     
    mov     r10, [M]      
    mov     r11, [K]    

    xor     r13, r13    
.fill_mem:
    cmp     r13, rbx
    je      .filled
    mov     al, [symbol]
    mov     [mem + r13], al
    inc     r13
    jmp     .fill_mem

.filled:
    xor     r13, r13 

.print_rows:
    cmp     r11, 0        
    je      .exit
    cmp     r13, rbx   
    jae     .exit

    mov     rax, rbx
    sub     rax, r13

    mov     rdx, r10     
    cmp     rax, r10
    jb      .use_remaining
    jmp     .len_ready
.use_remaining:
    mov     rdx, rax     
.len_ready:
    mov     r14, rdx    

    lea     rsi, [mem + r13]
    mov     rax, 1   
    mov     rdi, 1     
    mov     rdx, r14      
    syscall

    mov     rax, 1
    mov     rdi, 1
    lea     rsi, [newline]
    mov     rdx, 1
    syscall


    add     r13, r14      
    dec     r11           
    jmp     .print_rows

.exit:
    mov     rax, 60       
    xor     rdi, rdi
    syscall

