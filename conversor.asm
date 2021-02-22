
global		main
extern 		printf
extern 		gets
extern 		sscanf

section 	.data
	msgSal				db	"numero en base %li es: %s",10,0
	msgSalNeg			db 	"numero en base %li es: -%s",10,0
	msjError			db 	"combinacion de base y numero incorrecto",10,0
	msjCadVacia			db 	"Entrada no valida (caracter vacio)",10,0
	msjDigitos 			db 	"La sumatoria de digitos es: %li",10,0
	mensajeInicial 		db 	"ingrese un numero (letras en mayusculas): ",0
	mensajeBase 		db 	"ingrese Base del numero anterior: ",0
	formatoEntrada 		db 	"%li",0

	msjBaseIncorrecta 	db 	"Por favor ingrese una base valida Ej: (2 ,4, 8, 10, 16)",10,0
	vecBases 			dw 	2,4,8,10,16
	vecNumHexa			dw	10,11,12,13,14,15
	vecLetras  			db 	"A   ",0,"B   ",0,"C   ",0,"D   ",0,"E   ",0,"F   ",0
	borrar 				db 	"%li",10,0
	borrar2 			db  "",10,0
	


section 	.bss

	buffer 				resb 	50
	buffer2 			resb  	50
	buffer3 			resb  	50
	bufferAux 			resb 	50
	numeroAConvertir	resw 	1
	contadorBase10		resq 	1
	entradaAlphNum 		resb 	1
	baseInicioValida 	resb 	1
	numeroNegativo 		resb 	1
	
	numEntrada			resq	1
	baseInicio 			resq	1
	baseActual			resq 	1
	plusRsp				resq	1  
	contador 			resq  	1
	contador2			resq 	1
	contador3 			resw 	1
	todoOk 				resb 	1

	indice 				resw 	1
	indice2 			resd 	1
	base 				resb 	100
	longitudBuffer		resq 	1
	sumDigits 			resq 	1


section 	.text

main:
entradaNumero:
	mov 	qword[contadorBase10],0
	sub 	rax,rax
	mov 	rdi,mensajeInicial
	call 	printf

	mov 	rdi,buffer
	call 	gets

entradaBase:
	sub 	rax,rax
	mov 	rdi,mensajeBase
	call 	printf

	mov 	rdi,buffer2
	call 	gets	

	call 	validarEntrada
	dec 	qword[longitudBuffer]
	
	cmp 	byte[numeroNegativo],'S'
	jne 	validacionBase

	;numero negativo
	cmp 	byte[entradaAlphNum],'S'
	jne 	cambioDeSigno

	;en este punto mi buffer tiene un numero negativo y es conformado con una letra
	call 	cambioDeBuffer
	jmp 	validacionBase

cambioDeSigno:	 	
	neg 	qword[numEntrada]

validacionBase:
	call 	validarBase
	
	cmp 	byte[baseInicioValida],'N'
	je		msjbaseInvalida

	cmp 	qword[longitudBuffer],-1		;valido entrada vacia	
	je 		msjCadenaVacia
	
	jmp 	conversion

suma:							;jmp en conversion y sumaDigitos porque mostraba varias veces resultado final
	call 	sumaDigitos
	
finPrograma:
	ret 


cambioDeBuffer:
	lea 	rsi,buffer + 1
	lea 	rdi,bufferAux
	mov 	rcx,[longitudBuffer]
rep movsb
		
	mov 	rcx,[longitudBuffer]
	lea 	rsi,bufferAux 
	lea 	rdi,buffer

rep movsb
	mov 	rbx,[longitudBuffer]
	mov 	byte[buffer + ebx],0

	dec 	byte[longitudBuffer]
	
	ret


msjbaseInvalida:
	sub 	rax,rax
	mov 	rdi,msjBaseIncorrecta
	call 	printf
	jmp 	entradaBase

validarEntrada:
	mov 	byte[numeroNegativo],'N'
	mov 	byte[entradaAlphNum],'N'
	mov     rax,0
	mov 	rbx,0

iterBuffer:
	mov 	dl,byte[buffer + ebx]
    cmp     dl,0
    je     	convBuffer
	
	mov 	byte[buffer3],dl
	mov		byte[buffer3 + 1],0
	mov 	rdi,buffer3
	mov 	rsi,formatoEntrada
	mov 	rdx,numEntrada
    
	call	checkAlign      
	sub		rsp,[plusRsp]   
    call	sscanf
	add		rsp,[plusRsp]	
	
	cmp 	rax,0
	jle 	noNumerico

siguienteBuffer:
	inc     ebx
    jmp     iterBuffer

convBuffer:
	mov 	qword[longitudBuffer],rbx
	
	mov 	rdi,buffer
	mov 	rsi,formatoEntrada 	
	mov 	rdx,numEntrada

	call	checkAlign      
	sub		rsp,[plusRsp]   ;convierte el buffer ,si es no numerico no lo convierte 
    call	sscanf
	add		rsp,[plusRsp]				

invalido:
	ret

