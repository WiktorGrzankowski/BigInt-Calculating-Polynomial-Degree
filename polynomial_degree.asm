global polynomial_degree

section .text

; input :
; rdi - tablica intów
; rsi - rozmiar tablicy

; wynik :
; rbp - stopien wielomianu

polynomial_degree:
    push r12
    push r13
    push r14
    push r15
    push rbx 
    push rbp

    mov r12, 0 ; iterator po tablicy od zera
    mov r13, rsi
    dec r13
    jz .check_if_zero
    .check_const_input:
        ; sprawdź, czy początkowy input to tablica o stałych wartościach
        ; tablica jest pod rdi
        mov eax, dword [rdi + 4 * r12] ; bliższy element
        cmp eax, dword [rdi + 4 * (r12 + 1)] ; dalszy element
        jne .not_const ; elementy są różne
        inc r12 ; zwiększamy iterator po tablicy
        cmp r12, r13 ; czy doszliśmy do końca tablicy
        jne .check_const_input
        ; stała tablica, teraz pytanie, czy z zerami
    .check_if_zero:
        mov rax, 0
        mov ebx, 0
        cmp ebx, dword [rdi + 4 * r12] ; czy w tablicy jest 0
        jne .finish_early
        mov rax, -1
        jmp .finish_early


    .not_const:
        ; ile bedzie mial bigint? 3 inty
        ; więc rezerwujemy 4*4*3 bajty - 4biginty, kazdy po 3*4 bajty
        ; w sumie to 3 biginty, ale to już nieistotne zupełnie    
        mov r12, 0 ; iterator po elementach tablicy od zera

        ; poczatek obliczania dlugosci
        mov r15, rsi ; r15 = n
        
        shr r15, 5 ; r15 = n/32
        add r15, 3 ; r15 = n/32 + 3, może byc o jedno za dużo, ale dobra
        mov r8, r15 ; dlugosc biginta
        imul r8, 4 ; liczba bajtów w int
        imul r8, rsi ; liczba intów
        sub rsp, r8 ; rezerwowana liczba bajtów na stosie
        mov r14, rsp ; przepisanie wskaźnika na początek stosu
        ; koniec obliczania dlugosci


    .create_bigint_loop:
        ; podwójna pętla, zewnętrzna po elementach tablicy
        ; wewnętrzna wypełniająca całego biginta
        mov r13, 1 ; iterator po segmentach biginta od 1, bo 0 ustawiami ręcznie
        mov eax, dword [rdi + 4 * r12]
        ; przeniesienie pod tablicę bigintów początkowej wartości
        mov r8, r15 ; pomocnicza zmienna do ustalania pozycji
        imul r8, r12
        imul r8, 4
        mov [r14 + r8], eax; r12 * 4 przemnożone przez liczbę bigintów
        ; to znaczy, dla r15=3, do id=1 zajrzymy pod [r14 + 12], bo +0,+4,+8 zajęte
        cmp eax, 0
        jge .fill_zeroes_loop ; narazie załóżmy, że zawsze są >= 0

        .fill_minus_ones_loop:
        ; pętla wstawia -1 na pozostałe segmenty biginta
            mov eax, -1
            mov r8, r12
            imul r8, r15 
            imul r8, 4 ; dla r12=1, r15=3 mamy 12 - pierwszy el drugiego
            mov r9, r13
            imul r9, 4
            add r8, r9
            ; imul r8, r13
            ; imul r8, 4
            mov [r14 + r8], eax; np [r14 + 4*(3 + {1,2})]
            ; czyli [r14 + 16], [r14 + 20] dla biginta długości 3 i el. ind=1
            inc r13
            cmp r13, r15 ; czy wypelnilismy wszystkie elementy
            jne .fill_minus_ones_loop
            jmp .after_filling


        .fill_zeroes_loop:
            ; pętla zeruje wszystkie następne segmenty biginta
            mov eax, 0
            mov r8, r12
            imul r8, r15 
            imul r8, 4 ; dla r12=1, r15=3 mamy 12 - pierwszy el drugiego
            mov r9, r13
            imul r9, 4
            add r8, r9
            ; imul r8, r13
            ; imul r8, 4
            mov [r14 + r8], eax; np [r14 + 4*(3 + {1,2})]
            ; czyli [r14 + 16], [r14 + 20] dla biginta długości 3 i el. ind=1
            inc r13
            cmp r13, r15 ; czy wypelnilismy wszystkie elementy
            jne .fill_zeroes_loop
            
        .after_filling:
            inc r12 ; następny element tablicy
            cmp r12, rsi ; czy koniec tablicy
            jne .create_bigint_loop

    ; przepisana tablica wejściowa do tablicy bigintów

    
    mov rbx, rsi ; rbx - dlugość rozpatrywanej tablicy

    .till_const_loop:
        ; pętla która wywoluje odejmowania do momentu, aż
        ; nie będzie wszędzie w tablicy zer
        ; każdy obrót pętli skraca tablicę o jeden element
        mov r12, 0 ; iterator po elementach tablicy od zera
        .sub_loop:
            ; jedno wykonanie kroku algorytmu, wewnętrzna pętla
            ; pętla, gdzie odejmuje od siebie sąsiadów
            ; najpierw odejmujemy normalnie pierwsze elementy
            ; potem robimy sbb na kolejnych intach w bigincie
            ; zewnętrzna pętla: po elementach tablicy
            ; wewnętrzna pętla: po segmentach biginta
            mov r13, 0 ; iterator po bigint od zera 
            mov r8, r12
            imul r8, r15 ; przesuniecie o rozmiar biginta do kolejnego
            imul r8, 4 ;
            mov r9, 0 ; zaczynamy od zera
            
            clc ; reset carry flag
            pushf ; save flags
            ; przy kazdej iteracji zwiekszamy r8 i r9 o 
            .sub_bigint_loop:
                mov r9, r15
                imul r9, 4 ; przesuniecie na poczatek drugiego biginta - liczba intów * dlugosc inta
                add r9, r8 ; miejsce w bigincie
                ; np jak r8=0, to r9=12
                ; jak r8 = 4, to r9=16 dla dlugosci bigint= 3 inty
                mov eax, [r14 + r9] ; dalszy elem
                popf ; get saved flags
                sbb eax, [r14 + r8] ; blizszy elem
                pushf ; save flags, carry most importantly
                mov [r14 + r8], eax

                
                lea r8, [r8 + 4] ; move r8 4 bytes forward
                lea r13, [r13 + 1] ; inc r13        
                cmp r13, r15 ; is loop finished
                
                jne .sub_bigint_loop
            
            popf
            inc r12
            cmp r12, rbx
            jne .sub_loop

        dec rbx ; zmniejsz rozmiar rozpatrywanej tablicy
        cmp rbx, 1 ; czy został już tylko jeden element
        jnz .before_check_for_const_loop ; więcej niż jeden element
        ; faktycznie został tylko jeden element, czy jest to 0?
        ; przejsc sie po big int i sprawdzic czy ma same zera
        ; można skorzystać z nie używanego poza tym rejestru rdx
        mov rdx, 0 ; przechodzimy po bigincie od poczatku
        .check_last_element_loop:
            mov eax, [r14 + 4 * rdx]
            cmp eax, 0
            jne .last_is_not_zero ; ostatni element nie jest równy 0
            inc rdx
            cmp rdx, r15 ; czy doszlismy do konca biginta
            jne .check_last_element_loop
            ; ostatni element to 0
            ;;;; !!!!! WAŻNE !!!!! ;;;;
            ; TU JEST PEWNIE BŁĄD W ZWRACANIU WARTOŚCI RAX ;
            mov rax, rsi
            sub rax, 2
            ; mov rax, 9998 debug
            jmp .finish

        ; ostatni element nie jest 0, zwracamy najwyższy stopień = n - 1
        .last_is_not_zero:
            mov rax, rsi
            dec rax
            jmp .finish

        ; odejmowanie na bigintach zakończone, sprawdźmy, czy wszędzie jest 0

        .before_check_for_const_loop:
        ; przeiterować się po każdym segmencie każdego biginta i sprawdzić,
        ; czy jest tam 0
        mov rdx, 0 ; iterator po tablicy, rdx nie jest nigdzie indziej używany
        mov r12, r15 ; liczba intow w bigincie
        imul r12, 4 ; to już rozmiar jednego biginta
        imul r12, rbx ; razy liczba bigintów w tablicy
        .check_for_const_loop:
            ; w tablicy jest jeszcze >1 bigint
            ; pętla sprawdza, czy wszystkie wartości w tablicy
            ; wynoszą 0
            ; zwracamy szczególna uwagę na sytuację, gdy w tablicy jest tylko 
            ; 1 element. jesli jest różny od 0, wynik to rsi - 1
            ; jak równy to, to wynik jak w innych przypadkach #liczba obrotów pętli
            mov eax, [r14 + rdx] ; kolejny element tablicy
            cmp eax, 0
            jne .till_const_loop ; nie ma tam zera, kolejna iteracja algorytmu
            ; tu jest zero, patrzymy dalej
            add rdx, 4
            cmp rdx, r12 ; czy doszlismy do konca
            jne .check_for_const_loop
            ; faktycznie są same zera, zwracamy wynik

            mov rax, rsi
            sub rax, rbx
            sub rax, 1
            ; mov rax, 999
            jmp .finish


        
        jnz .till_const_loop 
    ; mov rax, r14 
    mov rax, rsi - 1

    
    

    .finish:
        mov r8, r15
        imul r8, 4
        imul r8, rsi
        add rsp, r8
    .finish_early:
        pop rbp
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        
        ret
