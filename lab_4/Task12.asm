format ELF64 executable

segment readable executable
entry start

start:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, number_buf
    mov rdx, 20
    syscall

    mov rcx, rax
    dec rcx
    mov [num_length], rcx

    cmp rcx, 1
    jle yes_result

    mov rcx, [num_length]
    dec rcx
    mov rsi, number_buf

check_loop:
    mov al, [rsi]
    sub al, '0'
    mov bl, [rsi+1]
    sub bl, '0'
    cmp al, bl
    jg no_result
    inc rsi
    loop check_loop

yes_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, yes_msg
    mov rdx, yes_msg_len
    syscall
    jmp exit

no_result:
    mov rax, 1
    mov rdi, 1
    mov rsi, no_msg
    mov rdx, no_msg_len
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

segment readable writeable
prompt      db 'Введите число: ', 0
prompt_len  = $ - prompt
yes_msg     db 'Да', 10, 0
yes_msg_len = $ - yes_msg
no_msg      db 'Нет', 10, 0
no_msg_len  = $ - no_msg
number_buf  rb 21
num_length  dq 0