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

section .data

liebre db '31,02'
perro1 db '01,01'
perro2 db '00,02'				;columna,fila
perro3 db '01,03'

turno db 0

msgSeleccionPerro db 'Indique el perro que desea mover: 1,2,3:',10,0
msgDireccionPerro db 'Indique la direccion en la que desea mover al perro:',10,'>> "w": Arriba',10,'>> "x": Abajo',10,'>> "d": Derecha',10,0
msgDireccionLiebre db 'Indique la direccion en la que desea mover a la liebre:',10,'>> "w": Arriba',10,'>> "xs": Abajo',10,'>> "d": Derecha',10,'>> "a": Izquierda',10,'>> "e": Arriba Derecha',10,'>> "q": Arriba Izquierda',10,'>> "c": Abajo Derecha',10,'>> "z": Abajo Izquierda',10,0

msgError1 db 'Error! Formato del parametro no valido!',10,0
msgError2 db 'Error! Parametro fuera del rango!',10,'>> Rango permitido: [3,30]',10,0
msgError3 db 'Error! Debe ingresar el ancho del tablero!',10,'>> Formato: $ ./Progra2 [ancho del tablero (Min 3, Max 40)]',10,0
msgError4 db 'Error! Direccion no valida!',10,0
msgError5 db 'Error! Numero del perro no valido!',10,10,0


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
	call leer
	;call mover_perro
	
	call imprimir_tablero
	
	jmp loop


	
salir:
	mov esp,ebp
	pop ebp
	ret
	
;-----------------------------------------------------------------------------------------------------
;											Subrutinas
;-----------------------------------------------------------------------------------------------------

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
	jmp escribir
	
	
guardar_ancho:
	call conversion_ascii_numerico
	mov [anchoTablero],cl
	
	add cl,cl
	add cl,4
	mov [largoTotal],cl
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
	;cmp [turno],0
	;je leer_liebre
	
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
	
	;cmp byte [direccion],'d'
	;je derecha
	
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
	
	;call mover_liebre
	ret
	
arriba:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,5
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	;mov dx,word[eax]
	call conversion_ascii_numerico

	cmp cl,0
	je error_direccion
	
	cmp cl,31
	je error_direccion
	
	push ecx							;guardo la columna actual del perro
	add eax,3							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
	
	cmp cl,1
	je error_direccion
	
	;push ecx							;guardo la fila actual del perro
	xor eax,eax

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	;add edx,edx
	;pop ecx

	add eax,tablero
	add eax,edx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	mov byte [eax],cl
	
	xor ebx,ebx
	
	mov bl,[perroSeleccion]
	mov cl,byte[largoTotal]
	
	xor ebx,30h
	
	sub eax,ecx
	sub eax,ecx
	
	mov byte[eax],bl
	
	ret
	
	
abajo:
	xor edx,edx
	mov dl,byte[perroSeleccion]
	
	xor eax,eax
	mov al,5
	mul dl								;multiplico 4*perroSeleccion
	
	add eax,liebre						;direccion de liebre+desplazamiento
	
	mov dh,byte[eax]
	mov dl,byte[eax+1]
	;mov dx,word[eax]
	call conversion_ascii_numerico

	cmp cl,0
	je error_direccion
	
	cmp cl,31
	je error_direccion

	push ecx							;guardo la columna actual del perro
	add eax,3							;me muevo 3 bytes desde el inicio de la direccion

	mov dh,byte[eax]
	mov dl,byte[eax+1]
	call conversion_ascii_numerico
a:	
	cmp cl,3
	je error_direccion
	
	;push ecx							;guardo la fila actual del perro
	xor eax,eax

	mov al,byte[largoTotal]
	dec cl
	mul cl
	add ax,ax								;obtengo el desplazamiento para la fila
	
	pop edx
	add edx,edx
	;add edx,edx
	;pop ecx
b:
	mov ecx,eax
	mov eax,tablero
	sub eax,ecx
	add eax,edx
	
	xor ecx,ecx
	mov cl,0x2a								;0x2a = '*'
	mov byte [eax],cl
	
	xor ebx,ebx
c:	
	mov bl,[perroSeleccion]
	mov cl,byte[largoTotal]
	
	xor ebx,30h
	
	add eax,ecx
	add eax,ecx
	
	mov byte[eax],bl
	
	ret
;izquierda:
;derecha:
	
	
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
	
	jmp leer
	
error_direccion:
	push ebp
	mov ebp,esp
	push msgError4
	call printf
	mov esp,ebp
	pop ebp
	
	jmp leer
