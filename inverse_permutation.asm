global inverse_permutation

; Argumenty funkcji inverse_permutation:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę z permutacją
inverse_permutation:
        cmp     rdi, 0x0                ; porównujemy n z 0
        jle     .incorrect              ; jeśli n <= 0, to przechodzimy do etykiety .incorrect
        mov     rcx, 0x80000000         ; ustawiamy rcx na największą liczbę 32-bitową (ze znakiem -> 2^31)
        cmp     rdi, rcx                ; porównujemy n z 2^31 (największą liczbą dla której n ma sens)
        jg      .incorrect              ; jeśli n > 2^31, to przechodzimy do etykiety .incorrect
        mov     r8, 0x0                 ; ustawiamy r8 na 0 (indeks w tablicy)

.loop_range:
        movsxd  rcx, DWORD [rsi+r8*4]   ; wczytujemy wartość z tablicy
        cmp     rcx, 0x0                ; porównujemy wartość w tablicy z 0
        jl      .incorrect              ; jeśli jest < 0, to przechodzimy do etykiety .incorrect
        cmp     rcx, rdi                ; porównujemy wartość w tablicy z n
        jge     .incorrect              ; jeśli jest >= n, to przechodzimy do etykiety .incorrect
        inc     r8                      ; zwiększamy indeks
        cmp     r8, rdi                 ; porównujemy indeks (r8) z n (rdi)
        jl      .loop_range             ; jeśli jest < n, to przechodzimy do etykiety .loop_range (kontynuujemy pętlę)

        mov     r8, 0x0                 ; ustawiamy r8 na 0 (indeks w tablicy)
.loop_unique:
        movsxd  rcx, DWORD [rsi+r8*4]   ; wczytujemy wartość z tablicy
        inc     r8                      ; zwiększamy indeks
        cmp     r8, rdi                 ; porównujemy indeks (r8) z n (rdi)
        jl      .loop_unique            ; jeśli jest < n, to przechodzimy do etykiety .loop_unique (kontynuujemy pętlę)

.correct:
        mov     rax, 0x1                ; jeśli przeszliśmy przez to wszystko, to dane są poprawne, zatem rax = 1 (true)
        ret                             ; i zwracamy true

.incorrect:
        mov     rax, 0x0                ; jeśli n jest niepoprawne, to rax = 0 (false)
        ret                             ; i zwracamy false