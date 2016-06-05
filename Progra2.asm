;2 proyecto programado
;
;Implementacion del juego:
;		La liebre y los perros cazadores
;
;Esteban Bosques Mondol
;2013046970

section .bss

tablero resb 321
anchoTablero resw 1

section .data

msgError1 db 'Error! Formato del parametro no valido!',10,0
msgError2 db 'Error! Parametro fuera del rango!',10,'>> Rango permitido: [3,30]',10,0
msgError3 db 'Error! Debe ingresar el ancho del tablero!',10,'>> Formato: $ ./Progra2 [ancho del tablero (Min 3, Max 40)]',10,0


section .text

	extern printf				;'exporta' la funcion printf
	global main

main:

	nop
	push ebp
	mov ebp,esp
	
	mov ebx,[ebp+8]				;cantidad de parametros
	cmp ebx,1
	je errorNoParametros		;Verifico que el usuario haya ingresado al menos un parametro
	
	xor edx,edx
	mov eax,[ebp+12]			;inicio del vector
	mov ecx,dword[eax+4]		;guardo la direccion del primer parametro (largo del tablero)
	mov dx,word [ecx]
	
	call guardar_ancho
	
	cmp word[anchoTablero],30
	ja errorFueraRango
	cmp word[anchoTablero],3
	jb errorFueraRango

	call generarTablero

errorNoParametros:
	push ebp
	mov ebp,esp
	push msgError3
	call printf
	mov esp,ebp
	pop ebp
	jmp salir
	
errorFueraRango:
	push ebp
	mov ebp,esp
	push msgError2
	call printf
	mov esp,ebp
	pop ebp
	jmp salir
	
salir:
	mov esp,ebp
	pop ebp
	ret
	
;Subrutinas

generarTablero:
	xor eax,eax				;eax tendra la direccion a escribier en tablero
	xor ebx,ebx				;ebx tendra la cantidad maxima de caracteres por fila
	xor ecx,ecx				;ecx tendra la cantidad de caracteres escritos en la fila
	xor edx,edx				;edx tendra la cantidad de asteriscos escritos
	
	push dword 0			;en la pila va a estar la fila en la que estoy escribiendo
	
	mov ebx,[anchoTablero]
	add ebx,ebx
	add ebx,4
	
	mov eax,tablero

escribir:
	cmp dword[esp],0
	je fila_extremos
	
	cmp dword[esp],5 
	je fila_extremos
	
	cmp dword[esp],1
	je fila_uno
	
	cmp dword[esp],4
	je fila_cuatro
	
	cmp dword[esp],3
	je fila_medio

fila_extremos:
	mov byte [eax],'  '
	add eax,2
	jmp centro

fila_uno:
	mov byte [eax],' /'
	add eax,2
	jmp centro
	
fila_cuatro:
	mov byte [eax],' \\'
	add eax,2
	jmp centro

fila_medio:
	mov byte [eax],'*-'
	add eax,2
	
centro:
	
	
	ret
	
	
guardar_ancho:
	;como los parametros se interpretan como caracteres ascii
	;tengo que pasar esos caracteres a decimales, para eso hago un xor a cada caracter
	
	cmp dh,0
	je nulo
	cmp dh,30h
	jb error
	cmp dh,39h
	ja error
nulo:
	cmp dl,30h
	jb error
	cmp dl,39h
	ja error
	
	xor dl,30h
	xor dh,30h
	xor ecx,ecx
	
	cmp dh,30h						;verifico si el numero es menor que 10
								;en ese caso habria un 0 (30h) en el dh
	je menor_diez
	
	cmp dl,3						;verifico si el numero es menor que 10
								;en ese caso habria un 0 (30h) en el dh
	je treintas
	
	cmp dl,2						;verifico si el numero es 30 y algo
								;en ese caso habria un 3 (3h) en el dh
	je veintes
	
	mov cl,10
	add cl,dh
	mov [anchoTablero],cl
	ret
	
veintes:
	mov cl,20
	add cl,dh
	mov [anchoTablero],cl
	ret
	
treintas:
	mov cl,30
	add cl,dh
	mov [anchoTablero],cl
	ret
	
menor_diez:
	mov [anchoTablero],dl
	ret
	
error:
	push ebp
	mov ebp,esp
	push msgError1
	call printf
	mov esp,ebp
	pop ebp
	ret
	
	
	
	
	
	
