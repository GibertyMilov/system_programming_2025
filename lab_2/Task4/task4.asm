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
    mov byte [rdi], 0x0A    ; перевод строки
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

    lea rsi, [rdi + 1]              ; адрес начала числа
    mov rdx, buf + 32
    sub rdx, rsi         ; длина

    ;-----------------------------------------
    ; write(1, rsi, rdx) через int 0x80
    ; eax = 4, ebx = 1, ecx = buf, edx = len
    ;-----------------------------------------
    mov eax, 4
    mov ebx, 1
    mov ecx, esi        ; младшие 32 бита адреса
    shr rsi, 32         ; старшие 32 бита адреса
    mov edx, edx        ; (len помещается в edx автоматически из rdx низких 32)
    int 0x80

    ;-----------------------------------------
    ; exit(0) через int 0x80
    ; eax = 1, ebx = 0
    ;-----------------------------------------
    mov eax, 1
    xor ebx, ebx
    int 0x80

