; process_array.asm
format ELF64

extrn print_str
extrn new_line
extrn number_str
extrn is_prime
extrn exit

section '.bss' writeable
array_ptr   dq ?
temp_ptr    dq ?
child_pids  dq 4 dup(?)
digit_count dd 10 dup(?)
number_buf  rb 32

section '.data' writeable
array_size = 591
msg_multiple_5 db "Numbers divisible by 5: ",0
msg_rare_digit db "Most rare digit: ",0
msg_median db "Median: ",0
msg_prime_count db "Prime numbers count: ",0

section '.text' executable
public _start
_start:
    ; mmap для массива
    mov rax, 9
    xor rdi, rdi
    mov rsi, array_size*8
    mov rdx, 3
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    mov [array_ptr], rax
    mov r12, rax
    
    ; Заполняем массив
    mov r13, array_size
    mov r14, 0
.fill_loop:
    call random_number
    mov [r12 + r14*8], rax
    inc r14
    cmp r14, r13
    jl .fill_loop
    
    mov r14, 0
.sequential_loop:
    cmp r14, 4
    jge .parent_exit
    
    ; Fork
    mov rax, 57
    syscall
    
    cmp rax, 0
    je child_process
    
    ; Родитель ждет завершения дочернего процесса
    mov rdi, rax
    mov rax, 61
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    
    inc r14
    jmp .sequential_loop

.parent_exit:
    mov rax, 11
    mov rdi, [array_ptr]
    mov rsi, array_size*8
    syscall
    call exit

child_process:
    cmp r14, 0
    je action_multiple_5
    cmp r14, 1
    je action_rare_digit
    cmp r14, 2
    je action_median
    cmp r14, 3
    je action_prime_count
    jmp child_exit

action_multiple_5:
    mov rsi, msg_multiple_5
    call print_str
    mov rbx, [array_ptr]
    mov rcx, array_size
    xor r15, r15
.count_loop:
    mov rax, [rbx]
    xor rdx, rdx
    mov rdi, 5
    div rdi
    test rdx, rdx
    jnz .not_multiple
    inc r15
.not_multiple:
    add rbx, 8
    dec rcx
    jnz .count_loop
    mov rax, r15
    call print_number
    call new_line
    jmp child_exit

action_rare_digit:
    mov rsi, msg_rare_digit
    call print_str
    mov rdi, digit_count
    mov rcx, 10
    xor rax, rax
    rep stosd
    mov rbx, [array_ptr]
    mov rcx, array_size
.digit_loop:
    mov rax, [rbx]
    call count_digits_in_number
    add rbx, 8
    dec rcx
    jnz .digit_loop
    mov rsi, digit_count
    mov rcx, 10
    mov rdx, 0x7FFFFFFF
    mov r8, 0; индекс самой редкой цифры
    mov r9, 0
.find_rare:
    mov eax, [rsi]
    cmp eax, edx
    jge .not_rarer
    mov edx, eax
    mov r8, r9
.not_rarer:
    add rsi, 4
    inc r9
    loop .find_rare
    mov rax, r8
    call print_number
    call new_line
    jmp child_exit

action_median:
    mov rsi, msg_median
    call print_str

    mov rax, 9
    xor rdi, rdi
    mov rsi, array_size*8
    mov rdx, 3
    mov r10, 0x22
    mov r8, -1
    xor r9, r9
    syscall
    
    mov [temp_ptr], rax


    mov rdi, rax
    mov rsi, [array_ptr]
    mov rcx, array_size
    rep movsq


    mov rbx, [temp_ptr]
    mov rcx, array_size
    dec rcx
.outer_loop:
    mov rdx, rcx
    mov rsi, rbx
.inner_loop:
    mov rax, [rsi]; array[j]
    mov rdi, [rsi + 8]; array[j + 1]
    cmp rax, rdi
    jle .no_swap
    mov [rsi], rdi
    mov [rsi + 8], rax
.no_swap:
    add rsi, 8
    dec rdx
    jnz .inner_loop
    loop .outer_loop
    mov rax, array_size
    xor rdx, rdx
    mov rdi, 2
    div rdi
    test rdx, rdx
    jz .even_count
    mov rbx, [temp_ptr]
    mov rax, [rbx + rax*8]
    jmp .print_median
.even_count:
    mov rbx, [temp_ptr]
    mov rax, [rbx + rax*8]
    mov rdx, [rbx + (rax-1)*8]
    add rax, rdx
    shr rax, 1
.print_median:
    call print_number
    call new_line
    mov rax, 11
    mov rdi, [temp_ptr]
    mov rsi, array_size*8
    syscall
    jmp child_exit

action_prime_count:
    mov rsi, msg_prime_count
    call print_str
    mov rbx, [array_ptr]
    mov rcx, array_size
    xor r15, r15
.prime_loop:
    mov rax, [rbx]
    call is_prime
    cmp rdi, 1
    jne .not_prime
    inc r15
.not_prime:
    add rbx, 8
    dec rcx
    jnz .prime_loop
    mov rax, r15
    call print_number
    call new_line
    jmp child_exit

child_exit:
    call exit

random_number:
    rdrand rax
    jnc random_number
    and rax, 0xFFFF
    ret

count_digits_in_number:
    test rax, rax
    jz .zero_case
.digit_loop:
    xor rdx, rdx
    mov rdi, 10
    div rdi
    mov rsi, rdx
    shl rsi, 2
    inc dword [digit_count + rsi]
    test rax, rax
    jnz .digit_loop
    ret
.zero_case:
    inc dword [digit_count]
    ret

print_number:
    mov rsi, number_buf
    call number_str
    mov rsi, number_buf
    call print_str
    ret