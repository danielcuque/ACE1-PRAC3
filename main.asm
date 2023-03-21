; Program Description: Juego de damas chinas en ensamblador
; Author: Daniel Estuardo Cuque Ruiz
; Creation Date: 14 de marzo de 2023


; ------------------------------------------------
; Imprimir
; esta macro se encarga de imprimir una cadena de caracteres en la pantalla. Para ello, primero carga la dirección de 
; inicio de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la 
; memoria de la cadena. Luego, carga el carácter de impresión de cadena en el registro AH y la dirección de inicio de 
; la cadena en el registro DX, y finalmente llama a la interrupción 21h para imprimir la cadena.
; ------------------------------------------------
printMsg macro str
            mov dx, offset str ; dx = offset de la cadena
            mov ah, 09h        ; imprimir cadena
            int 21h            ; imprimir cadena
endm

macroPrintPiece macro piece
            printMsg dobleSignoMayor
            printMsg piece
            printMsg dobleSignoMenor
endm


; Configuración del programa
.MODEL small
.STACK
.RADIX 16 ; para que los números se muestren en hexadecimal
dimension EQU 09 ; Tamaño del tablero
optionLong EQU 20 ; Tamaño de la opción del menú
.DATA

; Creamos la información de incio, seguido de la espera de ENTER para pasar al menú
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145' , 0Dh, 0Ah, '$'

; Creamos la información del menú
menuMessage DB 'Menu:', 0Dh, 0Ah,'1. Iniciar', 0Dh, 0Ah,'2. Cargar partida', 0Dh, 0Ah,'3. Salir', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la start_game de inicio de juego
; ------------------------------------------------
turnMsg DB 'Realizando sorteo aleatorio', 0Dh, 0Ah, '$'
turnDoneMsg DB 'Sorteo realizado', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Definimos los comandos
; ------------------------------------------------
saveCommand DB 'GUARDAR', '$'
generatePage DB 'GENERARPAGINA', '$'
exitCommand DB 'ABANDONAR', '$'

; ------------------------------------------------
; Variables para la option_2 de inicio de juego
; ------------------------------------------------
t2 DB 'op2', 0Dh, 0Ah, '$'
fileTableName DB 'table.txt', '$'
fileCreatedMsg DB 'Archivo creado', 0Dh, 0Ah, '$'
handle dw 0000

; ------------------------------------------------
; Creamos las variables para el el sorteo del juego
; ------------------------------------------------
;; 00 = jugador A
;; 01 = jugador B
playerTurn DB 0

;; Le asignamos a cada jugador una variable para saber que piezas le corresponden
;; 0 = piezas blancas
;; 1 = piezas negras
pieceTurn DB 0

; ------------------------------------------------
; Creamos las variables para el tablero
; ------------------------------------------------
table DB 81 DUP(0) ; 81 = 9x9 | Los 0 represetan filas vacias, los 1 representan piezas blancas, los 2 representan piezas negras
colTableStr DB '       1   2   3   4   5   6   7   8   9   ', 0Dh, 0Ah, '$'
lineTableStr DB '     +---+---+---+---+---+---+---+---+---+', 0Dh, 0Ah, '$'
nameLine DB '   @ |', '$'
cellTable DB '   |', '$'
selectPositionToMoveMsg DB 'Pieza a mover: ', '$'
indicateNewPositionMsg DB 'Destino de la pieza: ', '$'

displayTurn DB 'Turno del jugador ', '$'
conLaspiezas DB ' con las piezas ', '$'
dobleSignoMenor DB '<<', '$'
dobleSignoMayor DB '>>', '$'
playerA DB '1', '$'
playerB DB '2',  '$'
pieceB DB  'W', '$'
pieceW DB 'B',  '$'


; ------------------------------------------------
; Variables para la creación del .htm del estado del juego
; ------------------------------------------------
filename DB 'estado.htm', '$'
; conent DB '', '$'

; ------------------------------------------------
; Variables extra
; ------------------------------------------------
errorMsg DB 'Opcion no valida', 0Dh, 0Ah, '$'
exitMsg DB 'Cerrando programa ...', 0Dh, 0Ah, '$'
newLine  DB 0A,'$'
bufferKeyBoard DB 258 dup(0ff) ; 258 = 256 + 2
pressEnter DB 'Presione ENTER para continuar', 0Dh, 0Ah, '$'
invalidEntry DB 'Entrada invalida', 0Ah, '$'
debugerStr DB 'debuger', 0Dh, 0Ah, '$'

