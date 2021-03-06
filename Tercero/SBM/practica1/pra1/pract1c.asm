;**************************************************************************
; SBM 2015. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
; AUTORES: JOSE IGNACIO GOMEZ GARCIA, OSCAR GOMEZ BORZDYNSKI
; PAREJA 14
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT

DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
	RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
	; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
	; FIN DE LAS INICIALIZACIONES
	; COMIENZO DEL PROGRAMA
	MOV AX, 0535H ; CARGAMOS EN AX 0535H PARA PASARSELO A DS
	MOV DS, AX
	MOV BX, 1234H 
	MOV AL, DS:[BX] ; CARGAMOS EN AL EL CONTENIDO DE LA POSICION 5350+1234=6584
	MOV BX, 0210H 
	MOV AX, [BX] ; CARGAMOS EN AX EL CONTENIDO DE LA POSCION 5350+210=5560
	MOV AX, 1011H 
	MOV DI, AX
	MOV [DI], AL ; CARGAMOS EN LA POSICION 5350+1011=6361 EL CONTENIDO DE AL
	; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO