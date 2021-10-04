.data

.text
.lcomm width, 4
.lcomm width2, 4
.lcomm width3, 4
.lcomm height, 4
.lcomm height2, 4
.lcomm height3, 4
.lcomm mask, 4
.lcomm mask2, 4
.lcomm mask3, 4 
.lcomm size, 4
# .lcomm s, 4
.lcomm x, 4
.lcomm y, 4
.lcomm ebx_backap, 4
.lcomm pixel_pointer, 4
.global filter

filter:
push %ebp
mov %esp, %ebp
movl %ebx, ebx_backap
movl $0, %eax
movl $0, %edx

movl 8(%ebp), %eax
movl 12(%ebp), %edx 
movl %edx, width
movl %edx, x
dec %edx
mov %edx, width2
dec %edx
mov %edx, width3
movl $0, %edx
movl 16(%ebp), %edx

movl %edx, height
movl %edx, y


movl 20(%ebp), %edx
movl %edx, size
mov $0, %esi



mov $0, %esi
loop:

cmp $0,x
je x_r
cmp $1, x
je x_r_dec
cmp $2, x
je x_r_dec



mov width, %edx
cmp %edx,x
je x_r_dec
mov width2, %edx
cmp %edx,x
je x_r_dec

mov width3, %edx
cmp %edx,x
je x_r_dec

mov y, %edx
cmp height, %edx
je x_r_dec

mov y, %edx
# cmp $328, %edx
cmp $200, %edx
je last_line

# Algorytm
movl $0, %edx
movl $0, %ebx
# obliczenie położenia lewej pierwszej kolumny maski
# mask = eax - width -4
mov %eax, %edx
sub width , %edx
sub $4, %edx
mov %edx, mask
movl $0, %edx
# mask2 = eax - 3
mov %eax, %edx
sub $3, %edx
mov %edx, mask2
movl $0, %edx
# mask3 = eax + width -2
mov %eax, %edx
add width, %edx
sub $2, %edx
mov %edx, mask3

; # zapisanie wskaznika do "backapu"
movl %eax, pixel_pointer
# 1
movl $0, %edx
movl $0, %eax
movb (mask), %dl
mov $1, %eax 
mul %edx
mov %eax , %ebx
# 2 
movl $0, %edx
movl $0, %eax
movb (mask+3), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

# 3 
movl $0, %edx
movl $0, %eax
movb (mask+6), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

# 4
movl $0, %edx
movl $0, %eax
movb (mask2), %dl
mov $1, %eax 
mul %edx
add %edx , %ebx

# 5
movl $0, %edx
movl $0, %eax
movb (mask2+3), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

# 6
movl $0, %edx
movl $0, %eax
movb (mask2+6), %dl
mov $1, %eax 
mul %dl
add %eax , %ebx

# 7
movl $0, %edx
movl $0, %eax
movb (mask3), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

# 8
movl $0, %edx
movl $0, %eax
movb (mask3+3), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

; # 9
movl $0, %edx
movl $0, %eax
movb (mask3+6), %dl
mov $1, %eax 
mul %edx
add %eax , %ebx

movl $0, %edx
movl $0, %eax
movb (mask), %al
add %eax, %edx
movl $0, %eax 
movb (mask+3), %al
add %eax, %edx
movl $0, %eax
addb (mask+6), %al
add %eax, %edx
movl $0, %eax
addb (mask2), %al
add %eax, %edx
movl $0, %eax
addb (mask2+3), %al
add %eax, %edx
movl $0, %eax
addb (mask2+6), %al

addb (mask3), %al
add %eax, %edx
movl $0, %eax
addb (mask3+3), %al
add %eax, %edx
movl $0, %eax
addb (mask3+6), %al 
add %eax, %edx
movl $0, %eax
mov %ebx, %eax
mov %edx, %ebx
movl $0, %edx
divl %ebx
addl %edx,%eax
movl pixel_pointer, %ebx
movb %al, (%ebx) 

movl $0, %ebx


# Przywrócenie wskaznika pozycji pixela do eax
movl pixel_pointer, %eax




# #####
mov x, %edx
dec %edx
mov %edx, x

inc %eax
jmp loop_next

last_line:
movb $0b11111111, %cl
movb %cl, (%eax)
inc %eax
mov x, %edx
dec %edx
mov %edx, x
jmp loop_next
x_r:
movb $0b11111111, %cl
movb %cl, (%eax)
inc %eax
mov width, %edx
mov %edx, x

mov y, %edx
dec %edx
mov %edx, y
jmp loop_next
x_r_dec:
movb $0b11111111, %cl
movb %cl, (%eax)
inc %eax
mov x, %edx
dec %edx
mov %edx, x


loop_next:
inc %esi
cmp size, %esi
jl loop

mov ebx_backap, %ebx
pop %ebp
ret