; Iniciamos el bloque de código
.CODE
start:
main PROC

; Cargamos la dirección de inicio de la sección de datos en el registro AX y luego la cargamos en el registro DS,
mov ax, @data
mov ds, ax

printMsg infoMsg ; Imprimimos la información del programa
printMsg newLine ; Imprimimos un salto de linea
call wait_enter ; Esperamos a que se presione ENTER para continuar

; Imprimimos el menu principal
mainMenu:
printMsg menuMessage ; Imprimimos el menú principal
printMsg newLine ; Imprimimos un salto de línea
mov AH, 08h ; Cargamos a AH el código de interrupción para leer un caracter
int 21 ; Llamamos a la interrupción
cmp AL, 31 ; Comparamos el caracter leído con el código ASCII de 1
je start_game ; Si se presiona 1 entonces se llama a la función option_1
cmp AL, 32 ; Comparamos el caracter leído con el código ASCII de 2
je upload_game ; Si se presiona 2 entonces se llama a la función option_2
cmp AL, 33 ; Comparamos el caracter leído con el código ASCII de 3
je exit ; Si se presiona 3 entonces se llama a la función option_3
jmp mainMenu ; Si se presiona cualquier otra tecla entonces se vuelve a imprimir el menú principal


wait_enter: ; Esperamos a que se presione ENTER para continuar
            printMsg pressEnter ; Imprimimos el mensaje de espera de ENTER
            mov AH, 08h ; Cargamos a AH el código de interrupción para leer un caracter
            int 21 ; Llamamos a la interrupción
            cmp AL, 0Dh ; Comparamos el caracter leído con el código ASCII de ENTER
            jne wait_enter ; Con jne nos aseguramos que sea condicional, es decir, si no se presiona ENTER entonces
                           ; se vuelve a llamar a la interrupción para leer un caracter
                           ; Si se presiona ENTER entonces se continua con el programa
            ret ; Retornamos a la función main

start_game: ; Función para iniciar el juego
            printMsg turnMsg ; Imprimimos el mensaje de inicio de juego
            call generate_random_number ; Llamamos a la función para generar un número aleatorio
            jmp start_sequence

upload_game:
printMsg t2 ;; Esta funcion servira para cargar una partida guardada

jmp exit ;; Esta funcion servira para salir del juego


;;;; Esta seccion sera para subrutinas y asi no traslapar el codigo
;;;; Por eso cuando pase a la opt 2, se va a exit para poder salir del programa
;; Creamos una subrutina para generar numeros aleatorios entre el 0 y 1 tomando las milesimas de segundo del sistema
generate_random_number:
mov AH, 2Ch ; Cargamos a AH el codigo de interrupción para obtener el tiempo del sistema
int 21h ; Llamamos a la interrupción

mov AL, DL ; Cargamos a AL el valor de las milesimas de segundo
and AL, 1 ; Aplicamos un AND con 1 para obtener el valor de las milesimas de segundo

;; Añadimos el valor de AL a la variable playerTurn
mov [playerTurn], AL ; Cargamos a playerTurn el valor de AL

;; Comparamos los valores de AL con 0 y 1 para determinar el jugador que inicia el juego
cmp AL, 0 ; Comparamos el valor de AL con 0
je set_player_A ;; Si es 0, seteamos el jugador A

cmp AL, 1 ; Comparamos el valor de AL con 1
je set_player_B ;; Si es 1, seteamos el jugador B

; ------------------------------------------------
generate_piece_random:
mov AH, 2Ch ; Cargamos a AH el codigo de interrupción para obtener el tiempo del sistema
int 21h ; Llamamos a la interrupción

mov AL, DL ; Cargamos a AL el valor de las milesimas de segundo
and AL, 1 ; Aplicamos un AND con 1 para obtener el valor de las milesimas de segundo
mov [pieceTurn], AL ; Cargamos a pieceTurn el valor de AL
printMsg conLaspiezas

cmp [pieceTurn], 0 ; Comparamos el valor de AL con 0
je set_piece_B ;; Si es 0, seteamos el jugador A

cmp [pieceTurn], 1 ; Comparamos el valor de AL con 1
je set_piece_W ;; Si es 1, seteamos el jugador B

