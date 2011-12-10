section .data                           ; data section, read-write

debugFormat	DB "%s: %d %d %d",10,0        ; this is a temporary var
strFormat:      DB "%s,%s,%s",10,0        ; this is a temporary var
strFormat2:     DB "%d,  %s,  %d",10,0   ; this is a temporary var
intFormat:      DB "%d,   %d,   %d",10,0  ; this is a
                                ; temporary var
minusFormat:    DB "-",0       ; print char (for '-')
intCharFormat:  DB "%d",0       ; print 1 digit
longFormat:     DB "%d %d %d %d",10,0 ;print 128 bit integer
resultStr:      DB "%d",10,0                      ; this is a temporary var
X:              times 39 DB 0
X_LSD:          DD 0
Y:              times 39 DB 0
Y_LSD:          DD 0
RES:            times 39 DB 0
RES_LSD:        DD (RES+38)
RES_MSD:        DD 0
X_SIGN:         DD 0
Y_SIGN:         DD 0
RES_SIGN:       DD 0
CARRY:          DB 0

section .text           ; our code is always in the .text section
        global calc     ; makes the function appear in global scope
        extern printf   ; tell linker that printf is defined elsewhere

calc:                                   ; functions are defined as labels
        push    ebp                     ; save Base Pointer (bp) original value
        mov     ebp, esp             ; use base pointer to access stack contents
        pushad                          ; push all variables onto stack

        push    DWORD RES
        push    DWORD [RES_MSD]
        push    DWORD [RES_LSD]
        push    intFormat
        call    printf
         add    esp, 16

        ;;;;; convert first number to X ;;;;;;;;
        push    DWORD [ebp+8]    ;pointer to x input string
        push    X
        push    X_SIGN
        push    X_LSD
        call    converter
        add     esp, 16
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;; convert second number to Y ;;;;;;;;
        push    DWORD [ebp+16]
        push    Y
        push    Y_SIGN
        push    Y_LSD
        call    converter
        add     esp, 16
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; push    X
        ;; push    X_SIGN
        ;; push    X_LSD
        ;; call    printX
        ;; add     esp, 12

        mov ebx, [ebp+12]       ;ebp stores the operator's char

        cmp byte [ebx] ,45
        je minus

        cmp byte [ebx] ,43
        je plus

        cmp byte [ebx] ,42
        je multiply

        cmp byte [ebx] ,47
        je divide


converter:
        push    ebp
        mov     ebp, esp

        mov     ecx, [ebp+20]       ;pointer to string
        mov     eax, [ebp+16]       ;pointer to the byte in X
        mov     edi, [ebp+12]
        mov     DWORD [edi], 0
        cmp     byte [ecx], 45
        jne     convloop
        mov     DWORD [edi], 1
        inc     ecx

convloop:
        cmp     byte [ecx], 0
        je      endConv
        cmp     byte [ecx], 10
        je      endConv
        mov     ebx, 0
        mov     bl, byte [ecx]
        sub     bl, 48
        mov     BYTE [eax], bl
        inc     ecx
        inc     eax
        jmp     convloop

endConv:
        mov     edi, [ebp+8]
        mov     DWORD [edi], eax

        mov     esp, ebp
        pop     ebp
        ret
minus:
        mov eax, [X]
        mov ebx, [Y]
        sub eax, ebx
        jmp print

plus:                           ; X + Y
        mov     ebx, [X_LSD]    ; X_LSD
        dec     ebx             ; X_LSD points to one place AFTER the LSD

        mov     edi, [Y_LSD]    ; Y_LSD
        dec     edi
        mov     edx, [RES_LSD]   ; RES_LSD (right edge)


adding_loop:
        mov     eax, 0
        mov     al, [ebx]

        pushad
        push    eax

        add     al, [edi]
        add     al, [CARRY]
        mov     BYTE [CARRY], 0
        cmp     al, 10
        jb      mod10OK
        sub     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
mod10OK:
        push    0
        push    eax

        mov     [edx], al

        push    intFormat
        call    printf
        add     esp, 16
        popa

        dec     ebx
        dec     edi
        dec     edx
        cmp     ebx, X
        jb      x_done
        cmp     edi, Y
        jb      y_done
        jmp     adding_loop

x_done:
        mov     al, [edi]
        adc     [edx], al
        dec     edi
        dec     edx
        cmp     edi, Y
        jb      plus_done
        jmp     x_done

y_done:
        mov     al, [ebx]
        adc     [edx], al
        dec     ebx
        dec     edx
        cmp     ebx, X
        jb      plus_done
        jmp     y_done

plus_done:
        adc     [edx], BYTE 0            ;not forggeting the last carry
        cmp     [edx], BYTE 1
        je      with_carry
        inc     edx
with_carry:
        mov     [RES_MSD], edx

        push    DWORD RES
        push    DWORD [RES_MSD]
        push    DWORD [RES_LSD]
        push    intFormat
        call    printf
        add    esp, 16

        jmp     print_result

multiply:
        mov eax, [X]
        mov ebx, [Y]
        imul eax, ebx
        jmp print

divide:
        mov     eax, [X]
        cdq
        mov     ebx, [Y]
        idiv    ebx
        jmp     print
print_result:

        push    DWORD RES
        push    DWORD [RES_MSD]
        push    DWORD [RES_LSD]
        push    intFormat
        call    printf
        add     esp, 16


        push    RES_MSD
        push    RES_SIGN
        push    RES_LSD
        call    printX
        add     esp, 12

        jmp     zero_and_ret

zero_and_ret:
        mov     ecx, RES
        mov     esi, RES_LSD
        mov     esi, [esi]     ; deref RES_LSD
zero_loop:
        cmp     ecx, esi
        je      ret
        mov     BYTE [ecx], 0
        inc     ecx
        jmp     zero_loop

ret:
        mov     BYTE [ecx], 0
        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     ebp
        ret                     ; return to C.


print:
        push eax
        push resultStr
        call printf
        add esp, 8

        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     ebp
        ret

printX:
        push    ebp
        mov     ebp, esp

        mov     ecx, [ebp+12]   ; RES_SIGN
        cmp     DWORD [ecx], 1
        jne     print_init
        push    minusFormat
        call    printf
        add     esp, 4

print_init:
        mov     ebx, [ebp+16]   ; X[0] / RES_MSD
        mov     ebx, [ebx]
        ;; mov     ebx, [RES_MSD]
        ;; mov     esi, [ebp+8]    ; X_LSD
        mov     esi, RES_LSD
        mov     esi, [esi]
        dec     esi
        ;; push    DWORD RES
        ;; push    DWORD [RES_MSD]
        ;; push    DWORD [RES_LSD]
        ;; push         intFormat
        ;; call    printf
        ;; add     esp, 16

        push    DWORD RES
        push    DWORD ebx
        push    DWORD esi
        push    intFormat
        call    printf
        add     esp, 16

print_loop:
        cmp     ebx, esi
        je      end_printx
        mov     edx, 0
        mov     dl, byte [ebx]
        pushad
        push    edx
        push    intCharFormat
        call    printf
        add     esp, 8
        popa
        inc     ebx
        jmp     print_loop

end_printx:

        pop ebp
        ret
