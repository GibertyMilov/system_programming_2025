format elf64
public _start

section '.data' writable
    usage db 'Usage: program a b c', 0x0A, 0
    result_msg db 'Result: ', 0
    newline db 0x0A, 0

section '.bss' writable
    buffer rb 32
    a dq 0
    b dq 0
    c dq 0
    result dq 0

section '.text' executable

_start:
    ; Получаем количество аргументов
    pop rcx
    cmp rcx, 4      ; программа + 3 параметра
    jne .show_usage

    ; Пропускаем имя программы
    pop rsi

    ; Читаем параметр a
    pop rsi
    call str_number
    mov [a], rax

    ; Читаем параметр b
    pop rsi
    call str_number
    mov [b], rax

    ; Читаем параметр c
    pop rsi
    call str_number
    mov [c], rax

    ; Вычисляем выражение: (((a - b) + c) * c)
    call calculate_expression

    ; Выводим результат
    mov rsi, result_msg
    call print_str
    
    mov rax, [result]
    mov rsi, buffer
    call number_str
    call print_str
    
    call new_line
    call exit

.show_usage:
    mov rsi, usage
    call print_str
    call exit

; Функция вычисления выражения (((a - b) + c) * c)
calculate_expression:
    push rbx
    push rcx

    ; Вычисляем (a - b)
    mov rax, [a]
    sub rax, [b]    ; rax = a - b

    ; Вычисляем ((a - b) + c)
    add rax, [c]    ; rax = (a - b) + c

    ; Вычисляем (((a - b) + c) * c)
    mov rbx, [c]    ; rbx = c
    imul rbx        ; rax = rax * rbx

    ; Сохраняем результат
    mov [result], rax
    
    pop rcx
    pop rbx
    ret

; =============================================
; БИБЛИОТЕКА ФУНКЦИЙ 
; =============================================

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
    
    ; Проверка на ноль
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

str_number:
    push rcx
    push rbx
    xor rax, rax
    xor rcx, rcx
.loop:
    xor rbx, rbx
    mov bl, byte [rsi+rcx]
    cmp bl, 0
    je .finished
    cmp bl, 48
    jl .finished
    cmp bl, 57
    jg .finished
    sub bl, 48
    add rax, rbx
    mov rbx, 10
    mul rbx
    inc rcx
    jmp .loop
.finished:
    cmp rcx, 0
    je .restore
    mov rbx, 10
    div rbx
.restore:
    pop rbx
    pop rcx
    ret