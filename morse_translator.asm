; Morse Code Encoder/Decoder in NASM Assembly
; Modern 64-bit Linux version
; Modified to properly handle spaces between words

section .data
    ; Welcome and menu messages
    welcome_msg     db "Morse Code Encoder/Decoder", 10, 0
    menu_msg        db 10, "1. Text to Morse", 10, "2. Morse to Text", 10, "3. Exit", 10, "Enter choice: ", 0
    input_prompt    db 10, "Enter input: ", 0
    output_msg      db 10, "Output: ", 0
    error_msg       db 10, "Invalid input!", 10, 0
    newline         db 10, 0
    
    ; Buffers for input and output
    input_buffer    times 256 db 0
    output_buffer   times 512 db 0
    
    ; Special Morse code characters
    morse_space     db "/", 0      ; Use "/" to represent word spaces in Morse
    
    ; Morse code table - each character followed by its Morse code representation
    morse_table:
        db "A", ".-", 0
        db "B", "-...", 0
        db "C", "-.-.", 0
        db "D", "-..", 0
        db "E", ".", 0
        db "F", "..-.", 0
        db "G", "--.", 0
        db "H", "....", 0
        db "I", "..", 0
        db "J", ".---", 0
        db "K", "-.-", 0
        db "L", ".-..", 0
        db "M", "--", 0
        db "N", "-.", 0
        db "O", "---", 0
        db "P", ".--.", 0
        db "Q", "--.-", 0
        db "R", ".-.", 0
        db "S", "...", 0
        db "T", "-", 0
        db "U", "..-", 0
        db "V", "...-", 0
        db "W", ".--", 0
        db "X", "-..-", 0
        db "Y", "-.--", 0
        db "Z", "--..", 0
        db "0", "-----", 0
        db "1", ".----", 0
        db "2", "..---", 0
        db "3", "...--", 0
        db "4", "....-", 0
        db "5", ".....", 0
        db "6", "-....", 0
        db "7", "--...", 0
        db "8", "---..", 0
        db "9", "----.", 0
        db ".", ".-.-.-", 0
        db ",", "--..--", 0
        db "?", "..--..", 0
        db "!", "-.-.--", 0
        db " ", "/", 0      ; Space is represented as "/" in Morse
        db 0                ; End of table marker

section .bss
    choice          resb 4    ; For storing user menu choice

section .text
    global _start

_start:
    ; Display welcome message
    mov rdi, welcome_msg
    call print_string
    
menu_loop:
    ; Display menu
    mov rdi, menu_msg
    call print_string
    
    ; Get user choice
    mov rdi, choice
    mov rsi, 4            ; Read up to 4 bytes (character + newline + extra space)
    call read_input
    
    ; Process choice
    mov al, [choice]
    cmp al, '1'
    je text_to_morse
    cmp al, '2'
    je morse_to_text
    cmp al, '3'
    je exit_program
    
    ; Invalid choice, display error
    mov rdi, error_msg
    call print_string
    jmp menu_loop
    
text_to_morse:
    ; Get input text
    mov rdi, input_prompt
    call print_string
    
    ; Clear input buffer first
    mov rdi, input_buffer
    mov rcx, 256
    xor rax, rax
    rep stosb
    
    mov rdi, input_buffer
    mov rsi, 255           ; Max input size (reserve 1 for null)
    call read_input
    
    ; Convert text to Morse
    call convert_text_to_morse
    
    ; Display result
    mov rdi, output_msg
    call print_string
    mov rdi, output_buffer
    call print_string
    mov rdi, newline
    call print_string
    
    jmp menu_loop
    
morse_to_text:
    ; Get input Morse code
    mov rdi, input_prompt
    call print_string
    
    ; Clear input buffer first
    mov rdi, input_buffer
    mov rcx, 256
    xor rax, rax
    rep stosb
    
    mov rdi, input_buffer
    mov rsi, 255           ; Max input size (reserve 1 for null)
    call read_input
    
    ; Convert Morse to text
    call convert_morse_to_text
    
    ; Display result
    mov rdi, output_msg
    call print_string
    mov rdi, output_buffer
    call print_string
    mov rdi, newline
    call print_string
    
    jmp menu_loop
    
