format elf64
public _start

include 'func.asm'

section '.bss' writable
    buffer rb 4096           
    line_ptrs rq 512       
    lens rq 512            
    newline db 0x0A          

section '.text' executable

_start:
    pop rcx
    cmp rcx, 3
    jne .exit_program


    mov rdi, [rsp+8]    
    mov rax, 2               
    mov rsi, 0             
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .exit_program
    mov r8, rax            


    mov rdi, [rsp+16]       
    mov rax, 2            
    mov rsi, 577             ; O_WRONLY + O_TRUNC + O_CREAT(с лекции)
    mov rdx, 777o         
    syscall
    cmp rax, 0
    jl .exit_program
    mov r9, rax              


    mov rax, 0              
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 4096
    syscall
    mov r10, rax            


    mov rax, 3
    mov rdi, r8
    syscall


    xor rbx, rbx           
    xor rcx, rcx          
    mov r11, 0            

.find_lines:
    cmp rcx, r10
    jge .after_split

    mov al, [buffer + rcx]
    cmp al, 0x0A
    jne .next_char


    mov rax, buffer
    add rax, r11
    mov [line_ptrs + rbx*8], rax
    mov rax, rcx
    sub rax, r11
    mov [lens + rbx*8], rax
    inc rbx

    inc rcx
    mov r11, rcx
    jmp .find_lines

.next_char:
    inc rcx
    jmp .find_lines

.after_split:
    cmp rcx, r11
    je .write_reverse


    mov rax, buffer
    add rax, r11
    mov [line_ptrs + rbx*8], rax
    mov rax, rcx
    sub rax, r11
    mov [lens + rbx*8], rax
    inc rbx

.write_reverse:
    dec rbx                 
.write_loop:
    cmp rbx, -1
    jl .close_files

    mov rsi, [line_ptrs + rbx*8]
    mov rdx, [lens + rbx*8]
    mov rax, 1
    mov rdi, r9
    syscall

    mov rax, 1
    mov rdi, r9
    mov rsi, newline
    mov rdx, 1
    syscall

    dec rbx
    jmp .write_loop

.close_files:
    mov rax, 3
    mov rdi, r9
    syscall

.exit_program:
    call exit