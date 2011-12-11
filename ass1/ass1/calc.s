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
TMP:            times 39 DB 0
TMP_SIGN:       DD 0
TMP_LSD:        DD 0



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

;;;;  START OF PLUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plus:             ; X + Y
        mov     edx, [X_SIGN]
        cmp     edx, [Y_SIGN]
        je      same_sign
;;; different signs
        cmp     DWORD [X_SIGN], 0
        jne     negative_x_pos_y
;;; X is positive and Y is negative, so:
        mov     DWORD [Y_SIGN], 1 ; change this to X - Y. For this
                                ; purpose, we're changing Y to positive.
        jmp     minus

negative_x_pos_y:
        ;; -X + Y ==> Y - X, so we're making
        ;; X positive, and use minus_reverse
        mov     DWORD [X_SIGN], 0
        jmp     minus_reverse
        jmp     minus

same_sign:
        mov     [RES_SIGN], edx   ;edx is still holding X's (and Y's)
                                ;sign.
        jmp     actual_plus


actual_plus:
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
	mov 	[edx] , al
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
	mov  	[edx], al
        dec     ebx
        dec     edx

        jmp     plus_y_done

plus_done:
	cmp     [CARRY], BYTE 0
	je      plus_no_carry
        mov     [edx], byte 1             ;not forggeting the last carry        
	dec 	edx
plus_no_carry:
	inc     edx
      	mov     [RES_MSD], edx
        jmp     print_result
;;;;   END OF PLUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; START OF MINUS REVERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
minus_reverse: ; Y - X
        mov     edi, [X_LSD]    ; X_LSD
        dec     edi             ; X_LSD points to one place AFTER the LSD
        mov     ebx, [Y_LSD]    ; Y_LSD
        dec     ebx
        mov     edx, [RES_LSD]   ; RES_LSD (right edge)
	mov     BYTE [CARRY], 0
	jmp minus_reverse_adding_loop

minus_reverse_adding_loop:	
        mov     eax, 0
        mov     al, [ebx] 	   ; digit of x -> al
        sub     al, byte [edi]     ; al - = digit of y
        sub     al, byte [CARRY]   ; al - carry
        mov     BYTE [CARRY], 0    ; carry = 0
        cmp     al, 0 ; al < 0
        jge      min_reversePositive 
        add     al, 10		     ; al+= 10 to get the real digit
        mov     BYTE [CARRY], 1      ;set carry to 1

min_reversePositive:
        mov     [edx], byte al       ; al -> (digit of res) 
        dec     ebx              ; y digit
        dec     edi		 ; x digit
        dec     edx 		 ; res digit
        cmp     edi, X 		 ; no more digit in x
        jb      minus_reverse_x_done
        cmp     ebx, Y 		 ; no more digit in y
        jb      minus_reverse_y_done
        jmp     minus_reverse_adding_loop

minus_reverse_y_done:
	cmp     edi, X 		; if no more digit in x 
        jb      minus_reverse_done
	; rebot RES and need to switch numbers	
        mov     ecx, RES
        mov     esi, RES_LSD
        mov     esi, [esi]     ; deref RES_LSD
reverse_zero_res_loop1:
        cmp     ecx, esi
        je      minus ; minus
        mov     BYTE [ecx], 0
        inc     ecx
        jmp     reverse_zero_res_loop1

minus_reverse_x_done:
        cmp     ebx, Y		; if no more digit in y
        jb      minus_reverse_done

	mov     al, byte  [ebx]		; digit of y -> al
	sub     al, byte  [CARRY]        ; al-=carry
	mov     BYTE [CARRY], 0		;carry = 0
        cmp     al, 0			; al < 0
        jge      xmin_reversePositive
        add     al, 10
        mov     BYTE [CARRY], 1      ;set carry to 1

xmin_reversePositive:	
	mov  	[edx], al		;al -> digit of res 
        dec     ebx			;digit of y
        dec     edx			;digit of res
        jmp     minus_reverse_x_done

minus_reverse_done:
	cmp     [CARRY], BYTE 0		
	je      minus_reverse_no_carry
        mov     [RES_SIGN], dword 1  ;not forggeting the last carry - > the number is neg
	; rebot RES and need to switch numbers	
        mov     ecx, RES
        mov     esi, RES_LSD
        mov     esi, [esi]     ; deref RES_LSD
reverse_zero_res_loop2:
        cmp     ecx, esi
        je      minus ; minus_reverse
        mov     BYTE [ecx], 0
        inc     ecx
        jmp     reverse_zero_res_loop2
    
minus_reverse_no_carry:
	inc     edx
      	mov     [RES_MSD], edx
        jmp     print_result

;;;;   END OF MINUS REVERSE ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;  START OF MINUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
minus:             ; X - Y
        mov     ebx, [X_LSD]    ; X_LSD
        dec     ebx             ; X_LSD points to one place AFTER the LSD

        mov     edi, [Y_LSD]    ; Y_LSD
        dec     edi
        mov     edx, [RES_LSD]   ; RES_LSD (right edge)
	mov     BYTE [CARRY], 0