set_piece_B:
macroPrintPiece pieceB
printMsg newLine
ret

set_piece_W:
macroPrintPiece pieceW
printMsg newLine
ret
; ------------------------------------------------


; ------------------------------------------------
;; Con esta subrutina, indicamos que el jugador A es el que inicia el juego
set_player_A:
;; Iniciamos la secuencia de impresión del tablero
printMsg turnDoneMsg ; Imprimimos el mensaje de que el sorteo se ha realizado

;; Imprimimos el valor del registro de turno del jugador
printMsg displayTurn ; Imprimimos el mensaje de que es el turno del jugador
printMsg playerA ; Imprimimos el mensaje de que es el turno del jugador A
call generate_piece_random ; Llamamos a la función para generar un número aleatorio
call wait_enter ; Llamamos a la función para esperar a que se presione ENTER
ret

set_player_B:
;; Iniciamos la secuencia de impresión del tablero
printMsg turnDoneMsg ; Imprimimos el mensaje de que el sorteo se ha realizado

;; Imprimimos el valor del registro de turno del jugador
printMsg displayTurn ; Imprimimos el mensaje de que es el turno del jugador
printMsg playerB ; Imprimimos el mensaje de que es el turno del jugador B
call generate_piece_random ; Llamamos a la función para generar un número aleatorio
call wait_enter ; Llamamos a la función para esperar a que se presione ENTER
;; Iniciamos la secuencia de impresión del tablero
ret
; ------------------------------------------------

start_sequence:
    printMsg colTableStr ; Imprimimos la primera linea del tablero
    printMsg lineTableStr ; Imprimimos la segunda linea del tablero
    call fill_initial_table ; Llamamos a la función para llenar el tablero con las piezas iniciales
    call printTable ; Llamamos a la función para imprimir el tablero
    call printTurn ;; Imprimimos el turno del jugador 
    call requestPieceToMove ; Solicitamos al usuario que seleccione una pieza para mover
    call putPieceInTable ; Solicitamos al usuario que coloque una pieza en el tablero
    call changeTurn ; Cambiamos el turno del jugador
    jmp start_sequence

printTable:
    mov DI, 00 ; Cargamos a DI el valor 00
    mov CX, dimension ; Cargamos a CX el valor de la dimension del tablero

;; Imprimimos las filas del tablero
;; Es importante tomar en cuenta que usamos el ascii de @ para que al sumar en 1 el valor de DI
;; podamos ir imprimiendo A B C D, etc, ya que son contiguos en el ascii

printTableRows:
mov BX, offset nameLine ; Cargamos a BX la dirección de memoria de la variable nameLine
add BX, 03 ; Sumamos 3 a BX para que apunte a la posición de la letra que corresponde
mov AL, [BX] ; Cargamos a AL el valor de la posición de memoria de BX
inc AL ; Sumamos 1 a AL para que apunte a la siguiente letra
mov [BX], AL ; Cargamos a la posición de memoria de BX el valor de AL
sub BX, 03 ; Restamos 3 a BX para que apunte a la posición de la letra que corresponde
mov DX, BX ; Cargamos a DB el valor de BX
mov AH, 09h ; Cargamos a AH el código de interrupción para imprimir un string
int 21h ; Llamamos a la interrupción
mov SI, CX ; Cargamos a SI el valor de CX
mov CX, dimension ; Cargamos a CX el valor de la dimension del tablero

printCell: 
mov AL, [table + DI]
int 03h
mov BX, offset cellTable
inc BX
cmp AL, 00
je printEmptyCell
cmp AL, 01
je printPlayerWCell

printPlayerBCell:
mov AL, 42
mov [BX], AL
dec BX
jmp readyCell

printEmptyCell:
dec BX
jmp readyCell

printPlayerWCell:
mov AL, 57 ;; Cargamos a AL el valor de la letra A
mov [BX], AL ;; Cargamos a la posición de memoria de BX el valor de AL
dec BX ;; Restamos 1 a BX para que apunte a la posición de la letra que corresponde

