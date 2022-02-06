.data
	printResult:.asciiz "The result is:  "
	input_file: .asciiz "D:/Documents/C++Code/asic_testcase.dat"
	in_buff: .word 512
.text
	# open input file
	#la $a0,input_file
	#li $a1,0
	#li $a2,0
	#li $v0,13
	#syscall
	
	# read input file
	#move $a0,$v0
	#la $a1,in_buff	# the data in input file is save in in_buff
	#li $a2,2048
	#li $v0,14
	#syscall
	
	# close input file
	#li $v0,16
	#syscall
	
	#la $s0,in_buff		#
	#ori $s1,$0,0x1000
	#sll $s1,$s1,16
	
	addi $s0,$zero,256
	addi $s1,$zero,424
	lw $t0,0($s0)		# $t0 is knapsack capacity	
	lw $t1,4($s0) 		# $t1 is item_num
	addi $s0,$s0,8		# shift to address of the first weight
	add $t2,$zero,$zero 	# $t2 is i
	
oloop:	slt $t3,$t2,$t1
	beq $t3,$zero,oexit		
	lw $t4,0($s0)		# set $t4 as weight
	lw $t5,4($s0)		# set $t5 as value
	addi $s0,$s0,8		# shift to the next weight address
	addi $t2,$t2,1
	
	# begin inner loop
	add $t6,$t0,$zero 	# $t6 is j
	
iloop:	slt $t3,$t6,$zero		
	bne $t3,$zero,iexit
	slt $t3,$t6,$t4
	bne $t3,$zero,skpchk	
	
	# find cache_ptr[j] and save in $t7
	sll $t9,$t6,2
	add $s1,$s1,$t9
	lw $t7,0($s1)
	sub $s1,$s1,$t9
	
	# find cache_ptr[j-weight] and save in $t8
	sub $t3,$t6,$t4		
	sll $t9,$t3,2
	add $s1,$s1,$t9
	lw $t8,0($s1)
	sub $s1,$s1,$t9
	
	# update $t8 = cache_ptr[j-weight]+val
	add $t8,$t8,$t5
	
	# if(cache_ptr[j]>cache_ptr[j-weight]+val)
	slt $t3,$t8,$t7
	bne $t3,$zero,skpchk	
	
	# else update cache_ptr[j] in memory	
	sll $t9,$t6,2
	add $s1,$s1,$t9
	sw  $t8,0($s1)
	sub $s1,$s1,$t9

skpchk:	addi $t6,$t6,-1	
	j iloop
	
iexit:	j oloop
	
oexit:	sll $t9,$t0,2
	add $s1,$s1,$t9	
	lw $v0,0($s1)		# final result save in $v0
	
