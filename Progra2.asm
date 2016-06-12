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
largoTotal resw 1

perroSeleccion resw 4
direccion resw 4
columTotales resb 1

section .data

liebre db '3102'
perro1 db '0101'
perro2 db '0002'				;columna,fila
perro3 db '0103'

turno db 0xff

msgSeleccionPerro db 'Indique el perro que desea mover: 1,2,3:',10,0
msgDireccionPerro db 'Indique la direccion en la que desea mover al perro:',10,'>> "w": Arriba',10,'>> "x": Abajo',10,'>> "d": Derecha',10,0
msgDireccionLiebre db 'Indique la direccion en la que desea mover a la liebre:',10,'>> "w": Arriba',10,'>> "x": Abajo',10,'>> "d": Derecha',10,'>> "a": Izquierda',10,'>> "e": Arriba Derecha',10,'>> "q": Arriba Izquierda',10,'>> "c": Abajo Derecha',10,'>> "z": Abajo Izquierda',10,0

msgError1 db 'Error! Formato del parametro no valido!',10,0
msgError2 db 'Error! Parametro fuera del rango!',10,'>> Rango permitido: [3,30]',10,0
msgError3 db 'Error! Debe ingresar el ancho del tablero!',10,'>> Formato: $ ./Progra2 [ancho del tablero (Min 3, Max 40)]',10,0
msgError4 db 'Error! Direccion no valida!',10,0
msgError5 db 'Error! Numero del perro no valido!',10,10,0
msgError6 db 'Error! La casilla a la que desea moverse esta ocupada!',10,10,0
msgError7 db 'Error! No es posible realizar el movimiento deseado!',10,10,0


section .text

	extern printf				;'exporta' la funcion printf
	extern read
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
	
loop:
	
	push ebp
	mov ebp,esp
	
	call leer
	
	call imprimir_tablero
	
	xor byte [turno],0xff
	
	mov esp,ebp
	pop ebp	
	jmp loop


	
salir:
	mov esp,ebp
	pop ebp
	ret
	
;///////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////	Subrutinas		////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////

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
	mov word [eax],' '
	add eax,1							;Muevo el puntero 2 bytes
	jmp espacios
	
fila_tres_inicio:
	mov word [eax],' '
	add eax,1							;Muevo el puntero 2 bytes
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
	cmp ebx,3
	je espacios_aux_1
	
	mov dword [eax],'/|\|'
	add eax,4
	inc ecx
	inc ecx
	
	jmp espacios_aux_2

espacios_aux_1:
	mov dword [eax],'\|/|'
	add eax,4
	inc ecx
	inc ecx
	
espacios_aux_2:
	
	cmp cx,word [anchoTablero]
	jb espacios
	
	cmp cx,word [anchoTablero]
	jbe espacios_aux_3
	sub eax,2
	
espacios_aux_3:
	xor ecx,ecx
	
	;sub eax,1
	
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
	
	push eax
	push ebx
	push ecx
	push edx
	
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	
	mov eax,liebre
	mov dl,byte[anchoTablero]
	inc dl
	call conversion_numerico_ascii
	mov [eax],ch
	mov [eax+1],cl
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	jmp escribir
	
	
guardar_ancho:
	call conversion_ascii_numerico
	mov [anchoTablero],cl
	
	inc cl
	mov [columTotales],cl
	
	add cl,cl
	add cl,2
	mov [largoTotal],cl
	
	mov dl,byte[anchoTablero]
	inc dl
	call conversion_numerico_ascii
	mov word[liebre],cx
	
	ret
	
imprimir_tablero:
	push ebp
	mov ebp,esp
	
	push tablero
	call printf
	
	mov esp,ebp
	pop ebp
	ret
	
leer:						;Lee el comando del usuario para mover a un perro
	push ebp
	mov ebp,esp
	
	mov word[perroSeleccion],0
	cmp byte [turno],0xff
	je leer_liebre
	
	push ebp
	mov ebp,esp
	push msgSeleccionPerro
	call printf
	mov esp,ebp
	pop ebp
	
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,perroSeleccion		;direccion de buffer
	mov edx,4			;cantidad de bytes a leer
	int 0x80

	mov dl,byte[perroSeleccion]
	call conversion_ascii_numerico
	mov byte [perroSeleccion],cl
	
	cmp cl,0
	je error_numero_perro
	
	cmp cl,3
	ja error_numero_perro

	push ebp
	mov ebp,esp
	push msgDireccionPerro
	call printf
	mov esp,ebp
	pop ebp
	
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,direccion		;direccion de buffer
	mov edx,2			;cantidad de bytes a leer
	int 0x80

	xor eax,eax
	mov al,byte[direccion]
	
	cmp al,77h						;77h = 'w'
	je arriba
	
	cmp al,78h						;78h = 'x'
	je abajo
	
	cmp al,64h						;64h = 'd'
	je derecha
	
	jmp error_direccion

