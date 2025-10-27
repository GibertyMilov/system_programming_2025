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

    mov rdi, [rsp+8]
    mov rax, 2              
    mov rsi, 577              
    mov rdx, 777o            
    syscall
    cmp rax, 0
    jl .exit_program
    mov r8, rax              

    mov rsi, [rsp+16]
    call str_number
    mov r9, rax                

    mov rbx, 1
.loop:
    inc rbx
    cmp rbx, r9
    jg .close_file

    mov rax, rbx
    call is_prime
    cmp rdi, 1
    jne .loop              

    mov rax, rbx
    mov rcx, 10
    xor rdx, rdx
    div rcx
    cmp rdx, 1
    jne .loop                


    mov rax, rbx
    mov rsi, buffer
    call number_str


    mov rax, buffer
    call len_str
    mov rdx, rax
    mov byte [buffer+rdx], 0x0A
    inc rdx

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