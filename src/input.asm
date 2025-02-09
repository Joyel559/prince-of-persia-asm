; Input Handling (input.asm)

section .text
read_input:
    mov ah, 0x01  ; Check for key press
    int 0x16
    jz no_input

    mov ah, 0x00  ; Get key
    int 0x16
    
    cmp al, 0x4B  ; Left arrow
    je move_left
    cmp al, 0x4D  ; Right arrow
    je move_right
    cmp al, 0x48  ; Up arrow (jump)
    je jump
    cmp al, 0x1B  ; Escape key
    je exit_game

no_input:
    ret
