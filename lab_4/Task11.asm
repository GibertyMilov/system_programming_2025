format ELF64 executable

segment readable executable
entry start

start:
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_n
    mov rdx, prompt_n_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, n_buffer
    mov rdx, 4
    syscall

    mov rsi, n_buffer
    call atoi
    mov [n], rax

    mov rbx, 0
    mov rcx, [n]

input_loop:
    push rcx
    push rbx

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_vote
    mov rdx, prompt_vote_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, vote_buffer
    mov rdx, 2
    syscall

    pop rbx
    pop rcx

    cmp byte [vote_buffer], '1'
    jne not_one
    inc rbx
not_one:

    loop input_loop

    mov rax, [n]
    mov rcx, 2
    xor rdx, rdx
    div rcx

    cmp rbx, rax
    jg decision_yes
    jl decision_no

    mov rax, 1
    mov rdi, 1
    mov rsi, tie_msg
    mov rdx, tie_msg_len
    syscall
    jmp exit

decision_yes:
    mov rax, 1
    mov rdi, 1
    mov rsi, yes_msg
    mov rdx, yes_msg_len
    syscall
    jmp exit

decision_no:
    mov rax, 1
    mov rdi, 1
    mov rsi, no_msg
    mov rdx, no_msg_len
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

atoi:
    xor rax, rax
    xor rcx, rcx
.next_digit:
    mov cl, [rsi]
    cmp cl, 0x0A
    je .done
    cmp cl, '0'
    jb .done
    cmp cl, '9'
    ja .done
    sub cl, '0'
    imul rax, 10
    add rax, rcx
    inc rsi
    jmp .next_digit
.done:
    ret

segment readable writeable
prompt_n      db 'Введите количество судей n: ', 0
prompt_n_len  = $ - prompt_n

prompt_vote   db 'Введите голос судьи (0 или 1): ', 0
prompt_vote_len = $ - prompt_vote

yes_msg       db 'Решение: Да', 10, 0
yes_msg_len   = $ - yes_msg

no_msg        db 'Решение: Нет', 10, 0
no_msg_len    = $ - no_msg

tie_msg       db 'Ничья! Решение не принято', 10, 0
tie_msg_len   = $ - tie_msg

n_buffer      rb 4
vote_buffer   rb 2
n             dq 0