format ELF64
public _start

extrn initscr
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn stdscr
extrn getch
extrn refresh
extrn endwin
extrn timeout
extrn erase
extrn curs_set
extrn mvaddch

section '.bss' writable
    xmax_actual dq 1      ; Физическая ширина экрана
    ymax_actual dq 1      ; Физическая высота экрана
    virtual_xmax dq 1     ; Виртуальная ширина (xmax_actual * 10)
    virtual_ymax dq 1     ; Виртуальная высота (ymax_actual * 10)
    current_x_virtual dq 0  ; Текущая виртуальная X-координата
    current_y_virtual dq 0  ; Текущая виртуальная Y-координата
    mode db 0             ; 0 = top-left to bottom-right, 1 = bottom-left to top-right
    delay_ms dq 100       ; Задержка между шагами в миллисекундах
    scale_factor dq 10    ; Коэффициент масштабирования

section '.text' executable
_start:
    call initscr
    
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [xmax_actual], rax
    
    mov rdi, [stdscr]
    call getmaxy
    dec rax
    mov [ymax_actual], rax
    
    mov rax, [xmax_actual]
    mov rbx, [scale_factor]
    mul rbx
    mov [virtual_xmax], rax
    
    mov rax, [ymax_actual]
    mov rbx, [scale_factor]
    mul rbx
    mov [virtual_ymax], rax
    
    call raw
    call noecho
    xor rdi, rdi          
    call curs_set

    mov qword [current_x_virtual], 0
    mov qword [current_y_virtual], 0
    mov byte [mode], 0
    mov qword [delay_ms], 100  

.main_loop:
    call erase
    
    mov rax, [current_x_virtual]
    mov rbx, [scale_factor]
    xor rdx, rdx
    div rbx               
    mov rsi, rax            
    
    mov rax, [current_y_virtual]
    mov rbx, [scale_factor]
    xor rdx, rdx
    div rbx              
    mov rdi, rax            
    
    mov rdx, '*'          
    call mvaddch
    
    call refresh

    mov rdi, [delay_ms]
    call timeout
    
    call getch
    mov rbx, rax            
    
 
    cmp rax, 'q'
    je .end_program
    
    cmp rax, '+'
    je .increase_speed
    
    cmp rax, '-'
    je .decrease_speed
    
    jmp .after_key_handling

.increase_speed:
    mov rax, [delay_ms]
    sub rax, 10
    cmp rax, 1
    jge @f
    mov rax, 1
@@:
    mov [delay_ms], rax
    jmp .after_key_handling

.decrease_speed:
    mov rax, [delay_ms]
    add rax, 10
    cmp rax, 1000
    jle @f
    mov rax, 1000
@@:
    mov [delay_ms], rax

.after_key_handling:
    cmp byte [mode], 0
    je .mode0_update

.mode1_update:
    mov rax, [current_x_virtual]
    cmp rax, [virtual_xmax]
    jge .mode1_skip_x
    inc qword [current_x_virtual]
.mode1_skip_x:

    mov rax, [current_y_virtual]
    test rax, rax
    jz .mode1_skip_y
    dec qword [current_y_virtual]
.mode1_skip_y:
    jmp .check_switch

.mode0_update:
    mov rax, [current_x_virtual]
    cmp rax, [virtual_xmax]
    jge .mode0_skip_x
    inc qword [current_x_virtual]
.mode0_skip_x:

    mov rax, [current_y_virtual]
    cmp rax, [virtual_ymax]
    jge .mode0_skip_y
    inc qword [current_y_virtual]
.mode0_skip_y:

.check_switch:
    cmp byte [mode], 0
    je .check_mode0


.check_mode1:
    mov rax, [current_x_virtual]
    cmp rax, [virtual_xmax]
    jne .no_switch
    mov rax, [current_y_virtual]
    test rax, rax
    jnz .no_switch
    
    mov byte [mode], 0
    mov qword [current_x_virtual], 0
    mov qword [current_y_virtual], 0
    jmp .main_loop

.check_mode0:
    mov rax, [current_x_virtual]
    cmp rax, [virtual_xmax]
    jne .no_switch
    mov rax, [current_y_virtual]
    cmp rax, [virtual_ymax]
    jne .no_switch
    
    mov byte [mode], 1
    mov qword [current_x_virtual], 0
    mov rax, [virtual_ymax]
    mov [current_y_virtual], rax
    jmp .main_loop

.no_switch:
    jmp .main_loop

.end_program:
    call endwin
    mov rax, 60    
    xor rdi, rdi   
    syscall