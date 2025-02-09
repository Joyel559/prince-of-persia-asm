
; Prince of Persia Clone in x86 Assembly (NASM)
; Runs in 320x200 256-color Mode 13h (Real-mode DOS)

org 100h  ; COM file format

section .data
    player_x db 20  ; Player X position
    player_y db 150 ; Player Y position
    player_dx db 1  ; X movement speed
    player_dy db 0  ; Y velocity for jumping/falling
    gravity db 2    ; Gravity effect
    ground_level db 150  ; Ground level

    screen_width db 320
    screen_height db 200

    jump_force db 10
    is_jumping db 0

    obstacle_x db 100
    obstacle_y db 150
    obstacle_width db 20
    obstacle_height db 10

    running db 1  ; Game loop flag

section .bss
    screen resb 64000  ; Off-screen buffer for smooth rendering

section .text
start:
    ; Set video mode to 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

game_loop:
    call read_input
    call apply_gravity
    call check_collision
    call update_player
    call draw_screen

    ; Check if game should continue
    cmp byte [running], 1
    je game_loop

exit_game:
    mov ax, 0x4C00
    int 0x21

; ------------------------------
; INPUT HANDLING
; ------------------------------
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
    cmp al, 0x1B  ; Escape key (exit)
    je quit_game

no_input:
    ret

move_left:
    dec byte [player_x]
    ret

move_right:
    inc byte [player_x]
    ret

jump:
    cmp byte [is_jumping], 1  ; Prevent mid-air jumps
    je end_jump

    mov byte [is_jumping], 1
    mov byte [player_dy], -10  ; Set upward velocity
end_jump:
    ret

quit_game:
    mov byte [running], 0
    ret

; ------------------------------
; PHYSICS ENGINE
; ------------------------------
apply_gravity:
    cmp byte [is_jumping], 1
    je apply_fall

    cmp byte [player_y], [ground_level]
    jge land
    jmp apply_fall

land:
    mov byte [player_y], [ground_level]
    mov byte [player_dy], 0
    mov byte [is_jumping], 0
    ret

apply_fall:
    add byte [player_dy], [gravity]
    add byte [player_y], [player_dy]
    cmp byte [player_y], [ground_level]
    jle stop_fall
    ret

stop_fall:
    mov byte [player_y], [ground_level]
    mov byte [player_dy], 0
    mov byte [is_jumping], 0
    ret

; ------------------------------
; COLLISION DETECTION
; ------------------------------
check_collision:
    ; Check horizontal collision
    mov al, [player_x]
    cmp al, [obstacle_x]
    jl no_collision
    cmp al, [obstacle_x]
    jg check_vertical_collision

no_collision:
    ret

check_vertical_collision:
    mov al, [player_y]
    cmp al, [obstacle_y]
    jl no_collision
    cmp al, [obstacle_y]
    jg no_collision

    ; If reached here, collision detected
    mov byte [player_x], 10  ; Reset player to start position
    ret

; ------------------------------
; GRAPHICS ENGINE
; ------------------------------
draw_screen:
    call clear_screen
    call draw_player
    call draw_obstacle
    ret

clear_screen:
    mov ah, 0x0C  ; Set pixel
    mov al, 0x00  ; Black color (background)
    mov cx, 0
    mov dx, 0
clear_loop:
    int 0x10
    inc cx
    cmp cx, 320
    jl clear_loop_x
    mov cx, 0
    inc dx
    cmp dx, 200
    jl clear_loop_x
    ret

clear_loop_x:
    jmp clear_loop

draw_player:
    mov ah, 0x0C  ; Set pixel
    mov al, 0x0F  ; White (player color)
    mov cx, [player_x]
    mov dx, [player_y]
    int 0x10
    ret

draw_obstacle:
    mov ah, 0x0C  ; Set pixel
    mov al, 0x04  ; Red (obstacle color)
    mov cx, [obstacle_x]
    mov dx, [obstacle_y]
draw_obstacle_loop:
    int 0x10
    inc cx
    cmp cx, [obstacle_x]
    jl draw_obstacle_loop_x
    mov cx, [obstacle_x]
    inc dx
    cmp dx, [obstacle_y]
    jl draw_obstacle_loop_x
    ret

draw_obstacle_loop_x:
    jmp draw_obstacle_loop

; ------------------------------
; GAME OVER HANDLER
; ------------------------------
game_over:
    mov ah, 0x09
    mov dx, game_over_msg
    int 0x21
    jmp exit_game

game_over_msg db 'Game Over!', 0

org 100h  ; COM file format

section .text
start:
    ; Set video mode to 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

main_loop:
    call read_input
    call apply_gravity
    call update_player
    call draw_screen
    jmp main_loop

exit_game:
    mov ax, 0x4C00
    int 0x21

org 100h  ; COM file format

section .data
    player_x db 10  ; Player X position
    player_y db 10  ; Player Y position
    gravity db 2    ; Gravity effect
    ground_level db 150  ; Ground level

section .text
start:
    ; Set video mode to 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

main_loop:
    call read_input
    call apply_gravity
    call update_player
    call draw_screen
    jmp main_loop

; Read keyboard input
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

apply_gravity:
    cmp byte [player_y], [ground_level]
    jge no_gravity
    add byte [player_y], [gravity]  ; Apply gravity
no_gravity:
    ret

; Draw the screen
; (For simplicity, clears the screen and prints player position as a dot)
draw_screen:
    mov ah, 0x0C  ; Set pixel
    mov al, 0x0F  ; White color
    mov cx, [player_x]
    mov dx, [player_y]
    int 0x10
    ret

; Simple delay function
delay:
    mov cx, 0xFFFF
wait_loop:
    loop wait_loop
    ret

exit_game:
    mov ax, 0x4C00
    int 0x21

; Additional features: Collision detection, animations, and obstacles
collision_detection:
    ; Placeholder for future collision handling
    ret

animate_player:
    ; Placeholder for player animations
    ret

handle_obstacles:
    ; Placeholder for obstacle logic
    ret

; Game over logic
game_over:
    mov ah, 0x09
    mov dx, game_over_msg
    int 0x21
    jmp exit_game

game_over_msg db 'Game Over!', 0
