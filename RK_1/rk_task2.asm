format ELF64
include '../func.asm'
public _start

section '.data' writable 
    random_chars db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    chars_count = $ - random_chars
    error_msg db "Error: Usage: ./program <directory> <number>", 10, 0
    file_created db "Created: ", 0
    slash db "/", 0
    newline db 10, 0

section '.bss' writable
    dir_name rq 1
    file_count rq 1
    file_buffer rb 64
    name_buffer rb 16 

section '.text' executable 
_start:
    mov rax, [rsp]          
    cmp rax, 3
    jne .error

    mov rax, [rsp + 16]  
    mov [dir_name], rax
    
    mov rsi, [rsp + 24]   
    call str_number
    mov [file_count], rax

    mov r12, [file_count]
.create_files:
    test r12, r12
    jz .done

    call generate_random_name
    
    mov rdi, file_buffer
    
    mov rsi, [dir_name]
.copy_dir:
    mov al, [rsi]
    test al, al
    jz .dir_copied
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .copy_dir
.dir_copied:
    
    mov al, '/'
    mov [rdi], al
    inc rdi
    
    mov rsi, name_buffer
.copy_name:
    mov al, [rsi]
    test al, al
    jz .name_copied
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .copy_name
.name_copied:
    mov byte [rdi], 0

    mov rax, 2          
    mov rdi, file_buffer  
    mov rsi, 0x241         
    mov rdx, 0644o   
    syscall
    
    cmp rax, 0
    jl .skip_file
    

    mov rdi, rax
    mov rax, 3          
    syscall
    
    mov rsi, file_created
    call print_str
    mov rsi, file_buffer
    call print_str
    mov rsi, newline
    call print_str

.skip_file:
    dec r12
    jmp .create_files

.done:
    call exit

.error:
    mov rsi, error_msg
    call print_str
    call exit

generate_random_name:
    push rcx
    push rsi
    push rdi
    
    mov rcx, 8              
    mov rdi, name_buffer
    
.rand_loop:

    rdtsc                   
    xor rdx, rdx
    mov rbx, chars_count
    div rbx                

    mov al, [random_chars + rdx]
    mov [rdi], al
    inc rdi
    loop .rand_loop
    
    mov byte [rdi], '.'
    mov byte [rdi+1], 't'
    mov byte [rdi+2], 'x'
    mov byte [rdi+3], 't'
    mov byte [rdi+4], 0
    
    pop rdi
    pop rsi
    pop rcx
    ret