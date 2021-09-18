SYSEXIT32 = 1
SYSCALL32 = 0x80
EXIT_SUCCESS = 0
SYSWRITE = 4
SYSREAD = 3
STDOUT = 1
STDIN = 0

input_len = 200

.global _start

.data
input: .space input_len
input2: .space input_len
liczba1: .space input_len
liczba2: .space input_len
liczba2_len: .space input_len * 4
liczba1_len: .space input_len * 4
wynik_len = (input_len+input_len) * 4
wynik: .space wynik_len
wynik_tekst: .space wynik_len
wynik_teks_len: .space
message: .ascii "Podaj liczbe1: "
message_len = . - message
message2: .ascii "Podaj liczbe2: "
message2_len = . - message2
errormessage: .ascii "Nieprawdilowe dane "
errormessage_len = . - errormessage
.text

_start:

mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $message, %ecx
mov $message_len, %edx
int $0x80

mov $SYSREAD, %eax
mov $STDIN, %ebx
mov $input, %ecx
mov $input_len, %edx
int $SYSCALL32



jmp rstrip
back: 


mov %eax, %edi
mov %eax, liczba1_len
mov $0, %esi
mov $0,%eax
mov $0, %ebx
petla:

mov $0, %ecx
cmpb $0x30, input(%esi) # jesli jest mniejsze od '0'
jb invaliddata
cmpb $0x3A, input(%esi) # jesli jest mniejsze od '9'
jb digit
cmpb $0x41, input(%esi) # jeśli jest mniejsze od 'A'
jb petlanext
cmpb $0x47, input (%esi) # jesli jest mniejsze od 'F'
jb BigLetter
cmpb $0x61, input (%esi) # jeśli jest mniejsze od 'a'
jb petlanext
cmpb $0x67, input (%esi) # jeśli mniejsze od 'f'
jb SmallLetter
jmp invaliddata
digit:
sub $48, input(%esi)
jmp petlanext
SmallLetter:
sub $87, input(%esi)
jmp petlanext
BigLetter:
sub $55, input(%esi)
petlanext:
cmp $8, %eax  # jesli aktualna dugosc slowa jest mniejsza od 8
jb aktualneslowo
mov $0, %eax
inc %ebx
jmp addbyte
aktualneslowo:

inc %eax 

addbyte:
shll $4, liczba1(,%ebx,4)
addb input(%esi), %cl
addl %ecx, liczba1(,%ebx,4) 
inc %esi
cmp %edi,%esi
jl petla  


# Wczytanie drugiej liczby
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $message2, %ecx
mov $message2_len, %edx
int $0x80

mov $SYSREAD, %eax
mov $STDIN, %ebx
mov $input2, %ecx
mov $input_len, %edx
int $SYSCALL32

jmp rstrip2
back2: 



mov %eax, %edx
mov %eax, liczba2_len
mov $0, %esi
mov $0,%eax
mov $0, %ebx
petla2:

mov $0, %ecx
cmpb $0x30, input2(%esi) # jesli jest mniejsze od '0'
jb petlanext2
cmpb $0x3A, input2(%esi) # jesli jest mniejsze od '9'
jb digit2
cmpb $0x41, input2(%esi) # jeśli jest mniejsze od 'A'
jb petlanext2
cmpb $0x47, input2 (%esi) # jesli jest mniejsze od 'F'
jb BigLetter2
cmpb $0x61, input2 (%esi) # jeśli jest mniejsze od 'a'
jb petlanext2
cmpb $0x67, input2 (%esi) # jeśli mniejsze od 'f'
jb SmallLetter2
jmp invaliddata
digit2:
sub $48, input2(%esi)
jmp petlanext2
SmallLetter2:
sub $87, input2(%esi)
jmp petlanext2
BigLetter2:
sub $55, input2(%esi)
petlanext2:
cmp $8, %eax  # jesli aktualna dugosc slowa jest mniejsza od 8
jb aktualneslowo2
mov $0, %eax
inc %ebx
jmp addbyte2
aktualneslowo2:
# Zaladowanie danych
inc %eax 

addbyte2:
shll $4, liczba2(,%ebx,4)
addb input2(%esi), %cl
addl %ecx, liczba2(,%ebx,4) 
inc %esi
cmp %edx,%esi
jl petla2


# Początek algorytmu mnożenia:
# Dane : 
# liczba1 - pierwsza liczba w hex
# liczba2 - druga liczba w hex:
# edi - dlugosc pierwszej liczby
# edx - dlugosc drugiej liczby
# wynik - bufor na wynik o rozmiarze wynik_len
movl $0, %edx
movl $0, %eax
# Ustawienie iteratora dużej pętli, ebx jest naszym 'x'
movl $0, %ebx
mnozenieb:
# SPrawdzenie warunku wyjscia  z duzej petli (czy ebx przekroczyl rozmiar liczby pierwszej)
cmp liczba1_len, %ebx
jz end_b
# Ustawienie iteratora małej pętli, ecx jest naszym 'y'
movl $0, %ecx
# Ustawienie pozycji przeniesienia o dwie pozycje dalej
movl $0, %esi

# Mniejsza pętla, po 'y'
mnozenies:
movl $0, %edi
# Sprawdzenie warunku wyjscia z małej pętli (czy ecs przekroczyl rozmiar drugiej liczby)

