.MODEL small
.STACK
.RADIX 16
.DATA

.CODE
inicio: 
    main proc
        mov al, 0
        mov ah, 04ch
        int 21
    main endp
END inicio