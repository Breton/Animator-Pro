;:ts=10

	TITLE   a1blit
_TEXT	SEGMENT  WORD PUBLIC 'CODE'
	extrn	clipblit:far
	extrn	_render_dot:far
	extrn	_render_bitmap_blit:far
_TEXT	ENDS
A1B_TEXT	SEGMENT  WORD PUBLIC 'CODE'
A1B_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: A1B_TEXT, DS: DGROUP, SS: DGROUP
A1B_TEXT      SEGMENT

	PUBLIC	_a1blit
;a1blit(wid, height, sx1,sy1,spt,snext_line, dx1,dy1,dpt,dnext_line, color,clip)
wid	equ 4+2
height	equ 6+2
sx1	equ 8+2
sy1	equ 10+2
spt_o	equ 12+2
spt_s	equ 14+2
snext	equ 16+2
dx1	equ 18+2
dy1	equ 20+2
dpt_o	equ 22+2
dpt_s	equ 24+2
dnext	equ 26+2
color	equ 28+2
_a1blit	PROC far
	push bp
	mov bp,sp
	push es
	push ds
	push si
	push di
	push bx
	push cx

	call FAR PTR clipblit
	jc za1


	;get starting source address in ds:si
	mov	ax,[bp+spt_s]
	mov	ds,ax
	mov	ax,[bp+sy1]
	mov	bx,[bp+snext]
	mul	bx	;y line offset in ax
	mov	bx,[bp+sx1]
	mov	cl,3
	shr	bx,cl	; += (sx1>>3)
	add	ax,bx	;start source offset in ax
	add	[bp+spt_o],ax ;save line start in spt_o


	;get starting destination address in es:di
	les	di,[bp+dpt_o]	
	mov	ax,[bp+dy1]
	mov	bx,[bp+dnext]
	mul	bx
	add	di,ax
	add	di,[bp+dx1]
	mov	[bp+dpt_o],di	;put line start in dpt_o

	;calculate start mask for line
	mov	cl,[bp+sx1]
	and	cl,7
	mov	dl,80h	;calculate initial mask
	shr	dl,cl	;and devote dl to it...

	mov	al,[bp+color]
	jmp	zabline
clipped:	jmp	za1
abline:
	mov	cx,[bp+wid]	;dot count in cx
	mov	dh,dl		;get mask into dh
	mov	si,[bp+spt_o]
	mov	di,[bp+dpt_o]
	mov	ah,[si]		;fetch 1st byte of source into ah
	inc	si
abpix:
	test	ah,dh
	jnz	abset
	inc	di	;skip pixel in dest
	shr	dh,1
	jz	newsrc
	loop	abpix
	jmp	zline
abset:	stosb		;set pixel in dest
	shr	dh,1
	jz	newsrc
	loop	abpix
zline:	mov	bx,[bp+snext]
	add	[bp+spt_o],bx
	mov	bx,[bp+dnext]
	add	[bp+dpt_o],bx
zabline:	dec	word ptr[bp+height]
	js	za1
	jmp	abline

newsrc:	;get next byte of source
	mov	ah,[si]		;fetch byte of source into ah
	inc	si
	mov	dh,80h		;mask to 1st pixel in byte
	loop	abpix
	jmp	zline

za1:
	pop cx
	pop bx
	pop di
	pop si
	pop ds
	pop es
	pop bp
	ret

_a1blit	ENDP


A1B_TEXT	ENDS
END
