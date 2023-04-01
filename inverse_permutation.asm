global inverse_permutation

section .text

; Argumenty funkcji inverse_permutation:
;   rdi - wartość n
;   rsi - wskaźnik na tablicę z permutacją
inverse_permutation:
        test    rdi, rdi                    ; porównujemy n z 0
        jle     .incorrect                  ; jeśli n <= 0, to przechodzimy do etykiety .incorrect
        mov     rcx, 0x80000000             ; ustawiamy rcx na największą liczbę 32-bitową (ze znakiem -> 2^31)
        cmp     rdi, rcx                    ; porównujemy n z 2^31 (największą liczbą dla której n ma sens)
        jg      .incorrect                  ; jeśli n > 2^31, to przechodzimy do etykiety .incorrect
        dec     rdi                         ; odejmujemy 1 od n (teraz wartość n - 1 mieści się tak naprawdę w edi)
        mov     ecx, edi                    ; ustawiamy ecx na n - 1 (indeks w tablicy)
        inc     rcx                         ; dodajemy 1 aby móc użyć loop

; sprawdziliśmy już czy n jest z odpowiedniego przedziału, teraz musimy sprawdzić czy wszystkie liczby w tablicy
; są z przedziału 0...n-1
.loop_range:
        mov     eax, DWORD [rsi+rcx*4-4]    ; wczytujemy wartość z tablicy (-4 ponieważ wcześniej zwiększyliśmy rcx)
        test    eax, eax                    ; porównujemy wartość w tablicy z 0
        jl      .incorrect                  ; jeśli jest < 0, to przechodzimy do etykiety .incorrect
        cmp     eax, edi                    ; porównujemy wartość w tablicy z n - 1
        jg      .incorrect                  ; jeśli jest > n - 1, to przechodzimy do etykiety .incorrect
        loop    .loop_range                 ; kontynuujemy pętlę dopóki nie przeczytamy wszystkich wartości z tablicy

        mov     ecx, edi                    ; analogicznie jak wcześniej, ustawiamy ecx na n - 1 (indeks w tablicy)
        inc     rcx                         ; dodajemy 1 aby móc użyć loop

; w tym momencie wiemy, że wszystkie liczby w tablicy są z zakresu 0...n-1, będziemy teraz chcieli sprawdzić,
; czy się nie powtarzają - aby to zrobić, gdy napotkamy w tablicy liczbę x, to od p[x] odejmujemy n, jeżeli okaże się,
; że p[x] jest już ujemne, to znaczy, że liczba x się powtarza
.loop_unique:
        movsxd  rax, DWORD [rsi+rcx*4-4]    ; wczytujemy wartość z tablicy, ale wcześniej musimy ją rozszerzyć do
                                            ; 64-bitów (aby móc wykorzystywać ją do dostępu do tablicy, ale może być
                                            ; ujemna - dlatego używamy movsxd, a nie mov)
        test    rax, rax                    ; porównujemy wartość w tablicy z 0
        jge     .positive                   ; jeśli jest >= 0, to przechodzimy do etykiety .positive
        add     rax, rdi                    ; w przeciwnym przypadku dodajemy n - 1 do wczytanej wartości
        inc     rax                         ; dodajemy 1 do otrzymanej wartości aby była z zakresu 0...n-1
.positive:
        mov     edx, DWORD [rsi+rax*4]      ; wczytujemy wartość z tablicy (na indeksie, który wcześniej wczytaliśmy)
        test    edx, edx                    ; porównujemy tą wartość z 0
        jl      .not_unique                 ; jeśli jest < 0, to przechodzimy do etykiety .not_unique (wartość się
                                            ; powtórzyła, ale trzeba jeszcze przywrócić tablicę do początkowego stanu)
        sub     edx, edi                    ; w przeciwnym przypadku odejmujemy n - 1 od wczytanej wartości
        dec     edx                         ; odejmujemy jeszcze 1 (w sumie odejmujemy n) od otrzymanej wartości aby
                                            ; była z zakresu -n...-1
        mov     DWORD [rsi+rax*4], edx      ; zapisujemy wartość w tablicy (na indeksie, który wcześniej wczytaliśmy)
        loop    .loop_unique                ; kontynuujemy pętlę dopóki nie przeczytamy wszystkich wartości z tablicy

        xor     ecx, ecx                    ; ustawiamy rcx na 0 (indeks w tablicy), operacja na ecx zeruje całe rcx

