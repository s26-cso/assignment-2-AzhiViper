.data
fname:  .string "input.txt"
rmode:  .string "r"
yes:    .string "Yes\n"
no:     .string "No\n"

# well need two fil ptrs , one to go from left , onre for right
# also store file size smwere in mem

fsize:  .space 8      # storing file size here , 8 bytes 

.text
.global main

main:
    #cuz saving ra , like obvi lowk

    addi sp, sp, -8
    sd ra, 0(sp)

    # open file -> left ptr , a0 needs name , and a1 needs mode like in c as args
    la a0, fname
    la a1, rmode
    call fopen
    mv s0, a0

    #a0 is return ie the pointer so store it in s0
    #make sure its not null
    
    beqz s0, print_no
    # if fopen failed   ie we got null so we say no


    # open same file again for right pointer
    la a0, fname
    la a1, rmode
    call fopen
    mv s1, a0
    # s1 = right file  ptr

    beqz s1, print_no

    # we need size of file
    # fseek(s1, 0, SEEK_END) , SEEK_END = 2

    mv a0, s1
    li a1, 0
    li a2, 2
    call fseek

    # now were at the end of file

    # ftell gives us current position ie file size
    mv a0, s1
    call ftell
    mv s2, a0
    #so now s2 has file size

    # left->0, right->n-1
    li s3, 0         # s3 = left index
    addi s4, s2, -1  # s4 = right index
    # s4 = n-1 cuz of 0 indexing


    # we also had mem for file size so we store it there

    la t0, fsize
    sd s2, 0(t0)

compare_loop:


    # if left >= right were done ie pallindrtome

    bge s3, s4, print_yes
    # when they meet or cross ie no conflict yet , ie both halfes identical blah blah blah

    # seek left handle to position s3

    mv a0, s0
    mv a1, s3
    li a2, 0         # SEEK_SET = 0 , ie from beginning
    call fseek

    # read singular character

 

    mv a0, s0
    call fgetc
    mv s5, a0

    # s5 = left char

    # now seek right handle to position s4

    mv a0, s1
    mv a1, s4
    li a2, 0
    call fseek

    #at ryt index

    # read one chartr

    mv a0, s1
    call fgetc
    # a0 = right character

    # if the left and right chars aremnmt equal , were done , we immediately print no , else we compare_loop
    
    bne s5, a0, print_no

    #eqaul , so just move left ptr by 1 and right by -1
    addi s3, s3, 1   # left++
    addi s4, s4, -1  # right--
    

    j compare_loop
    

print_yes:
    # cfclose for both

    mv a0, s0
    call fclose

    mv a0, s1
    call fclose

    la a0, yes
    call printf

    ld ra, 0(sp)
    addi sp, sp, 8
    li a0, 0
    ret

print_no:
    
    # fclose here asw , but spl case null ptrs , cand do that

    beqz s0, skip_closeleft
    mv a0, s0
    call fclose
skip_closeleft:
    beqz s1, skip_closeright
    mv a0, s1
    call fclose
skip_closeright:

    la a0, no
    call printf
    # print No 

    ld ra, 0(sp)
    addi sp, sp, 8
    li a0, 0
    ret
