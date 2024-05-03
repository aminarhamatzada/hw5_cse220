.data 
	space: .asciiz " "
	null: .asciiz ""

.text

init_student:

	# $a0 - id, $a1 - credit, $a2 - name

	# combine id and credit by shifitng left

	sll $a0, $a0, 10	# logical shift
	or $a0, $a0, $a1	# combine id and credit
	
	sw $a0, 0($a3)	# write the id and credit
	sw $a2, 4($a3)	# write the name

	jr $ra
	
print_student:
	
	# printing id #
	
	lw $t1, 0($a0)		# load the id and credit
	lw $t3, 4($a0)		# load the name 
	srl $t2, $t1, 10	# shift right by 10 and t2 is id

	li $v0, 1			# load print integer code
	move $a0, $t2		# move for printing
	syscall 			# issue a system call
	
	li $v0, 4			# load print string code
	la $a0, space		# print blank space
	syscall				# issue a system call
	
	# printing the credits #

	#lw $t2, 0($a0)		# load the id and credit
	
	sll $t2, $t1, 22	# shift credit left by 22
	srl $t2, $t2, 22	# shift credit back right by 22 

	move $a0, $t2		# move for printing
	li $v0, 1			# load print integer code
	syscall				# issue a system call
	
	li $v0, 4			# load print string code
	la $a0, space		# print blank space
	syscall				# issue a system call
	
	# printing the name as a string #
	
	move $a0, $t3		# move for printing
	li $v0, 4			# load print string code
	syscall				# issue a system call

	jr $ra

init_student_array:
	
	# preamble the values #

	addi $sp, $sp, -32
	sw $ra, 0($sp)

	# delclaration #
	
	sw $s0, 4($sp)		# num_students
	sw $s1, 8($sp)		# id_list should be 1
	sw $s2, 12($sp)		# credits_list
	sw $s3, 16($sp)		# names pointer 
	sw $s4, 20($sp)		# student records pointer 
	sw $s5, 24($sp)		# loop counter
	sw $s6, 28($sp)		# offset 
	
	# moving #
	
	move $s0, $a0		# move num_students
	move $s1, $a1		# move id list
	move $s2, $a2		# move credits list
	move $s3, $a3		# move names pointer
	
	# we reached the limit #

	lw $s4, 32($sp)		# move student records
	li $s5, 0			# set counter to 0
	
	loop:

		beq $s5, $s0, done	# terminate loop when if counter >= num_student
        	
		lw $t1, 0($s1)      # load id
		move $a0, $t1		# move id

		lw $t2, 0($s2)     	# load credits
        move $a1, $t2		# move credits

        move $a2, $s3		# name
		move $a3, $s4	
        	
		jal init_student	# call init function
		
		# create loop to go through name #
		
		inner_loop:
		
			lbu $t1, 0($s3)	# lbu to extract name 
			 
			# compare to 0, if zero branch to inner done
			# if not move char array over one (addi), then j inner_loop

			beqz $t1, inner_done		# exit if name is '\0'

			addi $s3, $s3, 1	# increment names pointer
			
			j inner_loop
		
		inner_done:		
		
			addi $s1, $s1, 4	# increment id
			addi $s2, $s2, 4	# increment credits
			addi $s3, $s3, 1	# increment name pointer
			addi $s4, $s4, 8	# increment record
			addi $s5, $s5, 1 	# increment loop counter
			
			j loop 			# jump back to the begninning
		
	done:
	
		# postamble - load all the function arguments # 

		lw $ra, 0($sp)
		lw $s0, 4($sp)		# restore num_students
		lw $s1, 8($sp)		# restore id_list
		lw $s2, 12($sp)		# restore credits_list
		lw $s3, 16($sp)		# restores names pointer 
		lw $s4, 20($sp)		# restores student records pointer 
		lw $s5, 24($sp)		# restores offset 
		lw $s6, 28($sp)		# restore loop counter
	
		addi $sp, $sp, 32	# free up space 
	
	jr $ra	

insert:

	# a0 - pointer to record, a1 - pointer to hash table, a2 - table size

	lw $t0, 0($a0) 		# load record pointer
	srl $t1, $t0, 10 	# shift t0 to access id 

	div $t1, $a2 	# then divide id by table size 
	mfhi $t1 		# mfhi remainder, index that i want to insert

	# loop for linear probing #

	li $t4, 0 		# loop counter
	move $t6, $a1	# put a1 in temp variable
	li $t8, -1   #this is tombstone value 

	loop_linear_probing :

		sll $t2, $t1, 2 	# t2=offset calculate offset for hash index
		add $t3, $t6, $t2 	# t3=base address calculate address in table
		lw $t5, 0($t3)		# load value from hash table

		# TODO: beq to check if the counter is the size of the table (if table is full)
		
		beq $t4, $a2, error #when its full, goes to error 
		beq $t5, $t8, record 
		beq $t5, $zero, record
	

		# TODO: bne if statement hash index reaches the end, we have to loop around, reset address to og, in this case use a1 (set t3 to a1)
        
		beq $t1, $a2, reset_index
		
		addi $t4, $t4, 1	# increment counter

    	#bne $t1, $a1, loop_linear_probing #TODO: if end the loop, jump and -1

		addi $t1, $t1, 1	# increment hash index this is our original index 
		j loop_linear_probing


		reset_index:
			li $t1, 0
			addi $t4, $t4, 1	# increment counter
			j loop_linear_probing

		# check if table is full, return -1 #
		#li $v0, -1			# returns -1

		# j loop_linear_probing

	record: 
		sw $a0, 0($t3)      # insert record into hash table
    	move $v0, $t1       # return index
		j done_inserting

	error: 
		li $v0, -1       
	
	done_inserting:

	jr $ra
	
search:

	# a0 - id, a1 - pointer to hash, a2 - table size

	# use branch to return something if we fail $v0 #

	li $v0, 0
	li $v1, -1

	jr $ra

delete:

	li $v0, -1

	jr $ra