exit_program:
    ; Exit the program with status code 0
    mov rax, 60        ; syscall: exit
    xor rdi, rdi       ; status: 0
    syscall

; Function to print a null-terminated string
; Input: RDI = address of string to print
print_string:
    ; Calculate string length
    mov rcx, rdi           ; Copy start address
    
str_len_loop:
    cmp byte [rcx], 0      ; Look for null terminator
    je str_len_done
    inc rcx
    jmp str_len_loop
    
str_len_done:
    sub rcx, rdi           ; RCX = string length
    
    ; Write string to stdout
    mov rdx, rcx           ; RDX = length
    mov rsi, rdi           ; RSI = string address
    mov rdi, 1             ; RDI = file descriptor (stdout)
    mov rax, 1             ; RAX = syscall number (write)
    syscall
    
    ret

; Function to read input from user
; RDI = buffer address, RSI = maximum length
read_input:
    ; Read input
    push rdi               ; Save buffer address
    mov rdx, rsi           ; RDX = maximum length
    mov rsi, rdi           ; RSI = buffer address
    mov rdi, 0             ; RDI = file descriptor (stdin)
    mov rax, 0             ; RAX = syscall number (read)
    syscall
    
    ; RAX now contains number of bytes read
    pop rdi                ; Restore buffer address
    
    ; Replace newline with null terminator
    dec rax                ; Ignore the newline
    mov byte [rdi + rax], 0
    
    ret

; Function to convert text to Morse code
convert_text_to_morse:
    ; Clear output buffer
    push rdi               ; Save registers
    push rsi
    push rcx
    
    mov rdi, output_buffer
    mov rcx, 512
    xor rax, rax
    rep stosb
    
    pop rcx                ; Restore registers
    pop rsi
    pop rdi
    
    ; Set up source and destination pointers
    mov rsi, input_buffer
    mov rdi, output_buffer
    
process_text:
    ; Get next character
    movzx rax, byte [rsi]
    test rax, rax         ; Check for end of string
    jz end_text_conversion
    
    ; Convert lowercase to uppercase
    cmp al, 'a'
    jl not_lowercase
    cmp al, 'z'
    jg not_lowercase
    sub al, 32            ; Convert to uppercase
    
not_lowercase:
    ; Find character in Morse table
    push rsi              ; Save input pointer
    push rdi              ; Save output pointer
    
    mov rbx, morse_table  ; RBX points to morse table
    
find_in_table:
    cmp byte [rbx], 0     ; End of table
    je char_not_found
    
    cmp al, [rbx]         ; Compare with table entry
    je char_found
    
    ; Skip to next entry
    inc rbx               ; Skip character
    
skip_morse:
    cmp byte [rbx], 0     ; Look for the null terminator
    je next_entry
    inc rbx
    jmp skip_morse
    
next_entry:
    inc rbx               ; Skip the null terminator
    jmp find_in_table
    
char_found:
    inc rbx               ; Move to Morse code
    
copy_morse:
    movzx rax, byte [rbx]
    test rax, rax         ; Check for end of Morse code
    jz end_copy_morse
    
    mov [rdi], al         ; Copy to output buffer
    inc rdi
    inc rbx
    jmp copy_morse
    
end_copy_morse:
    pop rdx               ; Original output pointer (discard)
    pop rsi               ; Restore input pointer
    
    ; Add space between characters (only if not at the end of input)
    cmp byte [rsi+1], 0   ; Check if next char is end of string
    je skip_space         ; If end of string, don't add space
    
    mov byte [rdi], ' '
    inc rdi
    
skip_space:
    inc rsi               ; Next input character
    jmp process_text
    
