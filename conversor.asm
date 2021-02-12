
global		main
extern 		printf
extern 		gets
extern 		sscanf

section 	.data
	msgSal				db	"numero en base %hi es: %s",10,0
	msjError			db 	"combinacion de base y numero incorrecto",10,0
	msjCadVacia			db 	"Entrada no valida (caracter vacio)",10,0
	;msj 				db 	"el numero ingresado en base 10 es: %hi",10,0
	msjDigitos 			db 	"La sumatoria de digitos es: %hi",10,0
	mensajeInicial 		db 	"ingrese un numero: ",0
	mensajeBase 		db 	"ingrese Base del numero anterior: ",0
	formatoEntrada 		db 	"%hi",0
	formatoBase 		db 	"%hi",0
	msjBaseIncorrecta 	db 	"Por favor ingrese una base valida Ej: (2 ,4, 8, 10, 16)",10,0
	vecBases 			dw 	2,4,8,10,16,-1
	vecNumHexa			dw	10,11,12,13,14,15
	vecLetras  			db 	"A   ",0,"B   ",0,"C   ",0,"D   ",0,"E   ",0,"F   ",0

section 	.bss

	buffer 				resb 	50
	buffer2 			resb  	50
	buffer3 			resb  	50
	numeroAConvertir	resw 	1
	contadorBase10		resw 	1
	entradaAlphNum 		resb 	1
	baseInicioValida 	resb 	1
	
	numEntrada			resw	1
	baseInicio 			resw	1
	baseActual			resw 	1
	plusRsp				resq	1  
	contador 			resq  	1
	contador2			resw 	1
	todoOk 				resb 	1

	indice 				resw 	1
	indice2 			resd 	1
	base 				resb 	100
	longitudBuffer		resw 	1
	sumDigits 			resw 	1


section 	.text

main:
entradaNumero:
	mov 	word[contadorBase10],0
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
	dec 	word[longitudBuffer]
	
validacionBase:
	call 	validarBase
	
	cmp 	byte[baseInicioValida],'N'
	je		msjbaseInvalida

	cmp 	word[longitudBuffer],-1		;valido entrada vacia	
	je 		msjCadenaVacia
	
	jmp 	conversion

suma:							;jmp en conversion y sumaDigitos porque mostraba varias veces resultado final
	jmp 	sumaDigitos
	
finPrograma:
	ret 

;*********************************************************
msjbaseInvalida:
	sub 	rax,rax
	mov 	rdi,msjBaseIncorrecta
	call 	printf
	jmp 	entradaBase

validarEntrada:
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
	mov 	word[longitudBuffer],bx
	
	mov 	rdi,buffer
	mov 	rsi,formatoEntrada
	mov 	rdx,numEntrada

	call	checkAlign      
	sub		rsp,[plusRsp]   
    call	sscanf
	add		rsp,[plusRsp]				; ver si puedo validar cuando entra mas parametros
	
invalido:
	ret

noNumerico:
	mov 	byte[entradaAlphNum],'S'
	jmp 	siguienteBuffer


msjCadenaVacia:
	mov		word[baseInicio],0
	sub 	rax,rax
	mov 	rdi,msjCadVacia
	call 	printf
	jmp 	entradaNumero

validarBase:
	mov 	byte[baseInicioValida],'N'
	
	mov 	rdi,buffer2
	mov 	rsi,formatoBase
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

	cmp 	dx,[baseInicio]
	je 		validoInicio

proximaIteracion:
	add		ebx,2
	cmp 	byte[baseInicioValida],'S'
	je 		terminarIteracion
	loop 	iteracion

terminarIteracion:
	ret 
	

validoInicio:
	mov 	byte[baseInicioValida],'S'
	jmp 	proximaIteracion
;******************************************

mensajeError:
	sub 	rax,rax
	mov 	rdi,msjError
	call 	printf
	jmp 	entradaNumero

conversion:
	;iterar por arreglo de bases 
	mov 	rax,1
	dec 	rax
	imul 	ebx,eax,2

sigConversion:
	mov 	dx,[vecBases + ebx]
	mov 	word[baseActual],dx
	mov 	dword[indice2],ebx

	cmp 	word[baseActual],-1
	je 		finConversion

base10:
	cmp 	word[baseInicio],10
	je 		deDecimalA
	
	jmp 	aDecimal	

chequeo:
	;a partir de aca ya tengo el numero en base 10, en contadorBase10
	mov 	byte[entradaAlphNum],'N'
	mov 	word[baseInicio],10

	mov 	r15w,word[contadorBase10]
	mov 	word[numEntrada],r15w
	jmp 	base10

aumentar:
	add 	dword[indice2],2
	mov 	ebx,dword[indice2]
	jmp 	sigConversion

finConversion:
	jmp 	suma

;*****************************************


deDecimalA:
	cmp 	byte[entradaAlphNum],'S'
	je 		mensajeError
	
	mov 	qword[contador],1
	mov 	ax,word[numEntrada] 		;numero en base decimal  
	mov 	word[contadorBase10],ax

sig:
	mov 	cx,word[baseActual] 		; base de destino
	cmp 	ax,cx
	jl 		finish

	xor 	dx,dx
	idiv 	cx

	push 	dx
	mov 	bx,ax	
	
	mov 	ax,bx
	inc  	qword[contador]
	jmp		sig

finish:
	push 	ax		
	mov 	rcx,0

prox:
	cmp 	qword[contador],0
	je 		fin
	
	dec 	qword[contador]
	pop 	bx
	

	cmp 	bx,9
	jg 		cambio

	add 	bx,48