; w tym momencie wiemy, że tablica jest poprawna oraz aktualnie wszystkie wartości w niej są z zakresu -n...-1, jeżeli
; napotkamy liczbę ujemną w tablicy, to znaczy, że jest to indeks początku cyklu, którego jeszcze nie odwróciliśmy,
; jeżeli natomiast napotkamy liczbę nieujemną to znaczy, że została już odwrócona i możemy przejść dalej
.loop_inverse:
        movsxd  rax, DWORD [rsi+rcx*4]      ; wczytujemy wartość z tablicy (będzie to potencjalny kolejny indeks w
                                            ; cyklu), ale wcześniej musimy ją rozszerzyć do 64-bitów aby móc
                                            ; wykorzystywać ją do dostępu do tablicy
        test    rax, rax                    ; porównujemy wartość w tablicy z 0
        jge     .positive_inverse           ; jeśli jest >= 0, to przechodzimy do etykiety .positive_inverse (liczba
                                            ; została już odwrócona, możemy przejść dalej)
        mov     rdx, rcx                    ; wpp. kopiujemy indeks początku (nieodwróconego jeszcze) cyklu (rcx) do rdx
.loop_inverse_cycle:
        add     rax, rdi                    ; dodajemy n - 1 do kolejnego indeksu w cyklu
        inc     rax                         ; dodajemy 1 do otrzymanej wartości aby była z zakresu 0...n-1
        mov     r8d, DWORD [rsi+rax*4]      ; wczytujemy wartość z tablicy (na indeksie, który wcześniej wczytaliśmy)
        test    r8d, r8d                    ; porównujemy tą wartość z 0
        jge     .positive_inverse           ; jeśli jest >= 0, to przechodzimy do etykiety .positive_inverse
                                            ; (skończyliśmy przesuwać aktualny cykl)
        mov     DWORD [rsi+rax*4], edx      ; zapisujemy w tablicy aktualny indeks
        mov     rdx, rax                    ; zapisujemy kolejny indeks do rdx
        movsxd  rax, r8d                    ; zapisujemy odczytaną wcześniej wartość (r8d - jest ujemny, dlatego movsxd)
                                            ; do rax (stanie się ona kolejnym indeksem w cyklu)
        jmp     .loop_inverse_cycle         ; przechodzimy do .loop_inverse_cycle (dalej jesteśmy w tym samym cyklu)
.positive_inverse:
        inc     rcx                         ; zwiększamy indeks w głównej pętli
        cmp     rcx, rdi                    ; porównujemy indeks z n - 1
        jle     .loop_inverse               ; jeśli jest <= n - 1, to przechodzimy do .loop_inverse (kontynuujemy pętlę)

.correct:
        mov     al, 0x1                     ; jeśli doszliśmy tutaj, to dane są poprawne, zatem al = 1 (true)
        ret                                 ; i zwracamy true

; któraś wartość się powtórzyła, ale część wartości z tablicy jest ujemna (a dokładnie należy do przedziału -n...-1),
; więc trzeba je jeszcze przesunąć do przedziału 0...n-1
.not_unique:
        mov     ecx, edi
        inc     ecx
.loop_not_unique:
        mov     eax, DWORD [rsi+rcx*4-4]    ; wczytujemy wartość z tablicy
        test    eax, eax                    ; porównujemy wartość w tablicy z 0
        jge     .positive_not_unique        ; jeśli jest >= 0, to przechodzimy do etykiety .positive_not_unique
        add     eax, edi                    ; w przeciwnym przypadku dodajemy n - 1 do wartości w tablicy
        inc     eax                         ; dodajemy 1 do otrzymanej wartości aby była z zakresu 0...n-1
.positive_not_unique:
        mov     DWORD [rsi+rcx*4-4], eax    ; zapisujemy wartość w tablicy
        loop    .loop_not_unique            ; kontynuujemy pętlę

.incorrect:
        xor     al, al                      ; jeśli doszliśmy tutaj, to dane są niepoprawne, zatem al = 0 (false)
        ret                                 ; i zwracamy false