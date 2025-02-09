; Player Movement & Physics (player.asm)

section .data
    player_x db 10  ; Player X position
    player_y db 10  ; Player Y position
    gravity db 2    ; Gravity effect
    ground_level db 150  ; Ground level

section .text
apply_gravity:
    cmp byte [player_y], [ground_level]
    jge no_gravity
    add byte [player_y], [gravity]  ; Apply gravity
no_gravity:
    ret

move_left:
    dec byte [player_x]
    ret

move_right:
    inc byte [player_x]
    ret

jump:
    sub byte [player_y], 10  ; Move up
    call delay
    call delay
    add byte [player_y], 10  ; Move back down
    ret
