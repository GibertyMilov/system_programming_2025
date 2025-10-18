format ELF64
public _start

section '.data' writable
N       dq 5277616985       
ten     dq 10
buf     rb 32              

section '.text' executable
_start:
    mov rbx, [N]       
    xor rsi, rsi        

.sum_loop:
    cmp rbx, 0
    je  .done
    xor rdx, rdx
    mov rax, rbx
    div qword [ten]     
    add rsi, rdx     
    mov rbx, rax
    jmp .sum_loop

.done:
    mov rax, rsi
    lea rdi, [buf + 31]
    mov byte [rdi], 0x0A    
    dec rdi

.conv_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx                
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .conv_loop

    lea rsi, [rdi + 1]        
    mov rdx, buf + 32
    sub rdx, rsi         

    mov eax, 4
    mov ebx, 1
    mov ecx, esi        
    shr rsi, 32       
    mov edx, edx      
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80


