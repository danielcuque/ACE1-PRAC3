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

; ------------------------------------------------
; Imprimir un caracter ascii
; esta macro se encarga de imprimir un carácter ASCII en la pantalla. Para ello, primero carga la dirección de inicio 
; de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la memoria de 
; la cadena. Luego, carga el carácter de impresión de carácter en el registro AH y el carácter ASCII en el registro DL, 
; y finalmente llama a la interrupción 21h para imprimir el carácter.
; ------------------------------------------------
printAscii macro ascii
            mov dx, offset ascii ; dx = offset del caracter
            mov ah, 02h          ; imprimir caracter
            int 21h              ; imprimir caracter
endm

; Configuración del programa
.MODEL small
.STACK
.RADIX 16 ; para que los números se muestren en hexadecimal
.DATA

; Creamos la información de incio, seguido de la espera de ENTER para pasar al menú
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145' , 0Dh, 0Ah,0Dh, 0Ah,'ENTER para continuar' , 0Dh, 0Ah, '$'

; Creamos la información del menú
menuMessage DB 'Menu:', 0Dh, 0Ah,'1. Iniciar', 0Dh, 0Ah,'2. Cargar partida', 0Dh, 0Ah,'3. Salir', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la start_game de inicio de juego
; ------------------------------------------------
turnMsg DB 'Realizando sorteo aleatorio', 0Dh, 0Ah, '$'
turnDoneMsg DB 'Sorteo realizado', 0Dh, 0Ah, '$'
turnPlayerMsg DB 'Turno del jugador', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la option_2 de inicio de juego
; ------------------------------------------------
t2 DB 'op2', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la option_2 de inicio de juego
; ------------------------------------------------

; ------------------------------------------------
; Creamos las variables para el el sorteo del juego
; ------------------------------------------------
playerTurn DB ? ; Variable para el turno del jugador
; ------------------------------------------------
; Creamos las variables para el tablero
; ------------------------------------------------
table DB 81 DUP(0)
Wchar DB 57h
Bchar DB 42h
colTableStr DB '        A      B       C       D       E       F       G       H', 0Dh, 0Ah, '$'
lineTableStr DB '    +---+---+---+---+---+---+---+---+---+---+', 0Dh, 0Ah, '$'
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

; Iniciamos el bloque de código
.CODE
start:
main PROC

; Cargamos la dirección de inicio de la sección de datos en el registro AX y luego la cargamos en el registro DS,
mov ax, @data
mov ds, ax

printMsg infoMsg ; Imprimimos la información del programa

; Imprimimos el menu principal
mainMenu:
printMsg menuMessage ; Imprimimos el menú principal
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
            mov AH, 08h ; Cargamos a AH el código de interrupción para leer un caracter
            int 21 ; Llamamos a la interrupción
            cmp AL, 0Dh ; Comparamos el caracter leído con el código ASCII de ENTER
            jne wait_enter ; Con jne nos aseguramos que sea condicional, es decir, si no se presiona ENTER entonces
                           ; se vuelve a llamar a la interrupción para leer un caracter
                           ; Si se presiona ENTER entonces se continua con el programa
            ret ; Retornamos a la función main

start_game: ; Función para iniciar el juego
printMsg turnMsg ; Imprimimos el mensaje de inicio de juego
call random ; Llamamos a la función random para hacer el sorteo
printMsg turnDoneMsg ; Imprimimos el turno del jugador
printMsg turnPlayerMsg ; Imprimimos el turno del jugador
printMsg playerTurn ; Imprimimos el turno del jugador

upload_game:
printMsg t2 ;; Esta funcion servira para cargar una partida guardada


print_table: ;; Funcion para mostrar el tablero
;; Lo primero que hacemos es mostrar las columnas
printMsg colTableStr ; Imprimimos las columnas

;; Creamos una subrutina para generar numeros aleatorios entre el 0 y 1 tomando las milesimas de segundo del sistema

generate_random_number:
mov AH, 2Ch ; Cargamos a AH el codigo de interrupción para obtener el tiempo del sistema
int 21h ; Llamamos a la interrupción

mov AL, Dl ; Cargamos a AL el valor de las milesimas de segundo
and AL, 1 ; Aplicamos un AND con 1 para obtener el valor de las milesimas de segundo

cmp AL, 0 ; Comparamos el valor de AL con 0
je set_player_A ; Si el valor de AL es 0 entonces se llama a la función set_player_A
jmp set_player_B ; Si el valor de AL es 1 entonces se llama a la función set_player_B


;; Con esta subrutina, indicamos que el jugador A es el que inicia el juego
set_player_A:
mov playerTurn, 'A' ; Cargamos a playerTurn el valor de A
ret ; Retornamos a la función generate_random_number

;; Con esta subrutina, indicamos que el jugador B es el que inicia el juego
set_player_B:
mov playerTurn, 'B' ; Cargamos a playerTurn el valor de B
ret ; Retornamos a la función generate_random_number

exit: 
printMsg exitMsg ; Imprimimos el mensaje de salida
mov AH, 4Ch ; Cargamos a AH el codigo DOS para interrumpir el programa
int 21h ; Llamamos a la interrupción
;; El 4Ch sirve para terminar el programa


main ENDP
END start