leer_liebre:
	push ebp
	mov ebp,esp
	push msgDireccionLiebre
	call printf
	mov esp,ebp
	pop ebp
	
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,direccion		;direccion de buffer
	mov edx,4			;cantidad de bytes a leer
	int 0x80
	
	xor eax,eax
	mov al,byte[direccion]
	
	cmp al,77h						;77h = 'w'
	je arriba
	
	cmp al,78h						;78h = 'x'
	je abajo
	
	cmp al,64h						;64h = 'd'
	je derecha
	
	cmp al,61h						;61h = 'a'
	je izquierda
	
	cmp al,65h						;65h = 'e'
	je arriba_derecha
	
	cmp al,71h						;71h = 'q'
	je arriba_izquierda
	
	cmp al,63h						;63h = 'c'
	je abajo_derecha
	
	cmp al,7ah						;80h = 'z'
	je abajo_izquierda
	
	jmp error_direccion
	
arriba:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
		
	push eax
	push dword[eax]
		
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,0
	je error_movimiento
	
	cmp cl,[columTotales]
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	add eax,2							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,1
	je error_movimiento
	
	push ecx							;guardo la fila actual del perro
	
	dec cl
	mov dl,cl
	call conversion_numerico_ascii
	
	mov [eax],ch
	mov [eax+1],cl						;Actualizo la 'variable'
	
	xor eax,eax
	
	pop ecx								;saco la fila

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx								;saco la columna
	add edx,edx

	add eax,tablero
	add eax,edx
	
	push eax							;guardo la direccion de la posicion en el tablero donde voy a mover el perro
	
	mov cl,byte[largoTotal]
	sub eax,ecx
	sub eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov bl,[perroSeleccion]
	xor ebx,30h
	call verif_liebre
	mov byte[eax],bl
	
	pop eax								;saco la direccion del tablero
	mov byte [eax],cl

	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret
	
abajo:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	;mov dx,word[eax]
	call conversion_ascii_numerico

	cmp cl,0
	je error_movimiento
	
	cmp cl,[columTotales]
	je error_movimiento

	push ecx							;guardo la columna actual del perro
	add eax,2							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,3
	je error_movimiento
	
	push ecx
	
	inc cl
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax
	
	mov cl,byte[largoTotal]
	add eax,ecx
	add eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov bl,[perroSeleccion]
	xor ebx,30h
	call verif_liebre
	mov byte[eax],bl
	
	pop eax
	mov byte [eax],cl
	
	xor eax,eax
		
	mov esp,ebp
	pop ebp
	
	ret
izquierda:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,0
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	dec cl
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	push ecx
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	sub eax,2
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov bl,[perroSeleccion]
	xor ebx,30h
	call verif_liebre
	mov byte[eax],bl
	
	pop eax
	mov byte [eax],cl
	
	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret
derecha:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,[columTotales]
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	inc cl
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	push ecx

	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	add eax,2
	
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov bl,[perroSeleccion]
	xor ebx,30h
	call verif_liebre
	mov byte[eax],bl
	
	pop eax
	mov byte [eax],cl
	
	xor eax,eax
		
	mov esp,ebp
	pop ebp
	
	ret

arriba_derecha:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,[columTotales]
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	inc cl
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,1
	je error_movimiento
	
	push ecx							;guardo la fila actual del perro
	
	dec cl
	mov dl,cl
	call conversion_numerico_ascii
	
	mov [eax],ch
	mov [eax+1],cl						;Actualizo la 'variable'
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax									;guardo la direccion dela posicion
												;actual del tablero
	xor ecx,ecx
	
	mov cl,byte[largoTotal]
	sub eax,ecx
	
	xor ecx,ecx
	mov cl,0x2f								;0x2f = '/'
	
	inc eax
		
	cmp byte[eax],cl
	jne error_movimiento
	
	mov cl,byte[largoTotal]
	sub eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	inc eax
		
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov byte[eax],0x4c						;0x4c = 'L'
	
	pop eax
	mov byte [eax],cl						;Desocupa la casilla en el tablero
	
	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret

