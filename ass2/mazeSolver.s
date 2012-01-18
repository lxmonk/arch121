section .data                           ; data section, read-write
MAZE:   times 20000 DD 0                ;maxima size is 128^2
                                ;according to the C file
RESULT: DD  0

section .bss

H:      resd 1
W:      resd 1
pMaze:  resd 1
ROW:    resd 1
COL:    resd 1
DIST:   resd 1


section .text           ; our code is always in the .text section
        global mazeSolver     ; makes the function appear in global scope
        ;; extern printf   ; tell linker that printf is defined elsewhere

mazeSolver:                                   ; functions are defined as labels
        push    ebp                     ; save Base Pointer (bp) original value
        mov     ebp, esp             ; use base pointer to access stack contents
        pushad                   ; push all variables onto stack

        mov     edx, [ebp + 8]
        mov     [pMaze], edx

        mov     edx, [ebp + 12]
        mov     [H], edx

        mov     edx, [ebp + 16]
        mov     [W], edx

        jmp     convert_maze
back:
        push    DWORD 0               ; row for rec
        push    DWORD 0               ; col for rec
        push    DWORD '2'               ; distance for rec
        call    rec             ; call recursive function
        add     esp, 12

        mov     eax, [H]
        mul     DWORD [W]
        dec     eax
        mov     edi, 4
        mul     edi
        add     eax, MAZE
        mov     eax, [eax]
        mov     [RESULT], eax


        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     ebp
        cmp     DWORD [RESULT], '1' ; was 1
        jnbe	there_is_a_path    ; was je

        mov     eax,-1
        ret
there_is_a_path:
        mov     eax, [RESULT]
        sub     eax, 50
        ret


rec:
        push    ebp             ; save Base Pointer (bp) original value
        mov     ebp, esp        ; use base pointer to access stack contents
        pushad                  ; push all variables onto stack

        mov     edx, [ebp + 16]
        mov     [ROW], edx

        mov     edx, [ebp + 12]
        mov     [COL], edx

        mov     edx, [ebp + 8]
        mov     [DIST], edx

        mov     eax, [ROW]      ; eax will hold maze[row][col]
        mul     DWORD [W]        ; row * w
        add     eax, [COL]      ; row * w + col
        mov     edi, 4
        mul     edi             ; multiply by 4, since we're using DWORDs
        add     eax, MAZE    ; eax now holds maze[row][col]

        cmp     DWORD [eax], '1'        ; if the first place is a wall?
        je      end_rec

        mov     ecx, [DIST]
        mov     [eax], ecx      ; writing the distance to
                                ; maze[row][col]
        mov     ebx, eax
        inc     DWORD [DIST]
        inc	DWORD [ebp + 8]

call_for_up:
        cmp     [ROW], DWORD 0  ; if row == 0 - don't go up
        je      call_for_right

        mov     ecx, ebx
        sub     ecx, [W]        ; ecx will point to 1-up (1)
        sub     ecx, [W]        ; we're subtracting 4 times (2)
        sub     ecx, [W]        ; since we're using DWORDs (3)
        sub     ecx, [W]        ; and don't want to involve eax (4)
        mov     ecx, [ecx]      ; ecx = maze[...][...] 1 up

        cmp     ecx, '0'        ; empty
        je      do_up

        cmp     ecx, '1'        ; wall
        je      call_for_right

        cmp     ecx, [DIST]     ; no improvement from this path
        jbe     call_for_right
do_up:
        ;; do the actual job
        dec     DWORD [ROW]
        push    DWORD [ROW]
        inc     DWORD [ROW]
        push    DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_right:
        mov     edx, [ebp + 16]
        mov     [ROW], edx

        mov     edx, [ebp + 12]
        mov     [COL], edx

        mov     edx, [ebp + 8]
        mov     [DIST], edx

        mov     edx, [COL]
        inc     edx
        cmp     edx, [W]
        je      call_for_down

        mov     ecx, ebx
        add     ecx, 4          ; ecx points to 1-right
        mov     ecx, [ecx]      ; ecx = maze[...][...] 1 down

        cmp     ecx, '0'        ; empty
        je      do_right

        cmp     ecx, '1'        ; wall
        je      call_for_down

        cmp     ecx, [DIST]     ; no improvement from this path
        jbe     call_for_down
do_right:
        ;; do the actual job
        push    DWORD [ROW]
        inc     DWORD [COL]
        push    DWORD [COL]
        dec     DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_down:
        mov     edx, [ebp + 16]
        mov     [ROW], edx

        mov     edx, [ebp + 12]
        mov     [COL], edx

        mov     edx, [ebp + 8]
        mov     [DIST], edx

        mov     edx, [ROW]
        inc     edx
        cmp     edx, [H]
        je      call_for_left

        mov     ecx, ebx
        add     ecx, [W]        ; ecx will point to 1-down (1)
        add     ecx, [W]        ; once we'll add the Width to it (2)
        add     ecx, [W]        ; 4 times, since we're using DWORDs (3)
        add     ecx, [W]        ; done. (4)
        mov     ecx, [ecx]      ; ecx = maze[...][...] 1 down

        cmp     ecx, '0'        ; empty
        je      do_down

        cmp     ecx, '1'        ; wall
        je      call_for_left

        cmp     ecx, [DIST]     ; no improvement from this path
        jbe     call_for_left
do_down:
        ;; do the actual job
        inc     DWORD [ROW]
        push    DWORD [ROW]
        dec     DWORD [ROW]
        push    DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_left:
        mov     edx, [ebp + 16]
        mov     [ROW], edx

        mov     edx, [ebp + 12]
        mov     [COL], edx

        mov     edx, [ebp + 8]
        mov     [DIST], edx

        mov     edx, [COL]
        cmp     edx, 0
        je      end_rec

        mov     ecx, ebx
        sub     ecx, 4          ; ecx points to 1-down
        mov     ecx, [ecx]      ; ecx = maze[...][...] 1 down

        cmp     ecx, '0'        ; empty
        je      do_left

        cmp     ecx, '1'        ; wall
        je      end_rec

        cmp     ecx, [DIST]     ; no improvement from this path
        jbe     end_rec
do_left:
        ;; do the actual job
        push    DWORD [ROW]
        dec     DWORD [COL]
        push    DWORD [COL]
        inc     DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

end_rec:
        popad
        mov     esp, ebp
        pop     ebp

        ret

convert_maze:
        cld
        mov     esi, [pMaze]
        mov     edi, MAZE
        mov     eax, [H]
        mul     DWORD [W]
        mov     ecx, eax
        xor     eax, eax
lp:
        lodsb
        stosd
        loop lp
        jmp     back