char_not_found:
    pop rdi               ; Restore output pointer
    pop rsi               ; Restore input pointer
    inc rsi               ; Skip unrecognized character
    jmp process_text
    
end_text_conversion:
    ; Ensure null termination
    mov byte [rdi], 0
    ret

; Function to convert Morse code to text
convert_morse_to_text:
    ; Clear output buffer
    push rdi               ; Save registers
    push rsi
    push rcx
    
    mov rdi, output_buffer
    mov rcx, 512
    xor rax, rax
    rep stosb
    
    pop rcx                ; Restore registers
    pop rsi
    pop rdi
    
    ; Set up source and destination pointers
    mov rsi, input_buffer
    mov rdi, output_buffer
    
    ; Skip leading spaces
skip_leading:
    cmp byte [rsi], ' '
    jne process_morse
    inc rsi
    jmp skip_leading
    
process_morse:
    ; Check for end of input
    cmp byte [rsi], 0
    je end_morse_conversion
    
    ; Check for word separator "/"
    cmp byte [rsi], '/'
    je handle_word_space
    
    ; Mark start of current Morse code
    mov rdx, rsi          ; RDX = start of current code
    
find_code_end:
    cmp byte [rsi], ' '
    je code_end_found
    cmp byte [rsi], 0
    je code_end_found
    inc rsi
    jmp find_code_end
    
code_end_found:
    ; Temporarily mark end of code
    movzx rcx, byte [rsi] ; Save character at end
    mov byte [rsi], 0     ; Null-terminate current code
    
    ; Search for code in table
    push rsi              ; Save current position
    push rdi              ; Save output position
    push rcx              ; Save end character
    
    mov rbx, morse_table
    
find_morse_in_table:
    cmp byte [rbx], 0     ; End of table
    je morse_not_found
    
    ; Save character
    movzx r9, byte [rbx]
    inc rbx               ; Point to Morse code
    
    ; Compare current Morse code with table entry
    mov rsi, rdx          ; Input code start
    
compare_morse:
    movzx rax, byte [rsi]
    movzx r8, byte [rbx]
    
    test rax, rax         ; End of input code?
    jz check_table_end
    
    test r8, r8           ; End of table code?
    jz morse_not_match
    
    cmp al, r8b           ; Compare characters
    jne morse_not_match
    
    inc rsi
    inc rbx
    jmp compare_morse
    
check_table_end:
    test r8, r8           ; End of table code?
    jz morse_match        ; Both ended = match
    
morse_not_match:
    ; Skip to next entry in table
    dec rbx               ; Go back to start of current entry
skip_to_next:
    cmp byte [rbx], 0     ; Look for null terminator
    je next_morse_entry
    inc rbx
    jmp skip_to_next
    
next_morse_entry:
    inc rbx               ; Skip null terminator
    jmp find_morse_in_table
    
morse_match:
    ; Get corresponding character (saved in R9)
    pop rcx               ; Restore end character
    pop rdi               ; Restore output position
    pop rsi               ; Restore input position
    
    ; Add character to output
    mov [rdi], r9b
    inc rdi
    jmp restore_and_continue
    
morse_not_found:
    pop rcx               ; Restore end character
    pop rdi               ; Restore output position  
    pop rsi               ; Restore input position
    
restore_and_continue:
    ; Restore the space or null
    mov [rsi], cl         ; Restore character
    
    ; If we reached end of string, finish
    test cl, cl
    jz end_morse_conversion
    
    ; Skip spaces between Morse codes
    inc rsi               ; Move past the space/terminator
    
skip_spaces:
    cmp byte [rsi], ' '
    jne process_morse     ; Not a space, process next code
    inc rsi               ; Skip space
    jmp skip_spaces

handle_word_space:
    ; Add space to output text
    mov byte [rdi], ' '
    inc rdi
    
    ; Skip past the "/"
    inc rsi
    
    ; Skip any spaces after the "/"
    jmp skip_spaces
    
end_morse_conversion:
    ; Ensure null termination
    mov byte [rdi], 0
    ret
