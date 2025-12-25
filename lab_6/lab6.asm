format ELF64

public _start


extrn initscr
extrn endwin
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn stdscr
extrn wmove
extrn waddch
extrn refresh
extrn getch
extrn noecho
extrn cbreak
extrn keypad
extrn nodelay
extrn COLOR_PAIR
extrn wattr_on
extrn wattr_off


extrn exit
extrn usleep

section '.bss' writable 
    xmax        dq 1
    ymax        dq 1
    x           dq 0
    y           dq 0
    direction   dq 1    
    current_color dq 1 
    delay_time  dq 100000 
    temp        dq 0

section '.data' writable
    COLOR_BLACK  equ 0
    COLOR_RED    equ 1
    COLOR_GREEN  equ 2
    COLOR_YELLOW equ 3
    COLOR_BLUE   equ 4
    COLOR_MAGENTA equ 5
    COLOR_CYAN   equ 6
    COLOR_WHITE  equ 7

section '.text' executable

_start:
    call initscr
    call start_color
    call noecho
    call cbreak
    
    mov rdi, [stdscr]
    mov rsi, 1
    call nodelay
    
    mov rdi, [stdscr]
    mov rsi, 1
    call keypad
    
    mov rdi, [stdscr]
    call getmaxx
    mov [xmax], rax
    call getmaxy
    mov [ymax], rax
    
    dec qword [xmax]
    dec qword [ymax]
    
    mov rdi, 1
    mov rsi, COLOR_RED
    mov rdx, COLOR_BLACK
    call init_pair
     
    mov rdi, 2
    mov rsi, COLOR_BLUE
    mov rdx, COLOR_BLACK
    call init_pair
    
    mov qword [x], 0
    mov qword [y], 0
    mov qword [direction], 1
    mov qword [current_color], 1
    
main_loop:
    call getch
    cmp rax, -1
    je no_input
    
    cmp rax, 'u'
    je exit_program
    cmp rax, 'U'
    je exit_program

    cmp rax, 'd'
    je increase_speed
    cmp rax, 'D'
    je increase_speed
    
no_input:
    mov rdi, [current_color]
    call COLOR_PAIR
    mov [temp], rax
    
    mov rdi, [stdscr]
    mov rsi, [y]
    mov rdx, [x]
    call wmove
    
    mov rdi, [stdscr]
    mov rsi, [temp]
    call wattr_on
    
    mov rdi, [stdscr]
    mov rsi, '#'     
    call waddch
    
    mov rdi, [stdscr]
    mov rsi, [temp]
    call wattr_off
    
    call refresh
    
    mov rdi, [delay_time]
    call usleep
    
    call move_cursor
    
    jmp main_loop

move_cursor:
    mov rax, [direction]
    add [y], rax
    
    mov rax, [y]
    mov rbx, [direction]
    
    cmp rbx, 1
    jne moving_up
    
moving_down:
    cmp rax, [ymax]
    jle move_done
    inc qword [x]
    mov qword [direction], -1
    mov rax, [ymax]
    mov [y], rax
    jmp check_right_bound
    
moving_up:
    cmp rax, 0
    jge move_done
    inc qword [x]
    mov qword [direction], 1
    mov qword [y], 0
    
check_right_bound:
    mov rax, [x]
    cmp rax, [xmax]
    jle move_done
    
    mov qword [x], 0
    mov qword [y], 0
    mov qword [direction], 1
    
    mov rax, [current_color]
    cmp rax, 1
    jne set_red
    mov qword [current_color], 2
    jmp move_done
set_red:
    mov qword [current_color], 1

move_done:
    ret

increase_speed:
    mov rax, [delay_time]
    cmp rax, 20000
    jle speed_done
    sub rax, 20000
    mov [delay_time], rax
speed_done:
    jmp no_input

exit_program:
    call endwin
    mov rdi, 0
    call exit