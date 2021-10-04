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
je next_line
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
cmp $328, %edx # 200
je last_line


movb $0b00000000, %cl
movb %cl, (%eax)


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
next_line:
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
