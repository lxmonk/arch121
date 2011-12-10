section .data                           ; data section, read-write
        strFormat:    DB "%s,%s,%s",10,0                ; this is a temporary var
        intFormat:    DB "%d,%s,%d",10,0                ; this is a temporary var
section .bss
X:
         resd 1 ; opernad 1
Y:
         resd 1 ; opernad 2
O:
         resb 1 ; operator

section .text                           ; our code is always in the .text section
        global calc                     ; makes the function appear in global scope
        extern printf                   ; tell linker that printf is defined elsewhere

calc:                                   ; functions are defined as labels
        push    ebp                     ; save Base Pointer (bp) original value
        mov     ebp, esp                ; use base pointer to access stack contents
        pushad                          ; push all variables onto stack

        mov ecx,[ebp+8]
        call convert
        mov [X],ebx
;	mov ecx,[ebp+12]
;	call convert
;	mov [O],ebx
        mov ecx,[ebp+16]
        call convert
        mov [Y],ebx
        push X
        push O
        push Y
        push intFormat
        call printf

        push dword [ebp+16]	; get function's 3rd argument
        push dword [ebp+12]	; get function's 2nd argument
        push dword [ebp+8]	; get function's 1st argument
        push strFormat
        call printf
        add esp,16


        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     dword ebp
        ret

convert:
        push	ebp
        mov	ebp, esp
        pushad

        mov	ebx, 0
        mov edx, 0 ; negative flag

        cmp byte[ecx],45 ; cheack if neg
        jne next_char
        mov edx,0xffff0000
        inc	ecx

next_char:
        mov dl,-48
        add dl,byte [ecx]
        cmp	byte [ecx],0
        je	char_end
        imul bx,10
        add bx,dx
        inc	ecx
        jmp next_char

char_end:
        popad
        mov	esp, ebp
        pop	ebp
        ret
