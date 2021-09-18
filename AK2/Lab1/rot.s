SYSEXIT32 = 1
SYSCALL32 = 0x80
EXIT_SUCCESS = 0
SYSWRITE = 4
SYSREAD = 3
STDOUT = 1
STDIN = 0

input_len = 100

.global _start

.data
input: .space input_len
message: .ascii "Podaj zdanie: "
message_len = . - message
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

mov %eax, %edi
dec %edi
mov $0, %esi

petla:
cmpb $0x41, input(%esi) # jeśli jest mniejsze od 'A'
jb petlanext
cmpb $0x5B, input (%esi) # jesli jest mniejsze od 'Z'
jb BigLetter
cmpb $0x61, input (%esi) # jeśli jest mniejsze od 'a'
jb petlanext
cmpb $0x7B, input (%esi) # jeśli mniejsze od 'z'
jb SmallLetter
jmp petlanext
SmallLetter:
cmpb $0x6D, input(%esi)
ja over
add $0xD, input(%esi)
jmp petlanext
over:
sub $0xD, input(%esi)
jmp petlanext
BigLetter:
cmpb $0x4D, input(%esi)
ja over
 add $0xD, input(%esi)
petlanext:
inc %esi
cmp %edi,%esi
jl petla  

mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $input, %ecx
mov $input_len, %edx
int $SYSCALL32

mov $1,%eax
mov $0, %ebx
int $0x80