readyCell:
mov DX, BX
mov AH, 09h ; Cargamos a AH el código de interrupción para imprimir un string
int 21h ; Llamamos a la interrupción
inc BX
mov AL, 20 ; Cargamos a AL el valor de un espacio en blanco
mov [BX], AL ; Cargamos a la posición de memoria de BX el valor de AL
dec BX ; Restamos 1 a BX para que apunte a la posición de la letra que corresponde
inc DI ; Sumamos 1 a DI para que apunte a la siguiente posición de memoria
loop printCell ; Vamos a la siguiente fila del tablero
printMsg newLine ; Imprimimos un salto de linea
printMsg lineTableStr ; Imprimimos la segunda linea del tablero
mov CX, Si ; Cargamos a CX el valor de Si
loop printTableRows ;; Vamos a la siguiente fila del tablero
mov AL, 40 ;; Cargamos a AL el valor de la letra A
mov BX, offset nameLine ;; Cargamos a BX la dirección de memoria de la variable nameLine
add BX , 03 ;; Sumamos 3 a BX para que apunte a la posición de la letra que corresponde
mov [BX], AL ;; Cargamos a la posición de memoria de BX el valor de AL
ret

;;; Para esta seccion, cambiamos el valor de la variable playerTurn para indicar que el jugador B es el que inicia el juego
changeTurn:
;; ----------------------------------------------------------------
mov AH, 01 
mov AL, [playerTurn]
sub AH, AL
mov [playerTurn], AH
;; ----------------------------------------------------------------

;; ----------------------------------------------------------------
mov CH, 01
mov CL, [pieceTurn]
sub CH, CL
mov [pieceTurn], CH
ret
;; ----------------------------------------------------------------

; ------------------------------------------------
putPieceInTable:
printMsg newLine ;; Mostramos una nueva linea
printMsg indicateNewPositionMsg ;; Mostramos el mensaje para que elija una nueva posición

mov DX, offset bufferKeyBoard ;; Nos movemos a la dirección de memoria del buffer
mov AH, 0a
int 21

printMsg newLine ;; Mostramos una nueva linea
call takePositionKeyboard ;; Solicitamos al usuario que ingrese una posición
cmp DL, 00 ;; Comparamos si todo salio bien, mediante la comparacion de Dl, ya que en take position le asignamos un valor distinto de 00 para indicar que todo salio bien
je error_position ;; Si es igual a 00, entonces hubo un error y volvemos al menu principal

mov DL, Ah ;; Le cargamos a Dl el valor de AH
mov AH, 00 ;; A ah le asignamos el valor 00
mov CL, 09 ;; A cl le asignamos el valor 09
mul CL ;; Multiplicamos ah por cl
mov AH, Dl ;; A ah le asignamos el valor de Dl
add AL, Ah ;; Sumamos al con ah
mov Bx, 0000 ;; A bx le asignamos el valor 0000
mov BL, Al ;; A bl le asignamos el valor de al
jmp putPiece ;; Llamamos a la función para colocar la pieza en el tablero

error_position:
printMsg invalidEntry
printMsg newLine
jmp putPieceInTable

putPiece:
mov DX, offset table
add BX, Dx
mov CH, [playerTurn]
cmp CH, 00
je putPieceW
jmp putPieceB

; ------------------------------------------------
putPieceW:
mov CH, 01
mov [BX], CH
ret

putPieceB:
mov CH, 02
mov [BX], CH
ret

putEmptyPiece:
mov CH, 00
mov [BX], CH
ret

exit: 
printMsg exitMsg ; Imprimimos el mensaje de salida
mov AH, 4Ch ; Cargamos a AH el codigo DOS para interrumpir el programa
mov AL, 00 ; Cargamos a AL el valor 00
int 21h ; Llamamos a la interrupción
;; El 4Ch sirve para terminar el programa

saveCommandFound:
		mov CX, 00
		mov DX, offset fileTableName
		mov AH, 3c
		int 21
		jc exit
		mov [handle], AX
		mov BX, AX
		mov DX, offset newLine
		mov AH, 09
		int 21
		mov DX, offset fileCreatedMsg
		mov AH, 09
		int 21
		mov CX, 51
		mov DX, offset table
		mov AH, 40
		int 21
		jmp mainMenu
		mov AH, 3e
		int 21
ret

