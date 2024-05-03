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
		
		sll $s6, $s5, 3   	# multiply loop counter by 8
        add $t7, $t4, $t6	# calculate address 
        	
		lw $t1, 0($s1)      # load id
		move $a0, $t1		# move id

		lw $t2, 0($s2)     	# load credits
        move $a1, $t2		# move credits

        move $a2, $s3		# name
		move $a3, $s4	
        	
		jal init_student	# call init function
		
		# create loop to go through name
		
		inner_loop:
		
			# lb to extract name 
			lbu $t1, 0($s3)
			 
			# compare to 0, if zero branch to inner done
			# if not move char array over one (addi), then j inner_loop

			beqz $t0, done		# exit if name is '\0'

			addi $s3, $s3, 1	# increment names pointer
			addi $s5, $s5, 1 	# increment loop counter
			
			j inner_loop
		
		inner_done:		
		
			addi $s1, $s1, 4	# increment id
			addi $s2, $s2, 4	# increment credits
			addi $s3, $s3, 1	# increment name pointer
			addi $s4, $s4, 8	# increment record
			addi $t5, $t5, 1 	# increment loop counter
		
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
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
