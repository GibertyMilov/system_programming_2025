format elf64
public _start

section '.data' writable
    usage db 'Usage: program <character>', 0x0A, 0
    ascii_msg db 'ASCII code: ', 0
    newline db 0x0A, 0

section '.bss' writable
    buffer rb 16
    char rb 2

section '.text' executable

_start:
    ; Получаем аргументы командной строки
    pop rcx         ; количество аргументов
    cmp rcx, 2      ; проверяем, есть ли параметр (программа + символ)
    jl .show_usage  ; если меньше 2 - показываем использование

    ; Получаем первый параметр (символ)
    pop rsi         ; пропускаем имя программы
    pop rsi         ; получаем первый аргумент (символ)
    
    ; Копируем первый символ параметра
    mov al, [rsi]   ; берем первый символ аргумента
    mov [char], al  ; сохраняем символ
    mov byte [char+1], 0 ; добавляем нуль-терминатор

    ; Выводим сообщение "ASCII code: "
    mov rsi, ascii_msg
    call print_str

    ; Преобразуем ASCII-код в строку и выводим
    movzx rax, byte [char] ; загружаем символ с нулевым расширением
    mov rsi, buffer
    call number_str
    call print_str

    ; Новая строка
    call new_line

    call exit

.show_usage:
    mov rsi, usage
    call print_str
    call exit

; =============================================
; ФУНКЦИЯ ВЫХОДА ИЗ ПРОГРАММЫ
; =============================================
exit:
    mov rax, 60     ; номер системного вызова exit
    mov rdi, 0      ; код возврата 0
    syscall
    ret

; =============================================
; ФУНКЦИЯ ВЫВОДА СТРОКИ
; Вход: RSI - указатель на строку
; =============================================
print_str:
    push rax
    push rdi
    push rdx
    push rcx
    push rsi
    
    ; Вычисляем длину строки
    mov rdi, rsi    ; сохраняем указатель
    call len_str    ; получаем длину в RAX
    
    ; Выполняем системный вызов write
    mov rdx, rax    ; длина строки
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    syscall
    
    pop rsi
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

; =============================================
; ФУНКЦИЯ ВЫЧИСЛЕНИЯ ДЛИНЫ СТРОКИ
; Вход: RDI - указатель на строку
; Выход: RAX - длина строки
; =============================================
len_str:
    push rdi
    mov rax, 0      ; счетчик длины
    
.loop:
    cmp byte [rdi + rax], 0 ; проверяем текущий символ
    je .end                 ; если 0 - конец строки
    inc rax                 ; увеличиваем счетчик
    jmp .loop
    
.end:
    pop rdi
    ret

; =============================================
; ФУНКЦИЯ ПРЕОБРАЗОВАНИЯ ЧИСЛА В СТРОКУ
; Вход: RAX - число, RSI - буфер для строки
; =============================================
number_str:
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rbx, 10     ; основание системы счисления
    xor rcx, rcx    ; счетчик цифр
    
    ; Проверка на ноль
    test rax, rax
    jnz .convert
    
    ; Если число ноль
    mov byte [rsi], '0'
    mov byte [rsi+1], 0
    jmp .end
    
.convert:
    ; Извлекаем цифры и сохраняем в стек
.digit_loop:
    xor rdx, rdx    ; обнуляем для деления
    div rbx         ; RDX:RAX / 10, остаток в RDX
    add dl, '0'     ; преобразуем цифру в символ
    push rdx        ; сохраняем в стек
    inc rcx         ; увеличиваем счетчик цифр
    test rax, rax   ; проверяем, закончилось ли число
    jnz .digit_loop
    
    ; Извлекаем цифры из стека в правильном порядке
    mov rdi, rsi    ; используем RDI как указатель
.store_loop:
    pop rax         ; извлекаем символ
    mov [rdi], al   ; записываем в буфер
    inc rdi         ; следующий байт
    loop .store_loop ; повторяем RCX раз
    
    ; Добавляем нуль-терминатор
    mov byte [rdi], 0
    
.end:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; =============================================
; ФУНКЦИЯ ВЫВОДА НОВОЙ СТРОКИ
; =============================================
new_line:
    push rax
    push rdi
    push rsi
    push rdx
    
    ; Создаем строку с символом новой строки в стеке
    mov rax, 0xA    ; символ новой строки
    push rax        ; помещаем в стек
    
    ; Выводим символ новой строки
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, rsp    ; указатель на данные в стеке
    mov rdx, 1      ; длина 1 символ
    syscall
    
    ; Восстанавливаем стек
    pop rax
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret