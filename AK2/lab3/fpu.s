SYSEXIT = 1
EX_TSUCCESS=0
.att_syntax noprefix
input_len = 50
.data
old: .word 0
nearest: .word 0x0000
down: .word 0x0400
up: .word 0x0800
zero: .word 0x0c00
input: .space input_len
round_len: .space input_len
format: .asciz "%lu\n"
formatstr: .ascii "float: %f \n\0"
scanformat: .asciz "%f"
roundingmessage: .ascii "Podaj tryb zaokraglania (n-nearest,d-down,u-up,z-zero)\n"
roundingmessage_len = . - roundingmessage
inputmessage: .ascii "Podaj dwie liczby zmiennoprzecinkowe (Uzyj . jako operatora przecinka)\n"
inputmessage_len = . - inputmessage
inputmessage2: .ascii " Następniej podaj operator działania (+,-,*,/,:)\n"
inputmessage2_len = . - inputmessage2
message: .ascii "Podano bledny operator\n"
message_len= . - message
.section bss

.lcomm x, 8
.lcomm y, 8
.lcomm control_word, 8
.text
.global main
main:
mov $4, %eax
mov $1, %ebx
mov $inputmessage, %ecx
mov $inputmessage_len, %edx
int $0x80

mov $4, %eax
mov $1, %ebx
mov $inputmessage2, %ecx
mov $inputmessage2_len, %edx
int $0x80

pushl $x
pushl $scanformat
call scanf

pushl $y
pushl $scanformat
call scanf

mov $3, %eax
mov $0, %ebx
mov $input, %ecx
mov $input_len, %edx
int $0x80

mov $4, %eax
mov $1, %ebx
mov $roundingmessage, %ecx
mov $roundingmessage_len, %edx
int $0x80

mov $3, %eax
mov $0, %ebx
mov $control_word, %ecx
mov $input_len, %edx
int $0x80

fstcw old
movw old, %ax
andb $0b11110011, %ah
orw %ax, nearest
orw %ax, down
orw %ax, up
orw %ax, zero

mov $0, %esi
cmpb $0x6e,control_word(%esi)
je roundnearest
cmpb $0x64, control_word(%esi)
je rounddown
cmpb $0x75, control_word(%esi)
je roundup
cmpb $0x7a, control_word(%esi)
je roundzero
jmp error


roundnearest:
fldcw nearest
jmp back
rounddown:
fldcw down
jmp back
roundup:
fldcw up
jmp back
roundzero:
fldcw zero

back:
mov $0, %esi
cmpb $0x2b,input(%esi)
je add
cmpb $0x2d,input(%esi)
je sub
cmpb $0x2a,input(%esi)
je mul
cmpb $0x3a,input(%esi)
je div
cmpb $0x2f,input(%esi)
je div

error:
mov $4, %eax
mov $1, %ebx
mov $message, %ecx
mov $message_len, %edx
int $0x80

mov $SYSEXIT, %eax
mov $EX_TSUCCESS, %ebx
int $0x80

sub:
fld y # Załadowanie na stos y
fld x # Załadowanie na stos x
# fmulp st, st(1)
fsubp st,st(1)
jmp koniec
add:
fld y # Załadowanie na stos y
fld x # Załadowanie na stos x
# fmulp st, st(1)
faddp st,st(1)
jmp koniec
mul:
fld y # Załadowanie na stos y
fld x # Załadowanie na stos x
fmulp st, st(1)
jmp koniec

div:
fld y # Załadowanie na stos y
fld x # Załadowanie na stos x
fdivp st, st(1)

koniec:
push %eax
push %eax

fstpl (%esp)
pushl $formatstr

call printf
mov $SYSEXIT, %eax
mov $EX_TSUCCESS, %ebx
int $0x80
