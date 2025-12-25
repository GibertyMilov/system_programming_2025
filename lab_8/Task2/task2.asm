format elf64

public _start

extrn printf
extrn scanf
extrn atof

section '.data' writable
    input_format    db "%lf", 0
    output_header  db "%-10s%-15s%-15s", 0xA, 0
    output_row     db "%-10.6f%-15.6f%-15d", 0xA, 0
    
    header_x       db "x", 0
    header_epsilon db "epsilon", 0
    header_terms   db "terms", 0
    
    prompt_x       db "Enter x (-1 < x < 1): ", 0
    prompt_eps     db "Enter epsilon: ", 0
    newline        db 0xA, 0
    
    const_1        dq 1.0
    const_4        dq 4.0
    const_neg1     dq -1.0

section '.bss' writable
    x           rq 1    
    epsilon     rq 1   
    result      rq 1   
    term_count  rq 1      
    current_term rq 1     
    temp        rq 1      
    x_power     rq 1      

section '.text' executable

; (1/4)*ln((1+x)/(1-x)) + (1/2)*arctan(x)
calc_analytic:
    push rbp
    mov rbp, rsp
    
    ; ln((1+x)/(1-x))
    fld1
    fadd qword [x]   
    fld1
    fsub qword [x]      ; st0 = 1 - x, st1 = 1 + x
    fdivp st1, st0    
    fyl2x               ; st0 = log2((1+x)/(1-x))
    fldln2
    fmulp st1, st0      ; st0 = ln((1+x)/(1-x))
    
    ; * 1/4
    fld qword [const_1]
    fld qword [const_4]
    fdivp st1, st0      ; st0 = 1/4
    fmulp st1, st0      ; st0 = (1/4)*ln((1+x)/(1-x))
    
    ; находим arctan(x)
    fld qword [x]       ; st0 = x, st1 = предыдущий результат
    fld1                ; st0 = 1, st1 = x, st2 = предыдущий результат
    fpatan              ; st0 = arctan(x), st1 = предыдущий результат
    
    ; * 1/2
    fld1
    fadd st0, st0 
    fdivrp st1, st0     
    
    faddp st1, st0     
    
    leave
    ret

; x + x^5/5 + x^9/9 + ... + x^(4n+1)/(4n+1)
calc_series:
    push rbp
    mov rbp, rsp
    
    finit
    fldz             
    fstp qword [result]
    
    mov qword [term_count], 0
    mov qword [x_power], 1
    
    ; первое слагаемое: x^1/1 = x
    fld qword [x]
    fstp qword [current_term]
    fld qword [x]
    fstp qword [x_power]
    
.calc_loop:
    inc qword [term_count]
    
    ; вычисляем текущее слагаемое: x^(4n+1)/(4n+1)
    finit
    fld qword [x_power]  ; st0 = x^(4n-3) (текущая степень)
    
    ; умножаем на x^4 для получения следующей степени
    fld qword [x]
    fmul st0, st0        ; st0 = x^2
    fmul st0, st0        ; st0 = x^4
    fmulp st1, st0       ; st0 = x^(4n+1)
    fst qword [x_power]  ; сохраняем для следующей итерации
    
    ; делим на (4n+1)
    fild qword [term_count] ; st0 = n
    fld qword [const_4]     ; st0 = 4, st1 = n
    fmulp st1, st0          ; st0 = 4n
    fld1                    ; st0 = 1, st1 = 4n
    faddp st1, st0          ; st0 = 4n + 1
    fdivp st1, st0          ; st0 = x^(4n+1)/(4n+1)
    
    fst qword [current_term]
    
    fadd qword [result]
    fstp qword [result]
    
    ; проверяем точность
    ; если |current_term| < epsilon, выходим
    fld qword [current_term]
    fabs                   ; st0 = |current_term|
    fld qword [epsilon]    ; st0 = epsilon, st1 = |current_term|
    fcomip st1            ; сравниваем epsilon и |current_term|
    fstp st0              ; очищаем стек
    jb .continue          ; если epsilon < |current_term|, продолжаем
    jmp .done             ; иначе выходим
    
.continue:
    ; проверяем на итерации
    cmp qword [term_count], 1000000
    jl .calc_loop
    
.done:
    leave
    ret

_start:
    mov rdi, prompt_x
    call printf
    
    mov rdi, input_format
    mov rsi, x
    xor rax, rax
    call scanf
    
    ; ввод точности
    mov rdi, prompt_eps
    call printf
    
    mov rdi, input_format
    mov rsi, epsilon
    xor rax, rax
    call scanf
    
    ; проверка корректности x
    finit
    fld qword [x]
    fabs                    ; st0 = |x|
    fld1                   ; st0 = 1, st1 = |x|
    fcomip st1            ; сравниваем 1 и |x|
    fstp st0              ; очищаем стек
    jbe .invalid_x        ; если |x| >= 1, ошибка
    
    call calc_analytic
    fstp qword [temp]     ; сохраняем аналитический результат
    
    call calc_series
    
    mov rdi, output_header
    mov rsi, header_x
    mov rdx, header_epsilon
    mov rcx, header_terms
    xor rax, rax
    call printf
    
    mov rdi, output_row
    movq xmm0, [x]
    movq xmm1, [epsilon]
    mov rsi, [term_count]
    mov rax, 2            
    call printf
    
    mov rax, 60
    xor rdi, rdi
    syscall
    
.invalid_x:
    mov rdi, newline
    call printf
    mov rdi, newline
    call printf
    
    mov rax, 60
    mov rdi, 1
    syscall