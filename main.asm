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
              mov ax, @data          ; ax = offset de la cadena
              mov ds, ax             ; ds = segmento de la cadena
              mov ah, 09h            ; imprimir cadena
              lea dx, str     ; dx = offset de la cadena
              int 21h                ; imprimir cadena
endm

; ------------------------------------------------
; Imprimir un caracter ascii
; esta macro se encarga de imprimir un carácter ASCII en la pantalla. Para ello, primero carga la dirección de inicio 
; de la sección de datos en el registro AX y luego la carga en el registro DS, lo que permite acceder a la memoria de 
; la cadena. Luego, carga el carácter de impresión de carácter en el registro AH y el carácter ASCII en el registro DL, 
; y finalmente llama a la interrupción 21h para imprimir el carácter.
; ------------------------------------------------
printAscii macro ascii
                mov ax, @data     ; ax = offset de la cadena
                mov ds, ax        ; ds = segmento de la cadena
                mov ah, 02h       ; imprimir caracter
                mov dl, ascii     ; dx = offset de la cadena
                int 21h           ; imprimir cadena
endm

; Configuración del programa
.MODEL small
.STACK
.RADIX 16 ; para que los números se muestren en hexadecimal
.DATA

; Creamos la información de incio, seguido de la espera de ENTER para pasar al menú
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,
     'Facultad de Ingenieria', 0Dh, 0Ah,
     'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,
     'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,
     'Seccion B', 0Dh, 0Ah,
     'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,
     '202112145' , 0Dh, 0Ah,
     0Dh, 0Ah,
     'ENTER para continuar' , 0Dh, 0Ah, '$'

; Creamos la información del menú
menuMessage DB 'Menu:', 0Dh, 0Ah,
     '1. Iniciar', 0Dh, 0Ah,
     '2. Cargar partida', 0Dh, 0Ah,
     '3. Salir', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la option_1 de inicio de juego
; ------------------------------------------------
t1 DB 'op1', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la option_2 de inicio de juego
; ------------------------------------------------
t2 DB 'op2', 0Dh, 0Ah, '$'

; ------------------------------------------------
; Variables para la option_2 de inicio de juego
; ------------------------------------------------



; ------------------------------------------------
; Creamos las variables para el tablero
; ------------------------------------------------
table DB 10 DUP(0)
Wchar DB 57h
Bchar DB 42h
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

mov ah, 09h             ; Imprimimos la información de inicio
lea dx, infoMsg
int 21h

mov ah, 08h             ; Esperamos a que se presione ENTER
int 21h

menu:                   ; Creamos un label para el menú

printMsg menuMessage    ; Imprimimos el menú

mov ah, 00h             ; Si no es ninguna de las opciones, volvemos a imprimir el menú
int 16h

cmp al, 31              ; 31 es el código ASCII de 1
je option_1             ; Si es 1, saltamos a la opción 1
cmp al, 32              ; 32 es el código ASCII de 2
je option_2             ; Si es 2, saltamos a la opción 2
cmp al, 33              ; 33 es el código ASCII de 3
je option_3             ; Si es 3, saltamos a la opción 3

jmp menu                ; Si no es ninguna de las opciones, volvemos a imprimir el menú


option_3:               ; Colocamos la salida del programa
printMsg exitMsg        ; Imprimimos el mensaje de error
jmp exit                ; Llamamos a la rutina de salida

option_1:               ; Llamamos a la rutina de inicio de juego
printMsg t1
jmp exit

option_2:               ; Llamamos a la rutina de carga de juego
printMsg t2
jmp exit

exit:
mov ah, 4Ch
int 21h

main ENDP
END start


