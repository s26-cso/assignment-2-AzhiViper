.data

integer: .string "%d"
space:   .string " "
nline:   .string "\n"
arr: .space 400
vals: .space 400
stk: .space 400

# since it is command line arg , argv in a0 , argc in a1
#n. of inetgers =argc -1 , cuz ignore name of cmd
.text
.global main 
main:

    addi sp, sp, -8
    sd ra, 0(sp) 
    #ssaving ra so return address is not lost

    #also store no. of intss in s0

    addi s0, a0, -1

    addi t0, a0, -1
    la t1, arr
    #load address of empty array
    addi a1, a1, 8
    #skip program name

    input_loop:
        beq zero, t0, input_parsed #all numbers parsed

        #t0, t1 , a1 need to be saved to sp , since atoi will change them

        addi sp, sp, -24
        sd a1, 0(sp)
        sd t0, 8(sp)
        sd t1, 16(sp)

        ld a0, 0(a1)

        call atoi

        #a0 , now contains the integer

        #restore regs
        ld a1, 0(sp)
        ld t0, 8(sp)
        ld t1, 16(sp)        
        addi sp, sp, 24

        #must now cange a1 to a1+8

        #store integer at 0(t1)

        sw a0, 0(t1)

        #t1 ->t1+8
        addi t1, t1, 4 #cuz were storing 4 byte int

        #decrement t0 , since one int parsed

        addi t0, t0,-1

        #a1->a1+8

        addi a1, a1, 8

        j input_loop

    input_parsed:

        # copy arr into vals so we always have the og values
        # arr will get overwritten with answers but vals will not chnage 
        la t0, arr
        la t1, vals
        mv t2, s0
    copy_loop:
        beqz t2, copy_done
        lw t3, 0(t0)
        sw t3, 0(t1)
        addi t0, t0, 4
        addi t1, t1, 4
        addi t2, t2, -1
        j copy_loop
    copy_done:
    
    #now input is done we need to use the stack now

    load_addresses:
        #s0 has no. of elements
        la s1, arr
        addi t0, s0, 0 
        #t0 checks no. of elements left to be preocessed

        la s2, stk
        li s3, 0
        #s3 tracks no. of elements in stack

        #s5 = base of vals, we donot touch ts one
        la s5, vals

        #arr needs to be set to last index of arr

        li t2, 4
        mul t1, s0, t2
        
        add s1, t1, s1
        addi s1, s1, -4
        #cuz we need arr+ (n-1)*4

        #s1 now has base address of last  element

        # push indeddx (n-1) 
        addi t1, s0, -1
        sw t1, 0(s2)

        addi s3, s3, 1

        #overwrite arr[n-1] with -1 since it has no next greater
        li t1, -1
        sw t1, 0(s1)

        addi s1, s1, -4

        addi t0, t0, -1

    processing:
        #now for n-1 eleements 
        #if t0=0 , exit to print

        beq t0, zero, done

        la s4, arr

        # load og value of arr[i] from vals, not arr (arr is being overwritten)
        sub t3, s1, s4
        srai t3, t3, 2
        slli t3, t3, 2
        add t3, t3, s5
        lw t1, 0(t3)

        pop_loop:
        #stk empty->stop
            beq s3, zero, store_negative_1

            #check stk->top
            #s3tracks no. of element is stk , s2 keeps its base addresss always

            addi t2, s3, -1
            slli t2, t2, 2
            add t2, t2, s2
            lw t2, 0(t2)         

            #loading arr[stack(top)] , so we compare with arr[i]
            #keep popping till stk emty or arr[i]>>
            
            # @ load from vals not arr, cuz arr[stk[top]] might already be overwritten
            slli t3, t2, 2
            add t3, t3, s5
            lw t3, 0(t3)          
            
            #t3 = value at that index

            bgt t3, t1, replace   
            #stk[top] value > arr[i], answer is t2 (the index)

            #pop since stk[top] <= arr[i]
            addi s3, s3, -1
            j pop_loop

            store_negative_1:
            #by deafut we have to put -1 to arr[i] , if thers no next grater
                li t2, -1
            
            replace:
                #store answer (index or -1) into arr[i]
                sw t2, 0(s1)

                # get index
                sub t2, s1, s4
                srai t2, t2, 2    # t2 = i current indesx

                #now push i onto the stk

                slli t3, s3, 2
                add t3, t3, s2
                sw t2, 0(t3)
                addi s3, s3, 1

                addi s1, s1, -4

                addi t0, t0, -1   #move left

                j processing

    done:
        la s1, arr          # reset s1 to start of arr
        mv t0, s0           # t0 = n, will count down

    print_loop:
        beqz t0, print_done # printed all elements, done

        # save regs since printf will clobber them
        addi sp, sp, -32
        sd s0, 0(sp)
        sd s1, 8(sp)
        sd s3, 16(sp)
        sd t0, 24(sp)

        lw a1, 0(s1)        # a1 = arr[i], the answer for this position
        la a0, integer      # format string "%d"
        call printf

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s3, 16(sp)
        ld t0, 24(sp)
        addi sp, sp, 32

        addi t0, t0, -1     # one less to print
        addi s1, s1, 4      # move to next element

        beqz t0, print_done # if that was the last one, skip the space

        # print space between elements
        addi sp, sp, -32
        sd s0, 0(sp)
        sd s1, 8(sp)
        sd s3, 16(sp)
        sd t0, 24(sp)

        la a0, space
        call printf

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s3, 16(sp)
        ld t0, 24(sp)
        addi sp, sp, 32

        j print_loop

    print_done:
        la a0, nline        # newline at the end
        call printf

        ld ra, 0(sp)        # restore ra before returning
        addi sp, sp, 8
        li a0, 0
        ret
