format ELF64 executable 3
entry start

segment readable writeable
prompt      db "cmd> ",0
msg_exit    db "Exiting launcher...",10,0
err_noexec  db "execve failed",10,0

sh_path     db "/bin/sh",0
sh_arg      db "-c",0

buffer      rb 512

segment readable executable

; ----------------- print string (rsi -> c-string) -------------------------
print_str:
    push    rdi
    push    rax
    xor     rax, rax
.find_len:
    cmp     byte [rsi + rax], 0
    je      .do_write
    inc     rax
    jmp     .find_len
.do_write:
    mov     rdi, 1
    mov     rdx, rax
    mov     rax, 1
    syscall
    pop     rax
    pop     rdi
    ret

; ----------------- read from stdin into buffer (rsi) ---------------------
read_line:
    mov     rdi, 0
    mov     rdx, 512
    mov     rax, 0
    syscall
    ret

; ----------------- simple exit ------------------------------------------
_exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

; ----------------- start -------------------------------------------------
start:
main_loop:
    ; print prompt
    mov     rsi, prompt
    call    print_str

    ; read line into buffer
    mov     rsi, buffer
    call    read_line            ; rax = bytes read

    ; if nothing read or just newline -> loop
    cmp     rax, 1
    jle     main_loop

    ; replace trailing newline '\n' with 0
    mov     rcx, rax
    dec     rcx
    mov     byte [buffer + rcx], 0

    ; trim trailing spaces, tabs and CR (\r = 13)
.trim_trail:
    ; find length (rcx currently index of last char or 0)
    ; compute len = strlen(buffer)
    xor     rdx, rdx
.trim_strlen_loop:
    cmp     byte [buffer + rdx], 0
    je      .got_len
    inc     rdx
    jmp     .trim_strlen_loop
.got_len:
    test    rdx, rdx
    jz      main_loop           ; empty after trimming -> repeat prompt
    dec     rdx                 ; rdx = index of last char
.trim_check_char:
    mov     al, [buffer + rdx]
    cmp     al, ' '
    je      .trim_drop
    cmp     al, 9               ; tab
    je      .trim_drop
    cmp     al, 13              ; CR
    je      .trim_drop
    jmp     .after_trim
.trim_drop:
    mov     byte [buffer + rdx], 0
    test    rdx, rdx
    jz      main_loop
    dec     rdx
    jmp     .trim_check_char
.after_trim:

    ; recompute length (could reuse earlier, but safe)
    xor     rax, rax
    mov     rsi, buffer
.len_loop:
    cmp     byte [rsi + rax], 0
    je      .len_done
    inc     rax
    jmp     .len_loop
.len_done:
    ; rax = length

    ; check for exact "exit"
    mov rsi, buffer
    cmp byte [rsi], 'e'
    jne .not_exit
    cmp byte [rsi+1], 'x'
    jne .not_exit  
    cmp byte [rsi+2], 'i'
    jne .not_exit
    cmp byte [rsi+3], 't'
    jne .not_exit
    cmp byte [rsi+4], 0
    jne .not_exit
    
.do_exit:
    mov rsi, msg_exit
    call print_str
    call _exit

.not_exit:
    ; fork
    mov     rax, 57
    syscall
    cmp     rax, 0
    je      .child_process

    ; parent: wait for child to finish (if you want non-blocking, remove this block)
    mov     rdi, rax     ; pid from fork
    mov     rax, 61      ; wait4
    xor     rsi, rsi
    xor     rdx, rdx
    xor     r10, r10
    syscall

    jmp     main_loop

; ---------------- child: exec via /bin/sh -c "buffer" --------------------
.child_process:
    ; build argv: ["/bin/sh", "-c", buffer, NULL]
    xor     rax, rax
    push    rax                ; argv[3] = NULL

    lea     rax, [buffer]
    push    rax                ; argv[2] = buffer

    lea     rax, [sh_arg]
    push    rax                ; argv[1] = "-c"

    lea     rax, [sh_path]
    push    rax                ; argv[0] = "/bin/sh"

    mov     rsi, rsp           ; rsi -> argv
    lea     rdi, [sh_path]     ; rdi -> filename "/bin/sh"
    xor     rdx, rdx           ; envp = NULL

    mov     rax, 59            ; execve
    syscall

    ; if execve returned -> error; print message and exit with status 1
    mov     rsi, err_noexec
    call print_str
    mov     rax, 60
    mov     rdi, 1
    syscall