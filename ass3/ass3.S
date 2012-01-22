section .data                           ; data section, read-write
        CODES DB 1, 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 1, 0, 1, 2, 2, 2, 2, 2, 2, 1, 1, 0, 1, 1, 2, 2, 2, 2, 2, 2, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 1, 2, 2, 2, 2, 2, 1, 0, 1, 0, 1, 1, 2, 2, 2, 2, 2, 0, 1, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 2, 1, 1, 1, 1, 0, 0, 1, 1, 2, 2, 2, 1, 1, 0, 1, 0, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 0, 1, 0, 0, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 2, 0, 0, 1, 1, 2, 2, 2, 2, 2, 2, 2, 0, 1, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 2, 2, 2, 2, 2, 2, 2, 0, 0, 1, 0, 0, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 2, 1, 0, 1, 0, 1, 0, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2

        VAL_TABLE DD 12, 40, 5, 27, 3, 61, 43, 4, 9, 971, 243, 26, 63, 8, 11, 41, 969, 3, 5, 14, 4, 120, 62, 970, 42, 963, 0

        LEN_TABLE DD 4, 6, 5, 5, 3, 6, 6, 4, 4, 10, 8, 5, 6, 4, 4, 6, 10, 4, 4, 4, 5, 7, 6, 10, 6, 10, 3

        TREE DD '~', TREE + 3, TREE + 6, '~', TREE + 9, TREE + 12, '~', TREE + 15, TREE + 18, '~', TREE + 39, TREE + 36, '~', TREE + 33, TREE + 45, '~', TREE + 30, TREE + 27, '~', TREE + 24, TREE + 21, '~', TREE + 69, TREE + 51, '~', TREE + 75, TREE + 72, '~', TREE + 48, TREE + 78, '~', TREE + 96, TREE + 93, '~', TREE + 102, TREE + 99, '~', TREE + 42, TREE + 105, ' ', TREE - 1, TREE - 1, '~', TREE + 111, TREE + 108, 'e', TREE - 1, TREE - 1, '~', TREE + 90, TREE + 87, '~', TREE + 66, TREE + 54, '~', TREE + 60, TREE + 57, 'm', TREE - 1, TREE - 1, 'w', TREE - 1, TREE - 1, 'f', TREE - 1, TREE - 1, '~', TREE + 156, TREE + 63, 't', TREE - 1, TREE - 1, '~', TREE + 81, TREE + 84, 'a', TREE - 1, TREE - 1, 'o', TREE - 1, TREE - 1, 'l', TREE - 1, TREE - 1, 'd', TREE - 1, TREE - 1, '~', TREE + 120, TREE + 123, '~', TREE + 114, TREE + 117, 'i', TREE - 1, TREE - 1, 'n', TREE - 1, TREE - 1, 's', TREE - 1, TREE - 1, 'h', TREE - 1, TREE - 1, 'r', TREE - 1, TREE - 1, 'c', TREE - 1, TREE - 1, 'u', TREE - 1, TREE - 1, 'b', TREE - 1, TREE - 1, 'p', TREE - 1, TREE - 1, 'y', TREE - 1, TREE - 1, 'g', TREE - 1, TREE - 1, 'v', TREE - 1, TREE - 1, '~', TREE + 135, TREE + 132, 'k', TREE - 1, TREE - 1, '~', TREE + 138, TREE + 141, '~', TREE + 153, TREE + 150, '~', TREE + 49, TREE + 48, 'x', TREE - 1, TREE - 1, 'j', TREE - 1, TREE - 1, 'q', TREE - 1, TREE - 1, 'z', TREE - 1, TREE - 1, '~', TREE + 126, TREE + 129


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