arriba_izquierda:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]					;leo la columna
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,0
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	dec cl
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,1
	je error_movimiento
	
	push ecx							;guardo la fila actual del perro
	
	dec cl
	mov dl,cl
	call conversion_numerico_ascii
	
	mov [eax],ch
	mov [eax+1],cl						;Actualizo la 'variable'
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax									;guardo la direccion dela posicion
												;actual del tablero
	xor ecx,ecx
	
	mov cl,byte[largoTotal]
	sub eax,ecx
	
	xor ecx,ecx
	mov cl,0x5c								;0x5c = '\'
	
	dec eax
		
	cmp byte[eax],cl
	jne error_movimiento
	
	mov cl,byte[largoTotal]
	sub eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	dec eax
		
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov byte[eax],0x4c						;0x4c = 'L'
	
	pop eax
	mov byte [eax],cl						;Desocupa la casilla en el tablero
	
	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret
	
abajo_derecha:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,[columTotales]
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	inc cl								;aumento la columna en 1 (avanzo)
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,3
	je error_movimiento
	
	push ecx							;guardo la fila actual del perro
	
	inc cl								;aumento la fila en 1 (bajo)
	mov dl,cl
	call conversion_numerico_ascii
	
	mov [eax],ch
	mov [eax+1],cl						;Actualizo la 'variable'
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax									;guardo la direccion dela posicion
												;actual del tablero
	xor ecx,ecx
	
	mov cl,byte[largoTotal]
	add eax,ecx
	
	xor ecx,ecx
	mov cl,0x5c								;0x5c = '\'
	
	inc eax
		
	cmp byte[eax],cl
	jne error_movimiento
	
	mov cl,byte[largoTotal]
	add eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	inc eax
		
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov byte[eax],0x4c						;0x4c = 'L'
	
	pop eax
	mov byte [eax],cl						;Desocupa la casilla en el tablero
	
	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret
	
abajo_izquierda:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,4
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	push eax
	push dword[eax]
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,0
	je error_movimiento
	
	push ecx							;guardo la columna actual del perro
	
	dec cl								;disminuyo la columna en 1 (retrocedo)
	mov dl,cl
	call conversion_numerico_ascii

	mov [eax],ch
	mov [eax+1],cl						;guardo la proxima posicion de la ficha

	add eax,2							;me muevo 3 bytes desde el inicio de la direccion
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico

	cmp cl,3
	je error_movimiento
	
	push ecx							;guardo la fila actual del perro
	
	inc cl								;aumento la fila en 1 (bajo)
	mov dl,cl
	call conversion_numerico_ascii
	
	mov [eax],ch
	mov [eax+1],cl						;Actualizo la 'variable'
	
	xor eax,eax
	
	pop ecx

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	
	mov ecx,eax
	mov eax,tablero
	add eax,ecx
	add eax,edx
	
	push eax									;guardo la direccion dela posicion
												;actual del tablero
	xor ecx,ecx
	
	mov cl,byte[largoTotal]
	add eax,ecx
	
	xor ecx,ecx
	mov cl,0x2f								;0x2f = '/'
	
	dec eax
		
	cmp byte[eax],cl
	jne error_movimiento
	
	mov cl,byte[largoTotal]
	add eax,ecx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	
	dec eax
		
	cmp byte[eax],cl
	jne errorCasillaOcupada
	
	xor ebx,ebx
	
	mov byte[eax],0x4c						;0x4c = 'L'
	
	pop eax
	mov byte [eax],cl						;Desocupa la casilla en el tablero
	
	xor eax,eax
	
	mov esp,ebp
	pop ebp
	
	ret
conversion_ascii_numerico:
	;como los parametros se interpretan como caracteres ascii
	;tengo que pasar esos caracteres a decimales, para eso hago un xor a cada caracter
	
	;Convierte el valor en dx
	;El valor queda en el cl
	
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
	
	cmp dh,0						;verifico si el numero es menor que 10
								;en ese caso habria un 0 en el dh
	je menor_diez
	
	cmp dh,30h						;verifico si el numero es menor que 10
								;en ese caso habria un 0 (30h) en el dh
	je menor_diez
	
	cmp dl,3						;verifico si el numero es 30 y algo
								;en ese caso habria un 3 en el dh
	je treintas
	
	cmp dl,2						;verifico si el numero es menor que 20
								;en ese caso habria un 2 en el dh
	je veintes
	
	mov cl,10
	add cl,dl
	ret
	
veintes:
	mov cl,20
	add cl,dh
	ret
	
treintas:
	mov cl,30
	add cl,dh
	ret
	
