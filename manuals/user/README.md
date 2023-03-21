# Práctica 3 - Damas Chinas
 
## Introducción
El juego consiste en un tablero de 9x9 posiciones. Cada jugador dispone de 10 fichas, además de que únicamente serán dos jugadores, para decidir quién empieza la partida, el programa elegirá de manera aleatoria al jugador que empieza. El objetivo es llevar todas las piezas al lugar de donde están las piezas del contrincante originalmente.

## Requerimientos
Para poder jugar a este juego, es necesario tener instalado un emulador de entorno de sistema operativo DOS (Disk Operating System), como por ejemplo [DOSBox](https://www.dosbox.com/). Además, es necesario tener instalado el compilador de lenguaje ensamblador x86, [MASM](https://www.masm32.com/).

## Instalación
Para poder jugar a este juego, es necesario ejecutar el archivo .EXE llamado `main.exe`que se encuentra en la raíz del proyecto. Para ello, es necesario abrir el emulador de DOSBox y ejecutar el comando `main.exe`.
```bash
main.exe
```

## Uso
Una vez ejecutado el programa, se mostrará el menú principal del juego, en el que se podrá elegir entre las siguientes opciones:
- Iniciar
- Cargar
- Salir

### Iniciar programa
Se mostrará un mensaje de la información del desarrollador

<img src="./assets/1.png" alt="Descripción de la imagen" width="150">

## Menú
El menú tendrá 3 opciones
- Iniciar: iniciará el juego
- Cargar: cargará una partida guardada
- Salir: saldrá del juego
<img src="./assets/3.png" alt="Descripción de la imagen" width="150">

### Iniciar juego
Se realizará el sorteo para ver quién empieza la partida
<img src="./assets/4.png" alt="Descripción de la imagen" width="150">

Se mostrará el

### Movimientos
El jugador podrá mover sus fichas, horizontalmente o verticalmente, no puede comerse a otras fichas pero si puede pasar encima de esas
<img src="./assets/5.png" alt="Descripción de la imagen" width="150">

Se solicitará la pieza que se desea mover, esta tendrá que ser en formato ColumnaFila, por ejemplo, si se desea mover la pieza de la columna F y fila 1, se deberá escribir F1

<img src="./assets/6.png" alt="Descripción de la imagen" width="150">


### Salir del juego
En la tercera opcion del menu, se cerrará la aplicación
<img src="./assets/7.png" alt="Descripción de la imagen" width="150">



