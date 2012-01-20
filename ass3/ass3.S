section .data                           ; data section, read-write
        CODES DB 1, 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 1, 0, 1, 2, 2, 2, 2, 2, 2, 1, 1, 0, 1, 1, 2, 2, 2, 2, 2, 2, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 1, 2, 2, 2, 2, 2, 1, 0, 1, 0, 1, 1, 2, 2, 2, 2, 2, 0, 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 2, 1, 1, 1, 1, 0, 0, 1, 1, 2, 2, 2, 1, 1, 0, 1, 0, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 0, 0, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 2, 0, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 0, 1, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 2, 2, 2, 2, 2, 2, 2, 0, 0, 1, 0, 0, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 2, 1, 0, 1, 0, 1, 0, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2
        VAL_TABLE DD 12, 40, 5, 27, 3, 61, 43, 4, 9, 971, 243, 26, 63, 8, 11, 41, 969, 3, 5, 14, 4, 120, 62, 970, 42, 963, 0
        LEN_TABLE DD 4, 6, 5, 5, 3, 6, 6, 4, 4, 10, 8, 5, 6, 4, 4, 6, 10, 4, 4, 4, 5, 7, 6, 10, 6, 10, 3

        TREE DD '~', 3, 6, '~', 9, 12, '~', 15, 18, '~', 39, 36, '~', 33, 45, '~', 30, 27, '~', 24, 21, '~', 69, 51, '~', 75, 72, '~', 48, 78, '~', 96, 93, '~', 102, 99, '~', 42, 105, ' ', -1, -1, '~', 111, 108, 'e', -1, -1, '~', 90, 87, '~', 66, 54, '~', 60, 57, 'm', -1, -1, 'w', -1, -1, 'f', -1, -1, '~', 156, 63, 't', -1, -1, '~', 81, 84, 'a', -1, -1, 'o', -1, -1, 'l', -1, -1, 'd', -1, -1, '~', 120, 123, '~', 114, 117, 'i', -1, -1, 'n', -1, -1, 's', -1, -1, 'h', -1, -1, 'r', -1, -1, 'c', -1, -1, 'u', -1, -1, 'b', -1, -1, 'p', -1, -1, 'y', -1, -1, 'g', -1, -1, 'v', -1, -1, '~', 135, 132, 'k', -1, -1, '~', 138, 141, '~', 153, 150, '~', 49, 48, 'x', -1, -1, 'j', -1, -1, 'q', -1, -1, 'z', -1, -1, '~', 126, 129

section .bss
        FREQ_TAB_PTR     resd 1
        LETTER_CODES_PTR resd 1
        TEXT_PTR         resd 1
        ENCODED_TEXT_PTR resd 1
        LEN              resd 1


section .text           ; our code is always in the .text section
        global  generateHuffmanCode ; makes the function appear in global scope
        global  encode
        global  decode

generateHuffmanCode:
        push    ebp             ; save Base Pointer (bp) original value
        mov     ebp, esp        ; use base pointer to access stack contents
        pushad                ; push all variables onto stack

        mov     eax, [ebp + 8]
        mov     [FREQ_TAB_PTR], eax
        mov     eax, [ebp + 12]
        mov     [LETTER_CODES_PTR], eax

        ;; copy the input to NODE_ARRAY
        cld
        mov     esi, [FREQ_TAB_PTR]
        ;; mov     edi, NODE_ARRAY
        mov     ecx, 27
        xor     eax, eax
lp:
        lodsd                   ; eax has the frequency
        stosd                   ; node[0] = frequency
        mov     eax, 27
        sub     eax, ecx
        stosd                   ; moving the numbers 0 ... 27 to
                                ; node[1] representing the chars 'a' -
                                ; 'z' + <space>
        add     edi, 8          ; leave '-1' as empty node pointers
        loop    lp



        popad                 ; restore all previously used registers
        mov   esp, ebp
        pop   ebp
        ret


encode:
        push    ebp             ; save Base Pointer (bp) original value
        mov     ebp, esp        ; use base pointer to access stack
                                ; contents
        pushad
        mov     eax, [ebp + 8]
        mov     [TEXT_PTR], eax
        mov     eax, [ebp + 16]
        mov     [ENCODED_TEXT_PTR], eax

        mov     esi, [TEXT_PTR] ; pointer to text
        mov     edi, [ENCODED_TEXT_PTR]
        mov     edx, [VAL_TABLE] ;pointer to vals
        mov     ebx, [LEN_TABLE] ; pointer to lens
        xor     ecx, ecx         ; counter
        xor     eax, eax
        mov     [edi], DWORD 0
        lodsb                   ; read a byte (char) from text

TEXT_LOOP:
        cmp     eax, 0
        je      END_LOOP
        cmp     eax, 32
        jne     a_z

        sub     eax, 6
        jmp     space
a_z:
        sub     eax, 97
space:
        imul    eax, 4
        add     ebx, eax
        mov     ebx, [ebx]
        mov     [LEN], ebx
        mov     ebx, [LEN_TABLE] ; pointer to lens
        add     edx, eax
        mov     eax, [edx]       ; eax has the right value
        mov     edx, [VAL_TABLE] ;pointer to vals
        shl     eax, cl
        add     cl, BYTE [LEN]  ; update counter
        or      [edi], eax
        lodsb

        cmp     cl, 16
        jb      TEXT_LOOP
        add     edi, 4
        mov     [edi], DWORD 0
        sub     edi, 2
        sub     cl, 16

        jmp     TEXT_LOOP

END_LOOP:
        popad            ; restore all previously used registers
        mov     esp, ebp
        pop     ebp
        ret

decode:
