global inverse_permutation

section .text

; Argumenty funkcji inverse_permutation:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę z permutacją
inverse_permutation:
        test    rdi, rdi                ; porównujemy n z 0
        jle     .incorrect              ; jeśli n <= 0, to przechodzimy do etykiety .incorrect
        mov     rcx, 0x80000000         ; ustawiamy rcx na największą liczbę 32-bitową (ze znakiem -> 2^31)
        cmp     rdi, rcx                ; porównujemy n z 2^31 (największą liczbą dla której n ma sens)
        jg      .incorrect              ; jeśli n > 2^31, to przechodzimy do etykiety .incorrect
        dec     rdi                     ; odejmujemy 1 od n (teraz wartość n - 1 mieści się tak naprawdę w edi)
        xor     r8, r8                  ; ustawiamy r8 na 0 (indeks w tablicy)

.loop_range:
        mov     ecx, DWORD [rsi+r8*4]   ; wczytujemy wartość z tablicy
        test    ecx, ecx                ; porównujemy wartość w tablicy z 0
        jl      .incorrect              ; jeśli jest < 0, to przechodzimy do etykiety .incorrect
        cmp     ecx, edi                ; porównujemy wartość w tablicy (ecx) z n - 1 (edi)
        jg      .incorrect              ; jeśli jest > n - 1, to przechodzimy do etykiety .incorrect
        inc     r8                      ; zwiększamy indeks
        cmp     r8d, edi                ; porównujemy indeks (r8d) z n (edi)
        jle     .loop_range             ; jeśli jest <= n - 1, to przechodzimy do .loop_range (kontynuujemy pętlę)
        xor     r8, r8                  ; ustawiamy r8 z powrotem na 0 (indeks w tablicy)

.loop_unique:
        mov     ecx, DWORD [rsi+r8*4]   ; wczytujemy wartość z tablicy
        movsxd  rcx, ecx                ; rozszerzamy wartość w ecx do 64-bitów (aby móc wykorzystywać ją do dostępu do
                                        ; tablicy)
        test    rcx, rcx                ; porównujemy wartość w tablicy z 0
        jge     .positive               ; jeśli jest >= 0, to przechodzimy do etykiety .positive
        add     rcx, rdi                ; w przeciwnym przypadku dodajemy n - 1 do wartości w tablicy
.positive:
        mov     r9d, DWORD [rsi+rcx*4]  ; wczytujemy wartość z tablicy (na indeksie, który wcześniej wczytaliśmy)
        test    r9d, r9d                ; porównujemy tą wartość z 0
        jl      .not_unique             ; jeśli jest < 0, to przechodzimy do etykiety .not_unique (wartość się
                                        ; powtórzyła, ale trzeba jeszcze przywrócić tablicę do początkowego stanu)
        sub     r9d, edi                ; w przeciwnym przypadku odejmujemy n - 1 od wczytanej wartości (przyjmujemy, że
                                        ; wartość, która już była na swoim indeksie będzie miała liczę ujemną)
        mov     DWORD [rsi+rcx*4], r9d  ; zapisujemy wartość w tablicy (na indeksie, który wcześniej wczytaliśmy)
        inc     r8                      ; zwiększamy indeks
        cmp     r8d, edi                ; porównujemy indeks (r8d) z n - 1 (edi)
        jle     .loop_unique            ; jeśli jest <= n - 1, to przechodzimy do .loop_unique (kontynuujemy pętlę)

.correct:
        mov     al, 0x1                 ; jeśli przeszliśmy przez to wszystko, to dane są poprawne, zatem al = 1 (true)
        ret                             ; i zwracamy true

.not_unique:
        xor     r8, r8                  ; ustawiamy r8 z powrotem na 0 (indeks w tablicy)
.loop_not_unique:
        mov     ecx, DWORD [rsi+r8*4]   ; wczytujemy wartość z tablicy
        test    ecx, ecx                ; porównujemy wartość w tablicy z 0
        jge     .positive_not_unique    ; jeśli jest >= 0, to przechodzimy do etykiety .positive_not_unique
        add     ecx, edi                ; w przeciwnym przypadku dodajemy n do wartości w tablicy
.positive_not_unique:
        mov     DWORD [rsi+r8*4], ecx   ; wczytujemy wartość z tablicy (na indeksie, który wcześniej wczytaliśmy)
        inc     r8                      ; zwiększamy indeks
        cmp     r8d, edi                ; porównujemy indeks (r8d) z n - 1 (edi)
        jle     .loop_not_unique        ; jeśli jest <= n, to przechodzimy do .loop_not_unique (kontynuujemy pętlę)

.incorrect:
        xor     al, al                  ; jeśli n jest niepoprawne, to al = 0 (false)
        ret                             ; i zwracamy false