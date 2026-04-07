.global make_node
.global insert
.global get
.global getAtMost
.section .text

make_node:
    #first we have a0 containing the value which is an int
    #copy that value to s0
    #make sure the value of s0 is first pushed to stack
    addi sp, sp, -16
    sd s0, 8(sp)
    sd ra, 0(sp)

    #now tthat we are free to use s0, we shall store the val at s0

    mv s0, a0
    #the contents of a0 ie val are in s0 now , this is beacuse a0 will be overwritten by malloc
    li a0, 24
    #allocating 24 bytes in memmory requires size of allocation in a0
    call malloc

    #return of malloc is in a0 , which is the base address of the allocation

    #put s0's contents ie val at 0(a0) , as a word( cuz its an int)

    sw s0, 0(a0)

    #also storre null ie zero at 8 and 16

    sd zero, 8(a0) #LEFT
    sd zero, 16(a0)#RIGHT   

    #struct is allocated now , put contents from stck back onto s0 , also return address is at a0 , ie the base address 

    ld s0, 8(sp)
    ld ra, 0(sp)
    addi sp, sp, 16

    ret

insert:


    #a0 has oot address , a1 has value
    #base case , a0=0 ie null addreess ie leaf or no tree

    
    #s0 will hold value
    #s1 will hold base addreess (root)
    #s2 will hold value of root 
    #s3 will hold rleft or right address if needed(left or right insertion)
    addi sp, sp, -48
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)
    sd ra, 32(sp)

    mv s0, a1
    mv s1, a0
    
    beq s1, zero, insert_basecase

    lw s2, 0(s1)

    #s2 contains val(root)

    bgt s2, s0, insert_left 
    #s2>s0 ie root>val meaning val is small insetri in left
    
    blt s2, s0, insert_right 
    #s2<s0 ie root<val meaning val is large insert in right

    beq s2, s0, insert_equal
    

    insert_basecase:
        #s0 has value
        
        mv a0, s0
        # ao has val , call make_nodde
        call make_node
        #a0 now contains the address of the node
        #3return 
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld s3, 24(sp)
        ld ra, 32(sp)
        addi sp, sp, 48
        ret
    
    insert_left:
        #put left address into s3, call makenode on s3 , and return of makenode must be linked to the left
        #saved reg is being used cux well have to keep the adddress safe cuz well have to link later

        ld s3, 8(s1)
        #s3 has address of left node
        #call insert on it
        mv a0, s3   #put root->left into a0
        mv a1, s0   #put val into a1
        call insert
        #a0 has address of thst root
        #not we need to fill in the valus from this address into the address at s3 
        #cuz like root->left=insert(root->left,val)


        #s1 has base address , left of s1 muct be changfed to a0
        sd a0, 8(s1)

        #now return root

        mv a0, s1


        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld s3, 24(sp)
        ld ra, 32(sp)
        addi sp, sp, 48

        ret

    insert_right:
        #put right address into s3, call makenode on s3 , and return of makenode must be linked to the riht
        #saved reg is being used cux well have to keep the adddress safe cuz well have to link later

        ld s3, 16(s1)
        #s3 has address of rigth node
        #call insert on it
        mv a0, s3   #put root->right into a0
        mv a1, s0   #put val into a1
        call insert
        #a0 has address of thst root
        #not we need to fill in the valus from this address into the address at s3 
        #cuz like root->right=insert(root->right,val)


        sd a0, 16(s1)

        #now return root

        mv a0, s1

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld s3, 24(sp)
        ld ra, 32(sp)        
        addi sp, sp, 48
        ret

    insert_equal:

        mv  a0, s1
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld s3, 24(sp)
        ld ra, 32(sp)
        addi sp, sp, 48
        ret

get:
    #a0 has root
    #a1 has value
    #basecase: hit null , secong bc find vsalue
    #last two cases left and right

    #s0 will have root 
    #s1 will have value
    #s2 will have left or right child address

    addi sp, sp, -32
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd ra, 24(sp)

    mv s0, a0
    mv s1, a1

    beq s0, zero, not_found #root==null

    lw t0, 0(s0)
    #t0 has val(root)

    beq t0, s1, found

    blt t0, s1, find_in_right
    #t0<s1 ie value t root is less , ie value to be found is more , look to right

    bgt t0, s1, find_in_left
    #t0>s1 ie value is greater ie find towadr left subtree


    not_found:
        li a0, 0
        #return null
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld ra, 24(sp)
        addi sp, sp, 32

        ret
    
    found:
        mv a0, s0
        #return root
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld ra, 24(sp)
        addi sp, sp, 32

        ret


    find_in_right:
        #put right in s2
        ld s2, 16(s0)
        #s2  has address of right

        #call in right

        mv a0, s2
        mv a1, s1
        call get
        #a0 contains return
        
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld ra, 24(sp)
        addi sp, sp, 32

        ret
    
    find_in_left:
        #put left in s2
        ld s2, 8(s0)
        #s2  has address of left

        #call in right

        mv a0, s2
        mv a1, s1
        call get
        #a0 contains return

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld s2, 16(sp)
        ld ra, 24(sp)
        addi sp, sp, 32

        ret

getAtMost:
    #int getAtMost(int val, struct Node* root); // Return the greatest value
    #present in the tree which is = val. Return -1 if no such node exists.

    #if find null , return -1
    #if root==val , return root
    #if root>val , curr node s too large  , return get atmost(left)
    #if root<val , candidate , yes , look right asw , if rightt != -1 , return right , else return root


    #a0 has val , a1 has root

    #well use s0, s1 for theem , 
    #s0 for root
    #s1 for val

    addi sp, sp, -32
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd ra, 16(sp)


    mv s0, a1
    mv s1, a0#now s0 has root

    li t0, 0
    beq s0, t0, return_minus_1

    lw t0, 0(s0)

    #to has root->val

    beq t0, s1, return_root

    bgt t0, s1, return_left
    #t0>s1 ie root->val>value , ie value is smaller ,look to left , return left  
    #last case , this is a potential candidate 
    

    ld t0, 16(s0)
    #t0 has address of right subtree t0=root->right

    #a0 must contain val , a1 must contain root->right

    mv a0, s1
    mv a1, t0
    call getAtMost

    #a0 conatins return , pu it in t0 for comparison

    mv t0, a0
    li t1, -1
    #if t0==t1, return lest best candidfate ie root

    beq t0, t1, return_root;

    #ie rifght has the answer ie ao has return 
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld ra, 16(sp)
        addi sp, sp, +32

        ret 

    return_minus_1:
        li a0, -1

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld ra, 16(sp)
        addi sp, sp, +32

        ret
    return_root:
        lw a0, 0(s0)
        
        ld s0, 0(sp)
        ld s1, 8(sp)
        ld ra, 16(sp)
        addi sp, sp, +32

        ret
    return_left:
        ld t0, 8(s0)
        #t0 has root->left

        mv a1, t0
        mv a0, s1

        call getAtMost

        ld s0, 0(sp)
        ld s1, 8(sp)
        ld ra, 16(sp)
        addi sp, sp, +32

        ret
