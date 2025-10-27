format elf64
public _start

section '.data' writable
    usage db 'Usage: program <character>', 0x0A, 0
    ascii_msg db 'ASCII code: ', 0
    newline db 0x0A, 0

section '.bss' writable
    buffer rb 16
    char rb 2

section '.text' executable

_start:
    pop rcx        
    cmp rcx, 2      
    jl .show_usage  

    pop rsi      
    pop rsi       
    
    mov al, [rsi]  
    mov [char], al  
    mov byte [char+1], 0 

    mov rsi, ascii_msg
    call print_str

    movzx rax, byte [char] 
    mov rsi, buffer
    call number_str
    call print_str

    call new_line

    call exit

.show_usage:
    mov rsi, usage
    call print_str
    call exit

exit:
    mov rax, 60    
    mov rdi, 0      
    syscall
    ret

print_str:
    push rax
    push rdi
    push rdx
    push rcx
    push rsi

    mov rdi, rsi  
    call len_str  
    
    mov rdi, rsi
    call len_str
    
    mov rdx, rax   
    mov rax, 1    
    mov rdi, 1   
    syscall
    
    pop rsi
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

len_str:
    push rdi
    mov rax, 0    
    
.loop:
    cmp byte [rdi + rax], 0 
    je .end                 
    inc rax    
    jmp .loop
    
.end:
    pop rdi
    ret

number_str:
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rbx, 10
    xor rcx, rcx 
    
    test rax, rax
    jnz .convert
    
    mov byte [rsi], '0'
    mov byte [rsi+1], 0
    jmp .end

.convert:
.digit_loop:
    xor rdx, rdx    
    div rbx         
    add dl, '0'     
    push rdx       
    inc rcx     
    test rax, rax   
    jnz .digit_loop
    
    mov rdi, rsi    
.store_loop:
    pop rax        
    mov [rdi], al  
    inc rdi        
    loop .store_loop
    
    mov byte [rdi], 0
    
.end:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

new_line:
    push rax
    push rdi
    push rsi
    push rdx

    mov rax, 0xA   
    push rax 
    
    mov rax, 0xA    
    push rax       
    

    mov rax, 1     
    mov rdi, 1    
    mov rsi, rsp 
    mov rdx, 1 
    syscall
    

    pop rax
    pop rdx
    pop rsi
    pop rdi
    pop rax

    ret


