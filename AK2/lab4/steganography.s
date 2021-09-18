.data
r: .long
it: .space 4
b: .byte 0x01
b2 :.byte 0x01
message: .ascii "Secret Message"
message_len = . - message
.text
.lcomm l, 4
.global steganography

steganography:
push %ebp
mov %esp, %ebp

movl $0, %eax
movl $0, %edx # rozmiar 


movl 8(%ebp), %eax
movl 12(%ebp), %edx # Ilośc pikseli

mov $0, %esi

petla:


# młodsze 4 bity bajtu z wiadomości
mov $0, %ecx
movb $0b00001111, b
movb message(%esi), %cl # w cl : kolejny bajt wiadomosci
andb %cl, b # w b : 0000+4bity z message


mov $0, %ecx # wyzerowanie ecx
# movb $0b11110000, %cl
# andb (%eax), %cl # w cl : 4bity z pix +0000

movb (%eax), %cl
and $0b11110000, %cl

xorb %cl, b
movl $0, %ecx
movb b, %cl

movb %cl, (%eax)


inc %eax
# starsze 4 bity bajtu wiadomosci
mov $0, %ecx
movb $0b11110000, b
movb message(%esi), %cl # w cl :  bajt wiadomosci
andb %cl, b # w b : 4 starszebity z bjtu + 0000
shrb $4, b # w b: 0000+4starszebity

mov $0, %ecx # wyzerowanie ecx
movb (%eax), %cl
and $0b11110000, %cl 
xorb %cl, b
movl $0, %ecx
movb b, %cl

movb %cl, (%eax)


inc %eax

petlanext:
inc %esi
cmp $message_len, %esi
jl petla

 





pop %ebp
ret
