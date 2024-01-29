format ELF64

SPEED = 20
WIDTH = 800
HEIGHT = 600

SQUAREWIDTH = 300
SQUAREHEIGHT = 100

KEY_RIGHT = 262
KEY_LEFT  = 263
KEY_DOWN  = 264
KEY_UP    = 265

section '.text' executable
public _start

extrn printf
extrn _exit
extrn InitWindow
extrn CloseWindow
extrn WindowShouldClose
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn DrawRectangle
extrn IsKeyDown
extrn DrawText
extrn SetTargetFPS
extrn sprintf

_start:
  mov rdi, WIDTH
  mov rsi, HEIGHT
  mov rdx, msg
  call InitWindow

	mov rdi, 60
	call SetTargetFPS

.loop:

	call BeginDrawing

	mov rdi, 0xFF0000FF
	call ClearBackground

	;RLAPI void DrawRectangle(int posX, int posY, int width, int height, Color color);                        // Draw a color-filled rectangle
	mov rdi, [position.x]
	mov rsi, [position.y]
	mov rdx, SQUAREWIDTH
	mov rcx, SQUAREHEIGHT
	mov r8d, 0xfff5f5f5
	call DrawRectangle

	mov rdi, buffer
	mov rsi, velocitystring
	mov rdx, [velocity.x]
	mov rcx, [velocity.y]
	call sprintf
	;RLAPI void DrawText(const char *text, int posX, int posY, int fontSize, Color color);       // Draw text (using default font)
	mov rdi, buffer
	mov rsi, 0
	mov rdx, 0
	mov rcx, 20
	mov r8d, 0xffffffff
	call DrawText

	call EndDrawing

macro CheckAndModifyDirection key, direction, dest {
    mov rdi, key
    call IsKeyDown
    direction dest, rax
}

	CheckAndModifyDirection KEY_RIGHT, add, qword [velocity.x]
	CheckAndModifyDirection KEY_LEFT,  sub, qword [velocity.x]
	CheckAndModifyDirection KEY_UP,    sub, qword [velocity.y]
	CheckAndModifyDirection KEY_DOWN,  add, qword [velocity.y]

macro checkboarders velocity, position, boarder, condition {
	mov rax, velocity
	mov rsi, position
	cmp rsi, boarder 
	condition @f
	;invert velocity
	mov rcx, -1
	imul rcx
	
	;reset position after collison
	mov rsi, boarder
	mov position, rsi
@@:;saving
	mov velocity, rax
}
	checkboarders [velocity.x], [position.x], WIDTH - SQUAREWIDTH, jl
	checkboarders [velocity.y], [position.y], HEIGHT - SQUAREHEIGHT, jl
	checkboarders [velocity.x], [position.x], 0, jg
	checkboarders [velocity.y], [position.y], 0, jg


	mov rax, [position.x]
	add rax, [velocity.x]
	mov [position.x], rax
	mov rax, [position.y]
	add rax, [velocity.y]
	mov [position.y], rax


	call WindowShouldClose
	test rax, rax
	jz .loop


  call CloseWindow
  xor rdi, rdi
  call _exit

section '.data'
msg: db "hello mom", 0

struc vec2 x,y {
  	.x dq x
		.y dq y
}
position vec2 100,100
velocity vec2 0,0

buffer: times 256 db 0
velocitystring: db "vx: %d, vy: %d", 0