cmp liczba2_len, %ecx
jz end_s
# Przeniesienie odpowiednich cyfr z aktualnych pozycji
# (Pozycje przechowywane są w ebx i ecx)
# Do rejestrów eax i edx
movl liczba1(,%ebx,4), %eax
movl liczba2(,%ecx,4), %edx
# Mnożenie edx * eax (czyli : Ax * Bx)
# 8 Bajtowy wynik umieszczany jest w postaci podwójnego słowa
# Wyższe 4 bajty uieszczane są w edx
# Niższe 4 bajty umieszczane są w eax
mull %edx
# Wytworzenie sumy : x+y
addl %ebx, %ecx 
# Do niższch 4 bajtów mnożenia w eax dodajemy tymczasowy wynik
# ...z pozycji x+y
addl wynik(,%ecx,4), %eax
# Przekopiowanie uzyskanej z poprzedniej operacji sumy
# na pozycje x+y wyniku
movl %eax, wynik(,%ecx,4)
# Zwiększenie pozycji:
incl %ecx
# Do wyższych 4 bajtów mnożenia w edx dodajemy tymczasowy wynik
# Z pozycji (x+y+1)
# Dodawanie z przeniesiem, ponieważ w operacji addl mogło wystąpić przeniesienie
adcl wynik(,%ecx,4), %edx

# Wyzerowanie przeniesienia
# jeśli zostało ono wygenerowane w poprzedniej operacji - trafia do edi
adcl $0, %edi
# Dodanie przeniesienia z poprzedniej iteracji
# (esi) wcześniej zawierało przeniesie na pozycje+2
# ...które teraz należy dodać
addl %esi, %edx
# Aktualizacja przeniesienia na kolejną pozycje '+2'
movl %edi, %esi
# Umieszczenie właściwej wartości, na właściwą pozycję wyniku
movl %edx, wynik(,%ecx,4)
# Przywrócenie właściwej wartosci ecx
subl %ebx, %ecx
jmp mnozenies
end_s:
incl %ebx
jmp mnozenieb







end_b:

# Uzyskanie długości wyniku poprzez dodanie dlugosci liczb wejscioweych:
mov $0, %eax
mov liczba1_len, %eax
add liczba2_len, %eax

# mov %eax, %edi
inc %eax
mov %eax, wynik_teks_len
shr $1, %eax
dec %eax
mov %eax, %esi # Ustawienie licznika pętli
mov $0, %edi # Wyzerowanie licznika pozycji w łańcuchu znaków

petla3:
# Wyzerowanie rejestrów edx i ecx
# Zostanie do nich przekazana ta sama para cyfr heksadecymalnych wyniku
# Następnie za pomocą przesunięc bitowych o 4 zostają dwie cyfry pojedynczo
mov $0, %edx
mov $0, %ecx
movb wynik(%esi), %dl
movb wynik(%esi), %cl
shr $4, %dl
shl $4, %cl
shr $4, %cl
cmpb $10, %dl
jb znakA
jmp znakD
petlanext3:

dec %esi
mov $0, %ecx
dec %ecx
cmp %ecx, %esi
jb petla3


petla3koniec:

# Jeśli wynik ma nieparzystą liczbę znaków
# To po lewej stronie łańcucha znajduje się zbędny bajt '0'
# ponieważ zapis do łańcucha tekstowego odbywał się parami
mov $0, %edx
mov %eax, %esi
movb wynik(%esi), %dl
shr $4, %dl
# Sprawdzenie czy pierwszy znak w wyniku to '0':
cmpb $0, %dl
jne wypiszwynik
shrb $8, wynik_tekst
wypiszwynik:
movb $10, %dl
movb %dl, wynik_tekst(%edi)


mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $wynik_tekst, %ecx
mov wynik_teks_len, %edx
int $0x80

mov $1,%eax
mov $0, %ebx
int $0x80

rstrip:
dec %eax
.loop:
cmpb $0xa,(%ecx,%eax,1)
je chop
cmpb $0xc, (%ecx,%eax,1)
je chop
cmpb $0xd, (%ecx,%eax,1)
je chop
done:
inc %eax
jmp back
chop:
movb $0, (%ecx,%eax,1)
dec %eax
jns .loop
jmp done

rstrip2:
dec %eax
.loop2:
cmpb $0xa,(%ecx,%eax,1)
je chop2
cmpb $0xc, (%ecx,%eax,1)
je chop2
cmpb $0xd, (%ecx,%eax,1)
je chop2
done2:
inc %eax
jmp back2
chop2:
movb $0, (%ecx,%eax,1)
dec %eax
jns .loop2
jmp done2
invaliddata:
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $errormessage, %ecx
mov $errormessage_len, %edx
int $0x80


mov $1,%eax
mov $0, %ebx
int $0x80

znakA:
# Konwersja pierwszej cyfry 0-9 do znaku
add $48, %edx
mov %edx, wynik_tekst(%edi)
inc %edi
cmpb $10, %cl
jb znakB
jmp znakC
znakB:
# Konwersja drugiej cyfry 0-9 do znaku
add $48, %ecx
mov %ecx, wynik_tekst(%edi)
inc %edi
jmp petlanext3
znakC:
# konwersja drugiej cyfry a-f do znaku
add $55, %ecx
mov %ecx, wynik_tekst(%edi)
inc %edi
jmp petlanext3
znakD:
# Konwersja pierwszej cyfry a-f do znaku
add $55, %edx
mov %edx, wynik_tekst(%edi)
inc %edi
cmpb $10, %cl
jb znakB
jmp znakC