noNumerico:
	cmp 	byte[buffer3],'-'
	jne 	alphaNum
	mov 	byte[numeroNegativo],'S'
	jmp 	siguiente

alphaNum:
	mov 	byte[entradaAlphNum],'S'

siguiente:
	jmp 	siguienteBuffer


msjCadenaVacia:
	mov		qword[baseInicio],0
	sub 	rax,rax
	mov 	rdi,msjCadVacia
	call 	printf
	jmp 	entradaNumero

validarBase:
	mov 	byte[baseInicioValida],'N'
	
	mov 	rdi,buffer2
	mov 	rsi,formatoEntrada
	mov 	rdx,baseInicio

	call	checkAlign      
	sub		rsp,[plusRsp]   
    call	sscanf
	add		rsp,[plusRsp]

	cmp 	rax,1
	jl 		invalido
	
	mov 	cx,5  ;para loop

	mov 	rax,1
	dec 	rax
	imul 	ebx,eax,2


iteracion:
	mov 	dx,[vecBases + ebx]

	cmp 	rdx,[baseInicio]
	je 		valido

proximaIteracion:
	add		ebx,2
	cmp 	byte[baseInicioValida],'S'
	je 		terminarIteracion
	loop 	iteracion

terminarIteracion:
	ret 
	

valido:
	mov 	byte[baseInicioValida],'S'
	jmp 	proximaIteracion


mensajeError:
	sub 	rax,rax
	mov 	rdi,msjError
	call 	printf
	jmp 	entradaNumero

conversion:
	;iterar por arreglo de bases 
	mov 	word[contador3],0 	;contador para vector de bases 
	mov 	rbx,0
	mov 	rax,1
	dec 	rax
	imul 	ebx,eax,2

sigConversion:
	cmp 	word[contador3],5 		;indice a recorrido a vector de bases
	je 		finConversion

	mov 	dx,[vecBases + ebx]
	mov 	qword[baseActual],rdx
	mov 	dword[indice2],ebx		;indice2 para conservar contenido de ebx

	cmp 	qword[baseInicio],10
	je 		deDecimalA
	
	jmp 	aDecimal	

cargarNumero:
	;a partir de aca ya tengo el numero en base 10, en contadorBase10
	sub 	rax,rax
	mov 	rdi,borrar2 	;espacio vacio para salida mas legible
	call 	printf

	mov 	byte[entradaAlphNum],'N'
	mov 	qword[baseInicio],10

	mov 	r15,qword[contadorBase10]
	mov 	qword[numEntrada],r15

	jmp 	conversion
	
aumentar:
	inc 	word[contador3]
	add 	dword[indice2],2
	mov 	ebx,dword[indice2]
	jmp 	sigConversion

finConversion:
	jmp 	suma


deDecimalA:
	mov 	word[indice],0 				;para reemplazar numero por letra hexa
	cmp 	byte[entradaAlphNum],'S'
	je 		mensajeError
	
	mov 	qword[contador],1
	mov 	rax,qword[numEntrada] 		;numero en base decimal  
	mov 	qword[contadorBase10],rax
	mov 	rcx,qword[baseActual] 		; base de destino
sig:

	cmp 	rax,rcx
	jl 		final

	xor 	rdx,rdx
	idiv 	rcx

	push 	rdx
	
	inc  	qword[contador]
	jmp		sig

final:
	push 	rax		
	mov 	rcx,0

prox:
	cmp 	qword[contador],0
	je 		salidaPantalla
	
	dec 	qword[contador]
	pop 	rbx

	cmp 	rbx,9
	jg 		cambio

	add 	rbx,48

desplazamiento:
	mov 	[base + rcx],bl
	inc 	rcx
	jmp 	prox
	
cambio:
	mov 	word[indice],0
	mov 	r8,rbx

	mov 	rax,1
	dec 	rax
	imul 	ebx,eax,2

proxLetra:

	mov 	dx,[vecNumHexa + ebx] 	
	inc 	word[indice]
	
	cmp 	rdx,r8      
	je 		copiarLetra	
	
	add 	ebx,2
	jmp 	proxLetra

copiarLetra:
	mov 	rdx,0
	mov 	ax,word[indice]
	dec		ax
	imul 	ebx,eax,5

	mov 	dx,[vecLetras + ebx]

	mov 	bx,dx
	jmp 	desplazamiento


salidaPantalla:

	sub 	rax,rax
	mov 	word[base+rcx],0

	cmp 	byte[numeroNegativo],'N'
	je		posit
	mov 	rdi,msgSalNeg
	mov 	rsi,[baseActual]
	mov 	rdx,base
	call 	printf
	jmp 	aumento

posit:
	sub 	rax,rax
	mov 	rdi,msgSal
	mov 	rsi,[baseActual]
	mov 	rdx,base
	call 	printf

aumento:
	jmp 	aumentar

;**********************************************
aDecimal:
	
	mov 	byte[todoOk],'S'
	cmp 	byte[entradaAlphNum],'S'
	je 		iterarNumero
	
	;a partir de aca se que es un numero   
	call 	cambioBase
	cmp 	byte[todoOk],'N'
	je 		mensajeError

