.data
by: .byte 0x01
by2 :.byte 0x01
input: .space 200
.text

.global read

read:
push %ebp
mov %esp, %ebp

movl $0, %eax
movl $0, %edx # rozmiar 


movl 8(%ebp), %eax
movl 12(%ebp), %edx # Ilość bajtów do wypisania

mov $0, %esi
petla:
mov $0, %ecx

# Pobranie pierwszego bajtu piksela
movb (%eax), %cl
inc %eax

movb $0b00001111, by
andb %cl, by

mov $0, %ecx
# Pobranie kolejnego bajtu piksela
movb (%eax), %cl
inc %eax
movb $0b00001111, by2
andb %cl, by2
shlb $4, by2

mov $0, %ecx
movb by, %cl
xorb by2, %cl 

movb %cl, input(%esi)

petlanext:

inc %esi
cmp %edx, %esi
jl petla

# Wypisanie wiadomosci:
mov $4, %eax
mov $1, %ebx
mov $input, %ecx
mov %esi, %edx
int $0x80 


pop %ebp

mov $1, %eax
mov $0, %ebx
int $0x80

ret
