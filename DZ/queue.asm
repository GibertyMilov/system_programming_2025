format ELF64

section '.text' executable

public init_queue
public enqueue
public dequeue
public fill_random
public count_primes
public get_odd_numbers
public remove_even_numbers


SYS_MMAP  equ 9
SYS_MUNMAP equ 11
SYS_BRK    equ 12

PROT_READ  equ 1
PROT_WRITE equ 2
MAP_PRIVATE equ 2
MAP_ANONYMOUS equ 0x20

section '.data' writable
queue_size dq 1024

section '.bss' writable
queue_data  rq 1
queue_head  rq 1
queue_tail  rq 1
queue_count rq 1
queue_cap   rq 1

section '.text' executable
init_queue:
    push    rbx
    mov     rax, SYS_MMAP
    xor     rdi, rdi
    mov     rsi, [queue_size]
    shl     rsi, 3
    mov     rdx, PROT_READ or PROT_WRITE
    mov     r10, MAP_PRIVATE or MAP_ANONYMOUS
    mov     r8, -1
    xor     r9, r9
    syscall

    mov     [queue_data], rax
    xor     rax, rax
    mov     [queue_head], rax
    mov     [queue_tail], rax
    mov     [queue_count], rax
    mov     rax, [queue_size]
    mov     [queue_cap], rax
    pop     rbx
    ret

enqueue:
    push    rbx
    mov     rbx, [queue_count]
    mov     rcx, [queue_cap]
    cmp     rbx, rcx
    jae     .full
    
    mov     rcx, [queue_tail]
    mov     rdx, [queue_data]
    mov     [rdx + rcx*8], rdi
    
    inc     rcx
    mov     rax, [queue_cap]
    cmp     rcx, rax
    jb      .no_wrap_tail
    xor     rcx, rcx
.no_wrap_tail:
    mov     [queue_tail], rcx
    
    mov     rax, [queue_count]
    inc     rax
    mov     [queue_count], rax
    
    pop     rbx
    ret
.full:
    pop     rbx
    ret

dequeue:
    push    rbx
    mov     rax, [queue_count]
    test    rax, rax
    jz      .empty
    
    mov     rcx, [queue_head]
    mov     rdx, [queue_data]
    mov     rax, [rdx + rcx*8]
    
    inc     rcx
    mov     rbx, [queue_cap]
    cmp     rcx, rbx
    jb      .no_wrap_head
    xor     rcx, rcx
.no_wrap_head:
    mov     [queue_head], rcx
    
    mov     rbx, [queue_count]
    dec     rbx
    mov     [queue_count], rbx
    
    pop     rbx
    ret
.empty:
    xor     rax, rax
    pop     rbx
    ret

fill_random:
    push    rbx
    push    r12
    mov     r12, rdi      
    test    r12, r12
    jz      .done

.next:
    mov     rax, 318  
    lea     rdi, [rsp-8]  
    mov     rsi, 8         
    xor     rdx, rdx       
    syscall
    
    mov     rdi, [rsp-8]    
    mov     rax, rdi
    mov     rcx, 1000
    xor     rdx, rdx
    div     rcx          
    mov     rdi, rdx        
    
    call    enqueue
    dec     r12
    jnz     .next

.done:
    pop     r12
    pop     rbx
    ret

is_prime:
    cmp     rdi, 2
    jl      .not_prime
    je      .prime
    
    test    rdi, 1        
    jz      .not_prime
    
    mov     rcx, 3     
.check_loop:
    mov     rax, rcx
    mul     rcx             
    cmp     rax, rdi
    ja      .prime  
    
    mov     rax, rdi
    xor     rdx, rdx
    div     rcx          
    test    rdx, rdx
    jz      .not_prime    
    
    add     rcx, 2       
    jmp     .check_loop

.prime:
    mov     rax, 1
    ret

.not_prime:
    xor     rax, rax
    ret

public free_array
free_array:
    push    rbx
    mov     rax, 11      
    mov     rsi, rsi       
    shl     rsi, 3
    syscall
    pop     rbx
    ret

count_primes:
    push    rbx
    push    r12
    push    r13
    
    mov     r12, [queue_count] 
    mov     r13, 0             
    
    test    r12, r12
    jz      .done
    
.count_loop:
    call    dequeue           
    mov     rbx, rax         
    
    mov     rdi, rbx           
    call    is_prime
    add     r13, rax
    
    mov     rdi, rbx         
    call    enqueue
    
    dec     r12
    jnz     .count_loop
    
.done:
    mov     rax, r13         
    pop     r13
    pop     r12
    pop     rbx
    ret

get_odd_numbers:
    push    rbx
    push    r12
    push    r13
    push    r14
    
    mov     r14, rdi         
    mov     r12, [queue_count]
    mov     r13, 0            
    
    test    r12, r12
    jz      .allocate
    
.count_loop:
    call    dequeue
    mov     rbx, rax
    
    test    rbx, 1            
    jz      .even
    
    inc     r13              
    
.even:
    mov     rdi, rbx
    call    enqueue
    
    dec     r12
    jnz     .count_loop
    
.allocate:
    mov     rax, SYS_MMAP
    xor     rdi, rdi
    mov     rsi, r13
    shl     rsi, 3           
    mov     rdx, PROT_READ or PROT_WRITE
    mov     r10, MAP_PRIVATE or MAP_ANONYMOUS
    mov     r8, -1
    xor     r9, r9
    syscall
    
    mov     r12, rax         
    mov     [r14], r13        

    mov     r13, [queue_count]
    mov     r14, 0          
    
    test    r13, r13
    jz      .done_second
    
.fill_loop:
    call    dequeue
    mov     rbx, rax
    
    test    rbx, 1             
    jz      .not_odd
    
    mov     [r12 + r14*8], rbx
    inc     r14
    
.not_odd:
    mov     rdi, rbx
    call    enqueue
    
    dec     r13
    jnz     .fill_loop
    
.done_second:
    mov     rax, r12           
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

remove_even_numbers:
    push    rbx
    push    r12
    
    mov     r12, [queue_count] 
    
    test    r12, r12
    jz      .done
    
.process_loop:
    call    dequeue            
    mov     rbx, rax
    
    test    rbx, 1            
    jnz     .odd
    
    jmp     .next
    
.odd:
    mov     rdi, rbx
    call    enqueue
    
.next:
    dec     r12
    jnz     .process_loop
    
.done:
    pop     r12
    pop     rbx
    ret