minus_adding_loop:	

        mov     eax, 0
        mov     al, [ebx] 	   ; digit of x -> al

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
        add     al, 10		     ; al+= 10 to get the real digit
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
        dec     edi		 ; y digit
        dec     edx 		 ; res digit
        cmp     ebx, X 		 ; no more digit in x
        jb      minus_x_done
        cmp     edi, Y 		 ; no more digit in y
        jb      minus_y_done
        jmp     minus_adding_loop

minus_x_done:
	cmp     edi, Y 		; if no more digit in y 
        jb      minus_done
        mov     [RES_SIGN], dword 1  ;RES is neg
	; rebot RES and need to switch numbers	
        mov     ecx, RES
        mov     esi, RES_LSD
        mov     esi, [esi]     ; deref RES_LSD
zero_res_loop1:
        cmp     ecx, esi
        je      minus_reverse ; minus_reverse
        mov     BYTE [ecx], 0
        inc     ecx
        jmp     zero_res_loop1

	
;        mov     al, [edi]	  ; digit of y -> al
;	sub     al, byte [CARRY]  ; al-=carry      
;	mov     BYTE [CARRY], 0	  ; carry = 0
;        cmp     al, 0 		  ; al < 0
;        jge      xminPositive
;        add     al, 10			
;        mov     BYTE [CARRY], 1      ;set carry to 1
;xminPositive:	
;	mov 	[edx] , al 	; al -> digit of res
;        dec     edi		; digit of y
;        dec     edx		; digit of res
;        jmp     minus_x_done	

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
	mov  	[edx], al		;al -> digit of res 
        dec     ebx			;digit of x
        dec     edx			;digit of res

        jmp     minus_y_done

minus_done:
	cmp     [CARRY], BYTE 0		
	je      minus_no_carry
        mov     [RES_SIGN], dword 1  ;RES is neg
	; rebot RES and need to switch numbers	
        mov     ecx, RES
        mov     esi, RES_LSD
        mov     esi, [esi]     ; deref RES_LSD
zero_res_loop2:
        cmp     ecx, esi
        je      minus_reverse ; minus_reverse
        mov     BYTE [ecx], 0
        inc     ecx
        jmp     zero_res_loop2



;	mov eax,0
;	mov al,[RES_SIGN]
;	pushad
;	push eax
;	push resultStr1
;	call printf
;	add esp, 8
;	popad
        
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

        push   	dword [RES_MSD] 
        push    RES_SIGN
        push    RES_LSD
        call    printX
        add     esp, 12

        Jmp     zero_and_ret

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
        mov     DWORD [RES_MSD], 0 ; reset RES_MSD
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
        push    ebp              	; save Base Pointer (bp) original value
        mov     ebp, esp         	; use base pointer to access stack contents
        pushad 

        mov     ecx, [ebp+12]   ; RES_SIGN
        cmp     DWORD [ecx], 1
        jne     print_init
	pushad
        push    minusFormat
        call    printf
	popad
        add     esp, 4

print_init:

       ;; mov     ebx, [ebp+16]   ; X[0] / RES_MSD
         mov     ebx, [RES_MSD]
      ;;  mov     esi, [ebp+8]    ; X_LSD
         mov     esi, RES_LSD
        mov     esi, [esi]
	inc esi

deleteResZeros:
	cmp [ebx] , byte 0
	jne print_loop	
	inc ebx	
	jmp deleteResZeros

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

exchange_x_y:
        pushad

        cld                     ;starting from X[0], Y[0] and
                                ;incrementing
;;;  TMP <- X
        mov     esi, X
        mov     edi, TMP
        mov     ecx, 39
lp:
        lodsb
        stosb
        loop    lp

        mov     ecx, DWORD [X_SIGN]
        mov     DWORD [TMP_SIGN], ecx
        ;; mov     ecx, DWORD [X_LSD]
        ;; mov     DWORD [TMP_LSD], ecx

;;; X <- Y
        mov     esi, Y
        mov     edi, X
        mov     ecx, 39
lp2:
        lodsb
        stosb
        loop    lp2

        mov     ecx, DWORD [Y_SIGN]
        mov     DWORD [X_SIGN], ecx
        ;; mov     ecx, DWORD [Y_LSD]
        ;; mov     DWORD [X_LSD], ecx

;;; Y <- TMP
        mov     esi, TMP
        mov     edi, Y
        mov     ecx, 39
lp3:
        lodsb
        stosb
        loop    lp3

        mov     ecx, DWORD [TMP_SIGN]
        mov     DWORD [Y_SIGN], ecx
        ;; mov     ecx, DWORD [TMP_LSD]
        ;; mov     DWORD [Y_LSD], ecx

;;; exchange LSDs:
debugLabel:
        mov     ecx, [X_LSD]
        sub     ecx, X
;;; return
        popad
        ret
