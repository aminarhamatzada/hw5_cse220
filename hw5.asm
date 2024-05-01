.data 
	space: .asciiz " "

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
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