finCambioBase:
	jmp		cargarNumero


iterarNumero:
	mov     rbx,0	;puntero a buffer

sigCaracter:
	mov 	rdx,0
	mov 	r13,0	;puntero a vecLetras
	mov 	r8,0 	;uso para reemplazar letra por numero / contador 
	mov 	dl,byte[buffer + ebx]
   
	cmp     dl,0
    je      finCambioBase

	jmp 	comprobarNumero
	
comprobarCadena:
	;si llego aca es porque es una letra y no un numero
	add 	dl,48

sigEnCadena:
	cmp 	r8w,6
	je 		mensajeError
	
	cmp 	dl,byte[vecLetras + r13d]
	je 		caracteresIguales
	add    	r13d,5
	inc		r8w
    jmp     sigEnCadena

	
comprobarNumero:
	sub 	dl,48
	cmp 	dl,0
	jl 		comprobarCadena

	cmp 	dl,9
	jg 		comprobarCadena
	
	mov 	r12,[longitudBuffer]
	call 	calcularPotencia
	imul 	rdx,qword[contador2] ;resultado en dx

	add 	qword[contadorBase10],rdx

	jmp 	incrementar


caracteresIguales:									; lo que hago aca es convertir la letra hexadecimal en numero
	mov 	r10,0											; y si es mayor a la base da error 
	imul 	r9d,r8d,2
	mov		r10w,word[vecNumHexa + r9d]
	
	cmp 	r10,qword[baseInicio]				;en r10w tengo el numero en decimal
	jge 	mensajeError
	
	mov 	r12,[longitudBuffer]
	
	call 	calcularPotencia
	imul 	r10,qword[contador2] ;resultado en dx


	add 	qword[contadorBase10],r10
	jmp 	incrementar

incrementar:
	inc 	ebx
	jmp 	sigCaracter



cambioBase:
	;dx:ax 
	;resto dx
	;cociente ax
	;**************************************
	mov 	r12,0    ;para contar el exponente
	mov 	rax,qword[numEntrada]
	mov 	r13,10

seguirConv:
	cmp 	rax,0 ;si el cociente da 0 corta
	je 		finConv

	xor 	rdx,rdx
	idiv	r13
	;resto en rdx numero "partido por digito"
	;***************************************************
	cmp 	rdx,qword[baseInicio]  ;si mi digito es mas grande que la base da error
	jge 	Error
	cmp 	rdx,0
	je 		incremento

	call 	calcularPotencia	;resultado en contador2
	cmp 	byte[entradaAlphNum],'S'
	je 		finConv

multi:
	imul 	rdx,qword[contador2] ;resultado en dx
	add 	qword[contadorBase10],rdx

incremento:
	inc 	r12
	jmp 	seguirConv

Error:
	mov 	byte[todoOk],'N'

finConv:
	ret


calcularPotencia:
	
	mov 	qword[contador2],1

	mov 	r11,1 	
	mov 	r14,1 ; siempre 1
	mov 	rcx,r12 ; exponente 
	inc 	rcx
pot:
	imul 	r14,r11
	mov 	qword[contador2],r14
	mov 	r11,qword[baseInicio] 	
	loop 	pot

imprimir:
	dec 	qword[longitudBuffer]

terminar:
	ret
										
;*****************************************************************
sumaDigitos:
	;inc 	word[contadorBase10]	;descomentar si es necesario, preguntar por limite 
	mov 	rbx,0

	mov 	qword[sumDigits],0 			;inicializo acumulador
	cmp 	byte[numeroNegativo],'S'
	je 		finSumDigitos

	mov 	rbx,1  						;inicia sumatoria en 1
	
cargarProx:
	cmp 	rbx,qword[contadorBase10] 	;contadorBase10 contiene el limite superior de la sumatoria
	jg 		finSumDigitos 	
	
	mov 	rax,rbx		
	mov 	r13,10
partirNumero:
	cmp 	rax,0
	je 		finParticion

	xor 	rdx,rdx
	idiv	r13
	;resto en rdx numero "partido por digito"
	add 	qword[sumDigits],rdx

	jmp 	partirNumero

finParticion:
	inc 	rbx
	jmp 	cargarProx

finSumDigitos:
	sub 	rax,rax
	mov 	rdi,msjDigitos
	mov 	rsi,[sumDigits]
	call 	printf

	ret


;----------------------------------------
;----------------------------------------
; ****	checkAlign ****
;----------------------------------------
;----------------------------------------
checkAlign:
	push rax
	push rbx

	push rdx
	push rdi

	mov   qword[plusRsp],0
	mov		rdx,0

	mov		rax,rsp		
	add     rax,8		 
	add		rax,32	
	
	mov		rbx,16
	idiv	rbx		

	cmp     rdx,0		
	je		finCheckAlign

	mov   qword[plusRsp],8

finCheckAlign:
	pop rdi
	pop rdx

	pop rbx
	pop rax
	ret