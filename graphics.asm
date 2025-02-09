; Graphics & Rendering (graphics.asm)

section .text
draw_screen:
    mov ah, 0x0C  ; Set pixel
    mov al, 0x0F  ; White color
    mov cx, [player_x]
    mov dx, [player_y]
    int 0x10
    ret
