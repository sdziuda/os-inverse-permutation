global inverse_permutation

; Argumenty funkcji inverse_permutation:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę z permutacją
inverse_permutation:
        cmp     rdi, 0x0        ; testujemy czy n <= 0
        jle      .incorrect     ; jeśli tak, to przechodzimy do etykiety .incorrect
        mov     rax, 0x7fffffff ; ustawiamy rax na największą liczbę 32-bitową (2^31 - 1)
        add     rax, 0x2        ; dodajemy 2, aby uzyskać 2^31 + 1 (największą liczbę dla której n ma sens)
        cmp     rdi, rax        ; porównujemy n z 2^31 + 1
        jge     .incorrect      ; jeśli n >= 2^31 + 1, to przechodzimy do etykiety .incorrect
        mov     rax, 0x1        ; jeśli nie, to n jest poprawne, zatem ustawiamy rax = 1 (true)
        ret                     ; i zwracamy true
.incorrect:
        mov     rax, 0x0        ; jeśli n jest niepoprawne, to rax = 0 (false)
        ret                     ; i zwracamy false