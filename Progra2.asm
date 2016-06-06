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

perro1 db '1,1'
perro2 db '0,2'				;columna,fila
perro3 db '1,3'
liebre db '31,2'

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
	
	call contar_parametros
	
	xor edx,edx
	mov eax,[ebp+12]			;inicio del vector
	mov ecx,dword[eax+4]		;guardo la direccion del primer parametro (largo del tablero)
	mov dx,word [ecx]
	
	call guardar_ancho
	call verif_parametro
	call generarTablero
	
	call imprimir_tablero
	
	jmp salir


	
salir:
	mov esp,ebp
	pop ebp
	ret
	
;Subrutinas

generarTablero:
	xor eax,eax				;eax tendra la direccion a escribir en tablero
	xor ebx,ebx				;ebx tendra la fila en la que estoy escribiendo
	xor ecx,ecx				;ecx tendra la cantidad de asteriscos escritos
	xor edx,edx				;edx tendra la cantidad de 'perros' colocados
	
	;push dword 0			;en la pila va a estar la fila en la que estoy escribiendo
	
	;mov ebx,[anchoTablero]
	;add ebx,ebx
	;add ebx,4
	
	mov eax,tablero

escribir:
	cmp ebx,0
	je fila_extremos_inicio
								;Averigua si voy a escribir en una fila de los extremos
	cmp ebx,4 
	je fila_extremos_inicio
	
	cmp ebx,1
	je fila_uno_inicio
								;Averigua si voy a escribir en una fila de los extremos medios
	cmp ebx,3
	je fila_tres_inicio
	
	cmp ebx,2
	je fila_medio_inicio				;Averigua si voy a escribir en la fila del centro

fila_extremos_inicio:
	mov word [eax],'  '
	add eax,2							;Muevo el puntero 2 bytes
	jmp casillas

fila_uno_inicio:
	mov word [eax],' /'
	add eax,2							;Muevo el puntero 2 bytes
	jmp espacios
	
fila_tres_inicio:
	mov word [eax],' \'
	add eax,2							;Muevo el puntero 2 bytes
	jmp espacios

fila_medio_inicio:
	mov word [eax],'2-'
	add eax,2							;Muevo el puntero 2 bytes
	inc edx
	jmp casillas
	
casillas:
	inc edx
	
	cmp ebx,2
	je centro
	
	xor dl,30h
	mov byte [eax],dl
	mov byte [eax+1],'-'
	xor dl,30h
	
	cmp ecx,0
	je perro

centro:									;Salto a esta etiqueta si estoy en la fila del centro
	mov word [eax],'*-'
	dec edx
	
perro:									;salto a esta etiqueta si hay que colocar un perro
	add eax,2
	inc ecx
	
	cmp cx,word [anchoTablero]
	jne casillas
	
	xor ecx,ecx
	
	dec eax
	
	jmp finales

espacios:
	mov word [eax],'|X'
	add eax,2
	inc ecx
	
	cmp cx,word [anchoTablero]
	jne espacios
	
	xor ecx,ecx
	
	dec eax
	
	jmp finales

finales:
	cmp ebx,0
	je fila_extremos_fin
								;Averigua si voy a escribir en una fila de los extremos
	cmp ebx,4 
	je fila_extremos_fin
	
	cmp ebx,1
	je fila_uno_fin
								;Averigua si voy a escribir en una fila de los extremos medios
	cmp ebx,3
	je fila_tres_fin
	
	cmp ebx,2
	je fila_medio_fin				;Averigua si voy a escribir en la fila del centro
	
fila_extremos_fin:
	mov word [eax],'  '
	add eax,2							;Muevo el puntero 2 bytes
	mov byte [eax],10					;ingreso el enter
	inc eax
	inc ebx
	
	cmp ebx,5							;averiguo si es la ultima fila
	jne escribir
	
	mov byte [eax],0					;si es la ultima fila agrego un caracter nulo
	ret

fila_uno_fin:
	mov word [eax],'\ '
	add eax,2							;Muevo el puntero 2 bytes
	mov byte [eax],10
	inc eax
	inc ebx
	jmp escribir
	
fila_tres_fin:
	mov word [eax],'/ '
	add eax,2							;Muevo el puntero 2 bytes
	mov byte [eax],10
	inc eax
	inc ebx
	jmp escribir

fila_medio_fin:
	mov word [eax],'-L'
	add eax,2							;Muevo el puntero 2 bytes
	mov byte [eax],10
	inc eax
	inc ebx
	jmp escribir
	
	
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
	
imprimir_tablero:
	push ebp
	mov ebp,esp
	
	push tablero
	call printf
	
	mov esp,ebp
	pop ebp
	ret

verif_parametro:
	cmp word[anchoTablero],30
	ja errorFueraRango
	cmp word[anchoTablero],3
	jb errorFueraRango
	ret

contar_parametros:
	mov ebx,[ebp+8]				;cantidad de parametros
	cmp ebx,1
	je errorNoParametros		;Verifico que el usuario haya ingresado al menos un parametro
	ret
	
errorNoParametros:
	push ebp
	mov ebp,esp
	push msgError3
	call printf
	mov esp,ebp
	pop ebp
	pop	eax						;Elimino la direccion de retorno
	jmp salir
	
errorFueraRango:
	push ebp
	mov ebp,esp
	push msgError2
	call printf
	mov esp,ebp
	pop ebp
	pop	eax						;Elimino la direccion de retorno
	jmp salir
	
	
	
