section .data                    	; data section, read-write
        an:    DD 0              	; this is a temporary var

section .text                    	; our code is always in the .text section
        global do_str            	; makes the function appear in global scope
        extern printf            	; tell linker that printf is defined elsewhere 				; (not used in the program)

do_str:                          	; functions are defined as labels
        push    ebp              	; save Base Pointer (bp) original value
        mov     ebp, esp         	; use base pointer to access stack contents
        pushad                   	; push all variables onto stack
        mov ecx, dword [ebp+8]	    ; get function argument
;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE STARTS HERE ;;;;;;;;;;;;;;;; 

	mov	dword [an], 0		; initialize answer
label_here:
    cmp byte [ecx], 60
    jz lswitch
    cmp byte [ecx], 62
    jz rswitch
    cmp byte [ecx], 97   ; 'a' == 97
    jl reloop          
    cmp byte [ecx], 122  ; 'z' == 122
    jle lowercase
    jmp reloop

lswitch:
    mov byte [ecx], 123  ; '<' becomes '{' ('{' == 123)
    inc dword [an]
    jmp reloop

rswitch:
    mov byte [ecx], 125
    inc dword [an]
    jmp reloop

lowercase:
    sub byte [ecx], 32
    inc dword [an]
    jmp reloop

	 ; Your code goes somewhere around here...
reloop:
	inc	ecx      		; increment pointer
	cmp	byte [ecx], 0    		; check if byte pointed to is zero
	jnz	label_here       		; keep looping until it is null terminated

;;;;;;;;;;;;;;;; FUNCTION EFFECTIVE CODE ENDS HERE ;;;;;;;;;;;;;;;; 
         popad                    ; restore all previously used registers
         mov     eax,[an]         ; return an (returned values are in eax)
         mov     esp, ebp
         pop     dword ebp
         ret
