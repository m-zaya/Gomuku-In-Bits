.data
newLine: .asciiz "\n"
space: .asciiz "  "
board:  .byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
numSides: .asciiz "15 ", "14 ", "13 ", "12 ", "11 ", "10 ", "9  ",  "8  ", "7  ", "6  ", "5  ", "4  ", "3  ","2  ",  "1  "
numSideIndex: .word 0
colLabels: .asciiz "   A  B  C  D  E  F  G  H  I  J  K  L  M  N  O\n"	
	# Make this into an array with .word
colIndex: .word 0
rowIndex: .word 0
offset: .word 4
buffer: .space 3
askForColor: .asciiz "Will you be playing as black or white? \n(input a 0 or a 1: 0 = black, 1 = white) :: "
whatColumn: .asciiz "Enter column of your next move (A-O) : "
whatRow: .asciiz "Enter row of your next move (1-15) : "
notValidMessage: .asciiz "Your input is invalid! Check range of board, or availability of place on board!"
emptyOnBoard: .byte '.'
userCol: .ascii ""
userRow: .word 0


	.macro randomNum
	#delay so that when two numbers are generated, they are not the same
	addi $a0, $zero, 50
	li $v0, 32
	syscall
	
	#generate random number between 0 and 14
	addi $v0, $zero, 30
	syscall
	add $t0, $zero, $a0

	addi $v0, $zero, 40
	add $a0, $zero, $zero
	add $a1, $zero, $t0
	syscall

	addi $v0, $zero, 42
	add $a0, $zero, $zero
	addi $a1, $zero, 15     # Set upper bound to 15 (excluded)
	syscall
	add $s0, $zero, $a0 # copies the random number to #s0
	.end_macro
	
	
	.macro askPlayerMove
	#askPlayerMove
	li $v0, 4
	la $a0, whatColumn
	syscall
	# read in column
	li $v0, 8
	la $a0, buffer
	li $a1, 3
	
	addi $t1, $zero, 0
	move $t1, $a0
	
	syscall
	
	
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall
	
	# print prompt for row (1-15)
	li $v0, 4
	la $a0, whatRow
	syscall
	# read in row
	li $v0, 5
	syscall
	
	addi $t2, $zero, 0
	move $t2, $v0
	
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall
	
	# print move
	li $v0, 4	# try printing column as character -- later
	la $a0, buffer 
	move $a0, $t1
	syscall
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall
	
	isValid # with $t1 and $t2 holding user input
	.end_macro

	.macro isValid
	la $s0, board
	
	# before using do the following:
	#	set $s1 = column Index
	#	set $s2 = row Index
	addi $t0, $zero, 15
	
	# check if space is empty: 
	mul $t6, $s2, $t0 # $t6 <-- rowIndex * colsize
	add $t6, $t2, $s1 # $t6 <-- '' + colIndex
	mul $t6, $t2, 1 # $t6 <-- '' * dataSize (the one byte)
	add $t6, $t2, $s0 # $t6 <-- '' + baseAddr of board
	
	lb $t4, emptyOnBoard
	lb $t5, ($t6) # element accessed is in $t5
	bne $t4, $t5, validErrorMessage
	
	
	
	
	
	# Don't need to check range of coputer indexes, because the range was already set
	
	# here check for row validity (in range)
	blt $t2, 1, validErrorMessage
	bgt $t2, 15, validErrorMessage
	
	# check if user col is valid last - becuase cannot check equality otherwise
	addi $t3, $zero, 65 # starts with $t3 = A
	lb $t1, ($t1)
	j colValidity
	.end_macro
	

.text
main: 
	# ask player whether they want to play as black or white
	li $v0, 4
	la $a0, askForColor
	syscall
	
	li $v0, 5
	syscall # chack that the input was either a 0 or 1
		# display message showing what color the user chose to play as (also playing first or second)
	# do something with the input of what color the player is playing as -> who moves first

	
	askPlayerMove
	
	j printBoard
	
main2:
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall
	
	
	randomNum
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall	
	
	randomNum
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	
	j exit



printBoard:
    la $s0, board
    lw $s1, colIndex
    lw $s2, rowIndex
    lw $s4, offset
    la $t6, numSides
    lw $t7, numSideIndex
    
    addi $s2, $zero, 0
    addi $t0, $zero, 15
    
    
    # prints column Labels - top
	li $v0, 4
	la $a0, colLabels
	syscall
    
    j outerLoopPrint

outerLoopPrint:
	
	li $v0, 4
	move $a0, $t6
	syscall

	jal innerLoopPrint
	
	
	# prints a new line
	li $v0, 4
	la $a0, newLine
	syscall
	
	addi $s1, $zero, 0
	
	addi $s2, $s2, 1 # increments rowIndex
	# increment rows
    
	blt $s2, $t0, outerLoopPrint # if row counter < 15, loops outerLoopPrint
	j bottomColLabel

innerLoopPrint:
	mul $t2, $s2, $t0 # $t2 <-- rowIndex * colsize
	add $t2, $t2, $s1 # $t2 <-- '' + colIndex
	mul $t2, $t2, 1 # $t2 <-- '' * dataSize (the one byte)
	add $t2, $t2, $s0 # $t2 <-- '' + baseAddr of board


	# printing out the characters
	li $v0, 11
	lb $a0, ($t2)
	syscall
    	
    	# prints a space
	li $v0, 4
	la $a0, space
	syscall
    	
    	
	addi $s1, $s1, 1 # column index increment
	blt $s1, $t0, innerLoopPrint
    	
    	li $v0, 4
	move $a0, $t6
	syscall
    	
    	addi $t6, $t6, 4
    	
	jr $ra
	
bottomColLabel:
	# prints column Labels - top
	li $v0, 4
	la $a0, colLabels
	syscall
	
	j main2
	
validErrorMessage:
	li $v0, 4
	la $a0, notValidMessage
	syscall
	j main

colValidity:
	bgt $t3, 79, validErrorMessage  # max range
	beq $t1, $t3, main2
	addi $t3, $t3, 1
	j colValidity

	
	
# map user input && comp input as a spot on the board
# check if input is valid (taken or out of range)


# Things to maybe-do
	# print move made < "you made blank move" & "computer made blank move)

exit: 
	li $v0, 10
	syscall
