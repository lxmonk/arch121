section .data                           ; data section, read-write

debugFormat:	DB "-----",10,0        ; this is a temporary var
strFormat:      DB "%s,%s,%s",10,0        ; this is a temporary var
strFormat2:     DB "%d,  %s,  %d",10,0   ; this is a temporary var
intFormat:      DB "%d,   %d,   %d",10,0  ; this is a
                                ; temporary var
minusFormat:    DB "-",0       ; print char (for '-')
intCharFormat:  DB "%d",0       ; print 1 digit
newLineFormat:  DB " ",10,0       ; print 1 digit
longFormat:     DB "%d %d %d %d",10,0 ;print 128 bit integer
resultStr:      DB "%d",10,0                      ; this is a temporary var
resultStr1:      DB "--%d",10,0                      ; this is a temporary var

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
TMP:            DD 0
TMP_LSD:        DD 0
TMP_SIGN:       DD 0

section .text           ; our code is always in the .text section
        global calc     ; makes the function appear in global scope
        extern printf   ; tell linker that printf is defined elsewhere

calc:                                   ; functions are defined as labels
        push    ebp                     ; save Base Pointer (bp) original value
        mov     ebp, esp             ; use base pointer to access stack contents
        pushad                          ; push all variables onto stack


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

;;;;;;;; START OF CONVERTOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;  END OF CONVERTOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

different_signs_in_plus:
        cmp     [X_SIGN], DWORD 1
        jne     x_plus_y_minus
        ;; X <= 0, Y >= 0
        cld
        mov     esi, X            ; -X + Y => Y - X
        mov     edi, TMP          ; so exchange (XCHG) X and Y and make
        mov     ecx, 39           ; them both positive
lp:
        lodsd
        stosd
        loop lp

        cld
        mov     esi, Y
        mov     edi, X
        mov     ecx, 39
lp2:
        lodsd
        stosd
        loop lp2

        cld
        mov     esi, TMP
        mov     edi, Y
        mov     ecx, 39
lp3:
        lodsd
        stosd
        loop lp3

        xchg    eax, [X_LSD]
        xchg    eax, [Y_LSD]
        xchg    eax, [X_LSD]

        mov     DWORD [X_SIGN], 0     ;X is now positive
        mov     DWORD [Y_SIGN], 0     ;Y is also now positive
        jmp     minus
x_plus_y_minus:
        mov     DWORD [Y_SIGN], 0     ; X + (-Y) => X - Y, so make Y positive
        jmp     minus           ; and goto minus
;;;;  START OF PLUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plus:             ; X + Y
        mov     ebx, [X_SIGN]   ; compare signs of X, Y and act
        ;; mov     ebx, [ebx]      ;; accordingly.
        cmp     ebx, [Y_SIGN]
        jne     different_signs_in_plus
        mov     [RES_SIGN], ebx ; +a + +b => a + b, -a + -b => -1 * (a + b)

        mov     ebx, [X_LSD]    ; X_LSD
        dec     ebx             ; X_LSD points to one place AFTER the LSD

        mov     edi, [Y_LSD]    ; Y_LSD
        dec     edi
        mov     edx, [RES_LSD]   ; RES_LSD (right edge)
        mov     BYTE [CARRY], 0


plus_adding_loop:

        mov     eax, 0
        mov     al, [ebx]

        add     al, byte [edi]
        add     al, byte [CARRY]
        mov     BYTE [CARRY], 0

;	pushad
;	push eax
;	push resultStr
;	call printf
;	add esp, 8
;	popad

        cmp     al, 10
        jb      plus_mod10OK
        sub     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
plus_mod10OK:
        mov     [edx], byte al

;	mov eax,0
;	mov al,[edx]
;	pushad
;	push eax
;	push resultStr1
;	call printf
;	add esp, 8
;	popad


        dec     ebx
        dec     edi
        dec     edx
        cmp     ebx, X
        jb      plus_x_done
        cmp     edi, Y
        jb      plus_y_done
        jmp     plus_adding_loop
plus_x_done:
        cmp     edi, Y
        jb      plus_done

        mov     al, [edi]
        add     al, byte [CARRY]
        mov     BYTE [CARRY], 0
        cmp     al, 10
        jb      plus_xmod10OK
        sub     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
plus_xmod10OK:
        mov     [edx] , al
        dec     edi
        dec     edx

        jmp     plus_x_done

plus_y_done:
        cmp     ebx, X
        jb      plus_done

        mov     al, byte  [ebx]
        add     al, byte  [CARRY]
        mov     BYTE [CARRY], 0
        cmp     al, 10
        jb      plus_ymod10OK
        sub     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
plus_ymod10OK:
        mov     [edx], al
        dec     ebx
        dec     edx

        jmp     plus_y_done

plus_done:
        cmp     [CARRY], BYTE 0
        je      plus_no_carry
        mov     [edx], byte 1             ;not forggeting the last carry
        dec     edx
plus_no_carry:
        inc     edx
        mov     [RES_MSD], edx
        jmp     print_result
