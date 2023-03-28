[BITS    16]
[ORG 0x7C00]

WSCREEN equ 320
HSCREEN equ 200

call setup
call palette

setup:
		mov ah, 0x00
		mov al, 0x13
		int 0x10

		mov ax, 0xA000
		mov es, ax
		
		mov ah, 0x0C

		xor al, al   ;AL = Color
		xor bx, bx   ;BX = Page
		xor cx, cx   ;CX = X
		mov dx, 0x08 ;DX = Y
		
		call text
		
		ret

;-------------------------------------			
		
reset:	
		xor cx, cx
		mov dx, 0x08
		inc word [color]
		
		palette:
				mov word [x], cx
				mov word [y], dx
		
				cmp word [color], 2048
				ja crash
				
				;cmp word [color], 1792
				;ja circles
				
				;cmp word [color], 1536
				;ja sierpinski
		
				;cmp word [color], 1280
				;ja squares
		
		        cmp word [color], 1024
				ja parabola
		
				cmp word [color], 768
				ja hearts
				
				cmp word [color], 512
				ja stars
				
				cmp word [color], 256
				ja xorfractal
				
				cmp word [color], 30
				ja scroll
				jb statics
				
				setpixel:
						cmp cx, WSCREEN
						jae nextline
						
						cmp dx, HSCREEN
						jae reset

						int 0x10

						inc cx
						jmp palette
						
						ret

;-------------------------------------	

statics:
		fild word [y]
		fdiv dword [a]
		fstp dword [b]
		
		;A = sin(A)
		fild dword [x]
		fsin
		fstp dword [x]
		
		mov al, [x]
		add al, [color]
		add al, [color]
		add al, [color]
		
		jmp GRAY

scroll:
        mov bp, cx
        add bp, [color]
        
        mov bx, bp
        add bl, [color]
        shr bl, 2
        
        mov al, bl
        shr al, 1
		
		jmp HSV

xorfractal:
        mov bx, cx
        xor bx, dx
        
        add bl, [color]
        mov al, bl
        shr al, 2 ;div 4
		;inc word [color]
        
        jmp HSV
		
stars:
		push ax
			add bx, cx
				
			mov ax, cx
			xor ax, dx
			xor ax, cx
				
			sub bl, al
		pop ax
        
        mov al, bl
        shr al, 2
		
		jmp GRAY
		
hearts:
        push ax
            add bx, cx
            
            mov ax, cx
            xor ax, dx
            
            sub bl, al
        pop ax
        
        mov al, bl
        shr al, 2
		
		jmp HSV
		
parabola:
        add bx, cx
        
        add bl, [color]
        mov al, bl
        shr al, 2
		
		jmp HSV
		
squares:
		fild word [x]
		fmul dword [y]
		fstp dword [x]

		mov al, [x]
		add al, [color]
		shr al, 2
		
		jmp HSV
		
		
sierpinski:
		mov bx, cx
        and bx, dx
        
        add bl, [color]
        mov al, bl
        shr al, 2
        
        jmp HSV
		
circles:
		mov word [zx], cx
		mov word [zy], dx

        ;A = X * X 
        fild dword [zx]
        fmul dword [zx]
        fstp dword [a]
        
        ;B = Y * Y
        fild dword [zy]
        fmul dword [zy]
        fstp dword [b]
        
        ;B = A + B
        mov bx, word [a]
        add word [b], bx
        
        mov al, [b]
        shr al, 3
        
        sub al, [color]
		
		jmp HSV
		
crash:
		shr al, 2
	    shr al, 2
	    dec al
		
		out dx, al
		
;-------------------------------------	
		
HSV:
		cmp al, 55
        ja delhsv
        
        cmp al, 32
        jb addhsv
		
		jmp setpixel

delhsv:
        sub al, 16
        jmp HSV
        
addhsv:
        add al, 32
        jmp HSV
		
;-------------------------------------			
		
GRAY:
		cmp al, 31
        ja delgray
        
        cmp al, 16
        jb addgray
		
		jmp setpixel
		
delgray:
		sub al, 16
        jmp GRAY

addgray:
		add al, 32
        jmp GRAY
		
;-------------------------------------	
                
nextline:
                xor cx, cx
                inc dx

                jmp palette 
						
;-------------------------------------	

text:	
		push ax
		push bx
		push cx
		push dx

		mov ax, cx
		mov ds, ax

		mov ah, 0x0E
		
		mov si, string
		mov al, [si]
		
		mov bh, 0x00
		
		returnFirstColor:
				mov bl, 32
				printLoop:
						inc bl
						
						cmp bl, 55
						je returnFirstColor
				
						int 10h
						
						rep stosw
						
						inc si
						mov al, [si]
						
						
						cmp al, 0x00
						jnz printLoop

						pop dx
						pop cx
						pop bx
						pop ax						
						
						ret

;-------------------------------------	

string: db "IT LOOKS LIKE YOU'RE HAVING A BAD DREAM!", 0x00
color: dw 0		

x: dw 0
y: dw 0

zx: dd 0.0
zy: dd 0.0

a: dd 0.0
b: dd 0.0
			
times 1022 - ($ - $$) db 0
dw 0xAA55