format ELF64
include '../func.asm'
public _start

section '.data' writable 
    buffer db 0
    rb 99             
    msg db "Result: ", 0

section '.bss' writable
    res rq 1               

section '.text' executable 
_start:
    mov rsi, [rsp + 16]     
    call str_number         
    mov rcx, rax             
    xor rbx, rbx            
    xor rdx, rdx             
    mov rdx, 1            

.loop:
    add rbx, rdx          
    mov rax, rdx
    mov rdi, 10
    mul rdi                 
    add rax, 1          
    mov rdx, rax              
    dec rcx
    jnz .loop

    mov rax, rbx
    mov rsi, buffer
    call number_str

    mov rsi, msg
    call print_str

    mov rsi, buffer
    call print_str

    call new_line
    call exit