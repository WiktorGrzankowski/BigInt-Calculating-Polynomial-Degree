global polynomial_degree

section .text

; input :
; rdi - const int *y
; rsi - size_t n, length of *y array

; output :
; rax - minimal degree of a polynomial that satisfies given array

polynomial_degree:
                                ; save registers' values
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx 
    push    rbp

    xor     r12, r12            ; iterete through input array from 0
    mov     r13, rsi            ; save initial lenght of array
    dec     r13                 ; since in the following loop we access 
                                ; one element forward, decrement end of array 
    jz      .check_if_zero      ; only one element in input array
    .check_const_input:
                                ; check if input array consists of only one value
        mov     eax, [rdi + 4 * r12] 
        cmp     eax, [rdi + 4 * (r12 + 1)] 
        jne     .not_const      ; different elements occur in input array
        inc     r12 
        cmp     r12, r13 
        jne     .check_const_input
                                ; input array consists of only one value
    .check_if_zero:
        xor     rax, rax
        xor     ebx, ebx
        cmp     ebx, [rdi + 4 * r12] 
        jne     .finish_early   ; the value is not zero
        mov     rax, -1         ; it is zero only in the array
        jmp     .finish_early

    .not_const:  
                                ; upper estimate for the length of the array is n/32 + 3
                                ; where it's calculated in how many ints fit into one bigint
        mov     r15, rsi        ; r15 = n
        shr     r15, 5          ; r15 = n/32
        add     r15, 3          ; r15 = n/32 + 3
        mov     r8, r15         ; number of ints in bigint
        shl     r8, 2           ; number of bytes in each int
        imul    r8, rsi         ; number of bigints
        sub     rsp, r8         ; make space on the stack
        mov     r14, rsp        ; move pointer to r14
        xor     r12, r12        ; iterate through array from the start

    .create_bigint_loop:
        mov     r13, 1          ; iterate through bigint's segments from 1
                                ; because we set 0th outside of loop
        mov     r9d, [rdi + 4 * r12]
        mov     r8, r15         ; position in the bigint array
        imul    r8, r12
        shl     r8, 2
        mov     eax, 0          ; set for case, when first int is positive
        mov     [r14 + r8], r9d ; copy first element
        cmp     r9d, 0          ; sign of the first element
        jge     .fill_bigint_loop
                                ; first int is negative
        mov     eax, -1
                                ; fill remaining ints according to sign
        .fill_bigint_loop:
            mov     r8, r12     ; position in the array
            imul    r8, r15     ; move by length of r12 bigints
            shl     r8, 2    
            mov     r9, r13     ; move by position within bigint
            shl     r9, 2
            add     r8, r9
            mov     [r14 + r8], eax
            inc     r13
            cmp     r13, r15    ; is loop finished
            jne     .fill_bigint_loop
                                ; all ints are filled with correct sign
        inc     r12                 
        cmp     r12, rsi        
        jne     .create_bigint_loop
                                ; entire input array is copied to bigints

    mov     rbx, rsi            ; rbx - current length of array we look at

    .till_const_loop:
                                ; substract adjacent elements of array
                                ; until it either shrunk to 1 element
                                ; or all elements are equal to 0
        xor     r12, r12        ; iterate through array elements from 0
        .sub_loop:
            xor     r13, r13    ; iterate through bigint from 0
            mov     r8, r12     ; r8 - closer element
            imul    r8, r15     ; move by size of one bigint
            shl     r8, 2
            xor     r9, r9      ; r9 - further element

            mov     rcx, r15    ; iterate downwards
            mov     rdx, r15    
            shl     rdx, 2      ; rdx equals the length of one bigint

            clc                 ; reset carry flag
            .sub_bigint_loop:
                mov     r9, rdx ; move by length od one bigint
                                ; move within the bigint
                lea     r9, [r9 + r8] 
                mov     eax, [r14 + r9]
                sbb     eax, [r14 + r8]
                mov     [r14 + r8], eax
                                ; move iterators
                lea     r8, [r8 + 4]
                lea     r13, [r13 + 1]     
                loop .sub_bigint_loop
                                ; loop within a pair of bigints finished
            inc     r12
            cmp     r12, rbx
            jne     .sub_loop
                                ; all substractions finished
        dec     rbx             ; now array is shorter by one element
        cmp     rbx, 1          ; check if there is only one element left
        jnz     .before_check_for_const_loop 
                                ; only one element left
        xor     rdx, rdx        ; iterate through last bigint
        .check_last_element_loop:
            mov     eax, [r14 + 4 * rdx]
            cmp     eax, 0          
            jne     .last_is_not_zero
            inc     rdx
            cmp     rdx, r15     ; is loop finished
            jne     .check_last_element_loop
                                ; last bigint equals 0
            mov     rax, rsi        
            sub     rax, 2
            jmp     .finish
                                ; last bigint doesn't equal 0
                                ; result is the biggest possible answer
        .last_is_not_zero:
            mov     rax, rsi
            dec     rax
            jmp     .finish
                                ; there are at least two elements
        .before_check_for_const_loop:
            xor     rdx, rdx     ; iterate through array from 0
            mov     r12, r15    ; number of ints in bigint
            shl     r12, 2      ; size of one int
            imul    r12, rbx    ; number of bigints in array

        .check_for_const_loop:
            mov     eax, [r14 + rdx] 
            cmp     eax, 0
            jne     .till_const_loop 
                                ; zeroes only so far
                                ; look futher
            lea     rdx, [rdx + 4]
            cmp     rdx, r12
            jne     .check_for_const_loop
                                ; all bigints equal 0
            mov     rax, rsi  
            sub     rax, rbx
            dec     rax
            jmp     .finish
                                ; not all elements equal 0
        jnz     .till_const_loop 
    mov     rax, rsi            ; result is the biggest possible answer
    dec     rax

    .finish:
                                ; add to rsp number of bytes allocated
        mov     r8, r15
        shl     r8, 2
        imul    r8, rsi
        add     rsp, r8
    .finish_early:
                                ; pop registers, but don't add to rsp
                                ; since it wasn't moved
        pop     rbp
        pop     rbx
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        
        ret
