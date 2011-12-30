section .data                           ; data section, read-write

section .bss
H:      resd 1
W:      resd 1
pMaze:  resd 1
ROW:    resd 1
COL:    resd 1
DIST:   resd 1
RESULT: resd 1

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

        push    DWORD 0               ; row for rec
        push    DWORD 0               ; col for rec
        push    DWORD '2'               ; distance for rec
        call    rec             ; call recursive function
        add     esp, 12

        mov     eax, [H]
        mul     DWORD [W]
        dec     eax
        add     eax, [pMaze]
        mov     eax, [eax]
        mov     [RESULT], eax


        popad                    ; restore all previously used registers
        mov     esp, ebp
        pop     ebp
        mov     eax, [RESULT]
        sub     eax, 38
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
        add     eax, [pMaze]    ; eax now holds maze[row][col]

        mov     cl, [DIST]
        mov     [eax], cl      ; writing the distance to
                                ; maze[row][col]
        mov     ebx, eax
        inc     DWORD [DIST]

call_for_up:
        cmp     [ROW], DWORD 0  ; if row == 0 - don't go up
        je      call_for_right

        mov     ecx, ebx
        sub     ecx, [W]        ; ecx points to 1-up
        mov     cl, [ecx]      ; ecx = maze[...][...] 1 up
        cmp     cl, '1'        ; wall
        je      call_for_right

        cmp     cl, [DIST]     ; no improvement from this path
        ;;  we should pay attention to 0.
        jbe     call_for_right

        ;; do the actual job
        dec     DWORD [ROW]
        push    DWORD [ROW]
        inc     DWORD [ROW]
        push    DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_right:
        mov     edx, [COL]
        cmp     edx, [W]
        je      call_for_down

        mov     ecx, ebx
        add     ecx, 1          ; ecx points to 1-down
        mov     cl, [ecx]      ; ecx = maze[...][...] 1 down
        cmp     cl, '1'        ; wall
        je      call_for_down

        cmp     cl, [DIST]     ; no improvement from this path
        jbe     call_for_down

        ;; do the actual job
        push    DWORD [ROW]
        inc     DWORD [COL]
        push    DWORD [COL]
        dec     DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_down:
        mov     edx, [ROW]
        cmp     edx, [H]
        je      call_for_left

        mov     ecx, ebx
        add     ecx, [W]        ; ecx points to 1-down
        mov     cl, [ecx]      ; ecx = maze[...][...] 1 down
        cmp     cl, '1'        ; wall
        je      call_for_left

        cmp     cl, [DIST]     ; no improvement from this path
        jbe     call_for_left

        ;; do the actual job
        inc     DWORD [ROW]
        push    DWORD [ROW]
        dec     DWORD [ROW]
        push    DWORD [COL]
        push    DWORD [DIST]
        call    rec
        add     esp, 12

call_for_left:
        mov     edx, [COL]
        cmp     edx, 0
        je      end_rec

        mov     ecx, ebx
        sub     ecx, 1          ; ecx points to 1-down
        mov     ecx, [ecx]      ; ecx = maze[...][...] 1 down
        cmp     cl, '1'        ; wall
        je      end_rec

        cmp     cl, [DIST]     ; no improvement from this path
        jbe     end_rec

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
