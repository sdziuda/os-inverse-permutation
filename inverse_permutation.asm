global inverse_permutation

; Argumenty funkcji inverse_permutation:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę z permutacją
inverse_permutation:
        cmp     rdi, 0x0            ; testujemy czy n <= 0
        jle     .incorrect          ; jeśli tak, to przechodzimy do etykiety .incorrect
        mov     rcx, 0x7fffffff     ; ustawiamy rax na największą liczbę 32-bitową (2^31 - 1)
        add     rcx, 0x2            ; dodajemy 2, aby uzyskać 2^31 + 1 (największą liczbę dla której n ma sens)
        cmp     rdi, rcx            ; porównujemy n z 2^31 + 1
        jge     .incorrect          ; jeśli n >= 2^31 + 1, to przechodzimy do etykiety .incorrect
        mov     r8, 0x0             ; ustawiamy r8 na 0 (indeks w tablicy)
.loop:
        mov     rcx, [rsi+r8*4]     ; wczytujemy wartość z tablicy
        cmp     rcx, 0x0            ; porównujemy wartość w tablicy z 0
        jl      .incorrect          ; jeśli jest < 0, to przechodzimy do etykiety .incorrect
        cmp     rcx, rdi            ; porównujemy wartość w tablicy z n
        jge     .incorrect          ; jeśli jest >= n, to przechodzimy do etykiety .incorrect
        inc     r8                  ; zwiększamy indeks
        cmp     r8, rdi             ; porównujemy indeks (rax) z n (rdi)
        jl      .loop               ; jeśli indeks < n, to przechodzimy do etykiety .loop (kontynuujemy pętlę)
        mov     rax, 0x1            ; jeśli przeszliśmy przez to wszystko, to dane są poprawne, zatem rax = 1 (true)
        ret                         ; i zwracamy true
.incorrect:
        mov     rax, 0x0            ; jeśli n jest niepoprawne, to rax = 0 (false)
        ret                         ; i zwracamy false