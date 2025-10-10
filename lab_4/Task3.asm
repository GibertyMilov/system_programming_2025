; Task3.asm - FASM (ELF64) — исправленная версия с корректным выводом знака

format ELF64 executable
entry start

segment readable writeable
    input   rb 64
    n       dq 0
    sum     dq 0
    k       dq 1
    sign    dq -1

segment readable executable

start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [prompt]
    mov rdx, prompt_len
    syscall

    mov rax, 0
    mov rdi, 0
    lea rsi, [input]
    mov rdx, 64
    syscall

    xor rbx, rbx        
    lea rsi, [input]
parse_loop:
    mov al, [rsi]
    cmp al, 10
    je parsed
    cmp al, 0
    je parsed
    cmp al, '0'
    jb parsed
    cmp al, '9'
    ja parsed
    movzx rdx, byte [rsi]
    sub rdx, '0'
    imul rbx, rbx, 10
    add rbx, rdx
    inc rsi
    jmp parse_loop
parsed:
    mov [n], rbx


    mov qword [sum], 0
    mov qword [k], 1
    mov qword [sign], -1


calc_loop:
    mov rax, [k]
    cmp rax, [n]
    ja done

    mov rbx, rax
    add rbx, 1
    imul rax, rbx   

    mov rcx, [k]
    imul rcx, rcx, 3
    add rcx, 1
    imul rax, rcx       

    mov rcx, [k]
    imul rcx, rcx, 3
    add rcx, 2
    imul rax, rcx


    mov rcx, [sign]
    imul rax, rcx

    add [sum], rax


    mov rax, [sign]
    neg rax
    mov [sign], rax

    inc qword [k]
    jmp calc_loop

done:
    mov rax, [sum]
    call print_int
    call newline


    mov rax, 60
    xor rdi, rdi
    syscall


print_int:
    cmp rax, 0
    jne .not_zero

    mov rax, 1
    mov rdi, 1
    lea rsi, [zero]
    mov rdx, 1
    syscall
    ret

.not_zero:
    xor r8, r8          
    cmp rax, 0
    jge .conv_start
    neg rax         
    mov r8, 1

.conv_start:
    mov rbx, 10
    lea rsi, [input+63] 
    mov byte [rsi], 0

.conv_loop:
    xor rdx, rdx
    div rbx            
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .conv_loop

    cmp r8, 0
    je .print_str
    dec rsi
    mov byte [rsi], '-'

.print_str:
    mov rax, 1
    mov rdi, 1
    mov rdx, input+64
    sub rdx, rsi        
    mov rsi, rsi
    syscall
    ret

newline:
    mov rax, 1
    mov rdi, 1
    lea rsi, [nl]
    mov rdx, 1
    syscall
    ret

segment readable
    prompt  db "Enter n: ",0
    prompt_len = $ - prompt
    zero    db "0"
    nl      db 10