;;;;   END OF PLUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;  START OF MINUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
minus:             ; X - Y
        mov     ebx, [X_LSD]    ; X_LSD
        dec     ebx             ; X_LSD points to one place AFTER the LSD

        mov     edi, [Y_LSD]    ; Y_LSD
        dec     edi
        mov     edx, [RES_LSD]   ; RES_LSD (right edge)
        mov     BYTE [CARRY], 0


minus_adding_loop:

        mov     eax, 0
        mov     al, [ebx]          ; digit of x -> al

        sub     al, byte [edi]     ; al - = digit of y
        sub     al, byte [CARRY]   ; al - carry
        mov     BYTE [CARRY], 0    ; carry = 0

;	pushad
;	push eax
;	push resultStr
;	call printf
;	add esp, 8
;	popad

        cmp     al, 0 ; al < 0
        jge      minPositive
        add     al, 10               ; al+= 10 to get the real digit
        mov     BYTE [CARRY], 1      ;set carry to 1
minPositive:
        mov     [edx], byte al       ; al -> (digit of res)

;	mov eax,0
;	mov al,[edx]
;	pushad
;	push eax
;	push resultStr1
;	call printf
;	add esp, 8
;	popad


        dec     ebx              ; x digit
        dec     edi              ; y digit
        dec     edx              ; res digit
        cmp     ebx, X                   ; no more digit in x
        jb      minus_x_done
        cmp     edi, Y                   ; no more digit in y
        jb      minus_y_done
        jmp     minus_adding_loop
minus_x_done:
        cmp     edi, Y                  ; if no more digit in y
        jb      minus_done

        mov     al, [edi]         ; digit of y -> al
        sub     al, byte [CARRY]  ; al-=carry
        mov     BYTE [CARRY], 0           ; carry = 0
        cmp     al, 0             ; al < 0
        jge      xminPositive
        add     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
xminPositive:
        mov     [edx] , al      ; al -> digit of res
        dec     edi		; digit of y
        dec     edx		; digit of res

        jmp     minus_x_done

minus_y_done:
        cmp     ebx, X		; if no more digit in X
        jb      minus_done

        mov     al, byte  [ebx]		; digit of x -> al
        sub     al, byte  [CARRY]        ; al-=carry
        mov     BYTE [CARRY], 0		;carry = 0
        cmp     al, 0			; al < 0
        jge      yminPositive
        add     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1
yminPositive:
        mov     [edx], al		;al -> digit of res
        dec     ebx			;digit of x
        dec     edx			;digit of res

        jmp     minus_y_done

minus_done:
        cmp     [CARRY], BYTE 0
        je      minus_no_carry
        mov     [RES_SIGN], dword 1  ;not forggeting the last carry - > the number is neg


        mov eax,0
        mov al,[RES_SIGN]
        pushad
        push eax
        push resultStr1
        call printf
        add esp, 8
        popad

minus_no_carry:
        inc     edx
        mov     [RES_MSD], edx
        jmp     print_result
;;;;   END OF MINUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

        push    dword [RES_MSD]
        push    RES_SIGN
        push    RES_LSD
        call    printX
        add     esp, 12

        Jmp     zero_and_ret

zero_and_ret:
        cld
        mov     edi, RES
        mov     ecx, 39
        xor     eax, eax
        rep     stosd
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
        push    ebp                     ; save Base Pointer (bp) original value
        mov     ebp, esp             ; use base pointer to access stack contents
        ;; pushad

        mov     ecx, [ebp+12]   ; RES_SIGN
        cmp     DWORD [ecx], 1
        jne     print_init
        pushad
        push    minusFormat
        call    printf
        popad
        add     esp, 4

print_init:

;	pushad
;         push    DWORD RES
;         push      DWORD [RES_MSD]
;         push    DWORD [RES_LSD]
;         push         intFormat
;         call    printf
;         add     esp, 16
;	popad

       ;; mov     ebx, [ebp+16]   ; X[0] / RES_MSD
         mov     ebx, [RES_MSD]
      ;;  mov     esi, [ebp+8]    ; X_LSD
         mov     esi, RES_LSD
        mov     esi, [esi]
        dec     esi
        ;; push    DWORD RES
        ;; push    DWORD [RES_MSD]
        ;; push    DWORD [RES_LSD]
        ;; push         intFormat
        ;; call    printf
        ;; add     esp, 16



;	pushad
;         push    DWORD RES
;         push    DWORD ebx
;         push    DWORD esi
;         push    intFormat
 ;        call    printf
;         add     esp, 16
;	popad

print_loop:
        cmp     ebx, esi
        je      end_printx
        mov     edx, 0
        mov     dl, [ebx]
        pushad
        push    edx
        push    intCharFormat
        call    printf
        add     esp, 8
        popad
        inc     ebx
        jmp     print_loop

end_printx:
        push    newLineFormat ; newline
        call    printf
        add     esp, 4

        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     dword ebp
        ret