menor_diez:
	mov cl,dl
	ret
	
conversion_numerico_ascii:
	;convierte un numero en ascii
	
	;Convierte el valor en dl
	;El valor queda en el cx
	
	xor ecx,ecx
	
	cmp dl,10						;verifico si el numero es menor que 10
								;en ese caso habria un 0 en el dh
	jb menor_diez_2
	
	cmp dl,30						;verifico si el numero es 30 y algo
								;en ese caso habria un 3 en el dh
	ja treintas_2
	
	cmp dl,20						;verifico si el numero es menor que 20
								;en ese caso habria un 2 en el dh
	ja veintes_2
	
	mov ch,31h
	sub dl,10
	xor dl,30h
	mov cl,dl
	ret
	
veintes_2:
	mov ch,32h
	sub dl,20
	xor dl,30h
	mov cl,dl
	ret
	
treintas_2:
	mov ch,33h
	sub dl,30
	xor dl,30h
	mov cl,dl
	ret
	
menor_diez_2:
	mov ch,30h
	xor dl,30h
	mov cl,dl
	ret
	
error:
	push ebp
	mov ebp,esp
	
	push msgError1
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

verif_liebre:
	cmp bl,0x30
	je es_liebre
	ret
es_liebre:
	mov bl,0x4c
	ret
	
buscar_salida:
	mov eax,liebre						;direccion de liebre
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
		
	push ecx							;guardo la columna actual del perro
	
	add eax,2							;me muevo 2 bytes desde el inicio de la direccion
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	push ecx							;guardo la fila actual del perro
	
	xor eax,eax
	
	mov ecx, dword[esp]					;simulo un pop del primer elemento en la pila
										;para no borrar ese elemento y utlizarlo mas adelante

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
											;(me ubico al principio de la fila X)
	
	mov edx, dword[esp+4]				;simulo un pop del segundo elemento en la pila
										;para no borrar ese elemento y utlizarlo mas adelante
	add edx,edx
	
	mov eax,tablero
	add ecx,eax
	
	xor eax,eax
	mov al,byte[largoTotal]
	
	pop edx								;saco el valor de la fila
	
	cmp dl,3
	je buscar_arriba						;busca salidas hacia 'arriba' de la liebre
	
	cmp dl,0
	je buscar_abajo							;busca salidas hacia 'abajo' de la liebre
	
	pop edx								;saco el valor de la columna
	
	mov bl,[columTotales]
	
	cmp dl,bl
	je buscar_izquierda
	
	;~ dec bl
	;~ cmp dl,bl
	;~ je buscar_especial						;busca el caso especial en el que la liebre
											;~ ;en la tercera fila y penultima columna
	ret

buscar_arriba:
	
;~ buscar_abajo:

;~ buscar_izquierda:
	
;///////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////	Errores		////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////
		
errorNoParametros:
	push ebp
	mov ebp,esp
	push msgError3
	call printf
	mov esp,ebp
	pop ebp
	pop	eax						;Elimino la direccion de retorno
	
	xor eax,eax
	jmp salir
	
errorFueraRango:
	push ebp
	mov ebp,esp
	push msgError2
	call printf
	mov esp,ebp
	pop ebp
	pop	eax						;Elimino la direccion de retorno
	
	xor eax,eax
	jmp salir
	
error_numero_perro:
	push ebp
	mov ebp,esp
	push msgError5
	call printf
	mov esp,ebp
	pop ebp
	
	mov esp,ebp
	pop ebp
	
	jmp leer
	
error_direccion:
	push ebp
	mov ebp,esp
	push msgError4
	call printf
	mov esp,ebp
	pop ebp
	
	mov esp,ebp
	pop ebp
	
	call imprimir_tablero
	
	jmp leer

errorCasillaOcupada:
	mov eax,dword[esp+4]			;datos
	mov ebx,dword[esp+8]			;direccion
	
	mov dword[ebx],eax
	
	push ebp
	mov ebp,esp
	push msgError6
	call printf
	mov esp,ebp
	pop ebp
		
	mov esp,ebp
	pop ebp
	
	call imprimir_tablero
	
	jmp leer

error_movimiento: 
	mov eax,dword[ebp-4]						;direccion
	mov ebx,dword[ebp-8]					;datos
	
	mov dword[eax],ebx
	
	push ebp
	mov ebp,esp
	push msgError7
	call printf
	mov esp,ebp
	pop ebp
	
	mov esp,ebp
	pop ebp
	
	call imprimir_tablero
	
	jmp leer
	