; ------------------------------------------------
;; Cambiamos los valores de nuestra tabla de juego
;; para que luzca como el tablero inicial de damas chinas
;; [B,B,B,B,0,0,0,0,0],
;; [B,B,B,0,0,0,0,0,0]
;; [B,B,0,0,0,0,0,0,0]
;; [B,0,0,0,0,0,0,0,0]
;; [0,0,0,0,0,0,0,0,0]
;; [0,0,0,0,0,0,0,0,W]
;; [0,0,0,0,0,0,0,W,W]
;; [0,0,0,0,0,0,W,W,W]
;; [0,0,0,0,0,W,W,W,W]

; ------------------------------------------------
;; Toma los datos del buffer para generar una posición
;; En Ah esta la posicion de la fila
;; En Al esta la posicion de la columna
;; En DL si la entrada no fue valida se toma como Dl = 00

takePositionKeyboard:
mov BX, offset bufferKeyBoard ;; Cargamos el buffer de teclado a BX
inc BX ;; Incrementamos en 1 el registro para que apunte al bit del tamaño de la cadena de caracteres
mov AL, [BX] ;; Cargamos ese bit a AL
cmp AL, 02 ;; Si el bit es de tamaño 2, entonces es correcto para asignar una posición
jne errorPosition ;; De lo contrario mostramos que tira error
inc BX ;; Incrementamos en 1 para acceder al primer caracter de la cadena, en este caso sería, la columna
mov AH, [BX] ;; Cargamos el valor de la fila a AL
cmp AH, 41 ;; Comparamos mediante jl y jg si el valor de la fila es menor o mayor a A e I respectivamente
jl errorPosition
cmp AH, 49 ;; numero ascii de I
jg errorPosition ;; mostramos error si es mayor
sub AH, 41 ;; Restamos 41 a AL para que el valor de AL sea el numero de la fila
mov AL, AH ;;  Cargamos a Ah el valor de Al para que quede en la posición de la fila
inc BX ;; Incrementamos en 1 para acceder al segundo caracter de la cadena, en este caso sería, la fila
mov AH, [BX] ;; Cargamos el valor de la fila a AL
cmp AH, 31 ;; Comparamos mediante jl y jg si el valor de la fila es menor o mayor a 1 y 9 respectivamente
jl errorPosition
cmp AH, 39
jg errorPosition
sub AH, 31
mov DL, 0ff ;; Cargamos a DL el valor de 0ff para indicar que la entrada fue valida
ret

fill_initial_table:
mov [table], 02
mov [table + 01], 02
mov [table + 02], 02
mov [table + 03], 02
mov [table + 09], 02
mov [table + 0A], 02
mov [table + 0B], 02
mov [table + 12], 02
mov [table + 13], 02
mov [table + 1B], 02

mov [table + 35], 01
mov [table + 3D], 01
mov [table + 3E], 01
mov [table + 45], 01
mov [table + 46], 01
mov [table + 47], 01
mov [table + 4D], 01
mov [table + 4E], 01
mov [table + 4F], 01
mov [table + 50], 01
ret

;------------------------------------------------
printTurn:
mov AL, [playerTurn]
cmp AL, 00
printMsg displayTurn
je printTurnA
jmp printTurnB

printTurnA:
printMsg playerA
printMsg conLaspiezas
jmp printPiece

printTurnB:
printMsg playerB
printMsg conLaspiezas

printPiece:
mov AL, [pieceTurn]
cmp AL, 00
je printPieceW

printPieceB:
macroPrintPiece pieceB
printMsg newLine
ret

printPieceW:
macroPrintPiece pieceW
printMsg newLine
ret

;; ------------------------------------------------
errorPosition: mov DL, 00
ret

; ------------------------------------------------
;; En esta seccion vamos a soliticar al usuario que ingrese la posicion de la pieza que desea mover
requestPieceToMove:
printMsg newLine ;; Imprimimos un salto de linea
printMsg selectPositionToMoveMsg ;; Mostramos el mensaje para elegir la posicion de la pieza a mover

mov DX, offset bufferKeyBoard
mov AH, 0a
int 21

printMsg newLine
call takePositionKeyboard

cmp DL, 00
je requestPieceToMove

mov DL, AH
mov AH, 00
mov cl, 09
mul CL ;; Multiplicamos el valor de la fila por 9 para obtener la posicion en la tabla
mov AH, DL 
add AL, AH
mov Bx, 0000
mov BL, Al

deletePiece:
mov DX, offset table
add BX, Dx
mov CH, 00
mov [BX], CH
ret

main ENDP
END start