desplazamiento:
	mov 	[base + rcx],bl
	inc 	rcx

	jmp 	prox
	
cambio:
	mov 	r8w,bx

	mov 	rax,1
	dec 	rax
	imul 	ebx,eax,2

proxLetra:
	mov 	dx,[vecNumHexa + ebx] 	
	inc 	word[indice]
	
	cmp 	dx,r8w      
	je 		copiarLetra	
	
	add 	ebx,2
	jmp 	proxLetra

copiarLetra:
	mov 	ax,word[indice]
	dec 	ax
	imul 	ebx,eax,5

	mov 	dx,[vecLetras + ebx]
	mov 	bx,dx
	jmp 	desplazamiento


fin:

	mov 	word[base+rcx],0

	sub 	rax,rax
	mov 	rdi,msgSal
	mov 	rsi,[baseActual]
	mov 	rdx,base
	call 	printf
	
	jmp 	aumentar

;**********************************************
aDecimal:
	mov 	byte[todoOk],'S'
	cmp 	byte[entradaAlphNum],'S'
	je 		iterarNumero
	
	;a partir de aca se que es un numero 
	mov 	r15w,word[numEntrada]
	mov 	word[numeroAConvertir],r15w   
	call 	cambioBase
	cmp 	byte[todoOk],'N'
	je 		mensajeError

	jmp		chequeo


iterarNumero:
	mov     rbx,0	;puntero a buffer
sigCaracter:
	mov 	r13,0	;puntero a vecLetras
	mov 	r8,0 	;uso para reemplazar letra por numero / contador 
	mov 	dl,byte[buffer + ebx]
   
	cmp     dl,0
    je      finCad

	jmp 	comprobarNumero
	
comprobarCadena:
	;si llego aca es porque es una letra y no un numero
	add 	dl,48
sigEnCadena:
	cmp 	r8w,6
	je 		mensajeError
	
	cmp 	dl,byte[vecLetras + r13d]
	je 		iguales
	add    	r13d,5
	inc		r8w
    jmp     sigEnCadena


finCad:
	jmp 	chequeo
	
comprobarNumero:
	sub 	dl,48
	cmp 	dl,0
	jl 		comprobarCadena

	cmp 	dl,9
	jg 		comprobarCadena
	
	mov 	r12w,[longitudBuffer]
	call 	calcularPotencia
	imul 	dx,word[contador2] ;resultado en dx

	add 	word[contadorBase10],dx

	jmp 	incrementar

	;********************************


iguales:									; lo que hago aca es convertir la letra hexadecimal en numero
											; y si es mayor a la base da error 
	imul 	r9d,r8d,2
	mov		r10w,word[vecNumHexa + r9d]
	
	cmp 	r10w,word[baseInicio]				;en r10w tengo el numero en decimal
	jge 	mensajeError
	
	mov 	r12w,[longitudBuffer]
	
	call 	calcularPotencia
	imul 	r10w,word[contador2] ;resultado en dx

	add 	word[contadorBase10],r10w
	jmp 	incrementar

incrementar:
	inc 	ebx
	jmp 	sigCaracter


cambioBase:
	;dx:ax 
	;resto dx
	;cociente ax
	;**************************************
	mov 	r12w,0
	mov 	ax,word[numeroAConvertir]
	mov 	r13w,10

seguirConv:
	cmp 	ax,0 ;si el cociente da 0 corta
	je 		finConv

	xor 	dx,dx
	idiv	r13w
	;resto en dx numero "partido por digito"
	;***************************************************
	cmp 	dx,word[baseInicio]
	jge 	Error

	jmp 	calcularPotencia	;resultado en contador2

multi:
	imul 	dx,word[contador2] ;resultado en dx
	add 	word[contadorBase10],dx
	inc 	r12w
	
	jmp 	seguirConv

Error:
	mov 	byte[todoOk],'N'

finConv:
	ret


calcularPotencia:
	mov 	rcx,0
	mov 	r11,0
	mov 	word[contador2],1

	mov 	r11w,1 	
	mov 	r14w,1 ; siempre 1
	mov 	cx,r12w ; exponente 
	inc 	cx

	cmp 	cx,0
	jz 		imprimir
pot:
	imul 	r14w,r11w
	mov 	word[contador2],r14w
	mov 	r11w,word[baseInicio] 	
	loop 	pot

imprimir:
	dec 	word[longitudBuffer]

	cmp 	byte[entradaAlphNum],'S'
	je 		terminar
	jmp 	multi

terminar:
	ret
										
;*****************************************************************
sumaDigitos:
	;inc 	word[contadorBase10]	;descomentar si es necesario, preguntar por limite 
	mov 	rbx,0

	mov 	word[sumDigits],0 			;inicializo acumulador
	mov 	bx,1  						;inicia sumatoria en 1
	
cargarProx:
	cmp 	bx,word[contadorBase10] 	;contadorBase10 contiene el limite superior de la sumatoria
	jg 		finSumDigitos 	
	
	mov 	ax,bx		
	mov 	r13w,10
partirNumero:
	cmp 	ax,0
	je 		finParticion

	xor 	dx,dx
	idiv	r13w
	;resto en dx numero "partido por digito"
	add 	word[sumDigits],dx

	jmp 	partirNumero

finParticion:
	inc 	bx
	jmp 	cargarProx

finSumDigitos:
	sub 	rax,rax
	mov 	rdi,msjDigitos
	mov 	si,[sumDigits]
	call 	printf

	jmp 	finPrograma


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