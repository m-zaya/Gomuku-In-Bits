# Program: Gomoku game, similar to connect 4, except it is 5 in a row, and there is free placement on the board
# Names: Sneha Bista, Sherry Cherniavsky, Kate Lopez, Judy Yang
# Due Date: 1 December 2022
# Course: CS 2340.001
    
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
colIndex: .word 0
rowIndex: .word 0
offset: .word 4
buffer: .space 3
askForColor: .asciiz "Will you be playing as black or white? Black will go first! \n(input a 0 or a 1: 0 = black, 1 = white) :: "
whatColumn: .asciiz "\nEnter column of your next move (A-O) *capital letters only* : "
whatRow: .asciiz "Enter row of your next move (1-15) : "
notValidMessage: .asciiz "Your input is invalid! Check range of board, or availability of place on board!"
emptyOnBoard: .byte '.'
makeBlackMove: .byte '*'
makeWhiteMove: .byte 'O'
userCol: .word 0
userRow: .word 0
black: .asciiz "Black"
white: .asciiz "White"
printBlackMove: .asciiz "Black's current move is: "
printWhiteMove: .asciiz "White's current move is: "
winnerMsg: .asciiz " is the winner with 5 pieces in a row!\n\n"
exitPrompt: .asciiz "\n\nIf you'd like to quit the game, enter a #\n"


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
    addi $a1, $zero, 15 # Set upper bound to 15 (excluded)
    syscall
    add $s0, $zero, $a0 # copies the random number to #s0
    .end_macro
    
    ############################################### reading in player move ###########################################
    
    .macro askPlayerMove
    
    # prompt for exit
    li $v0, 4
    la $a0, exitPrompt
    syscall
    
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
    
    lb $t1, ($t1) # letter in $t1
    beq $t1, 35, exit
    
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
    
    
    isValid # with $t1 and $t2 holding user input
    .end_macro
 
 ################################## checking valid user input then placing move ####################################
 
    .macro isValid
    # before using do the following:
    #    set $s1 = column Index
    #    $t2 should have row index
    addi $t0, $zero, 15 #setting col size
    
     # Don't need to check range of computer indexes, because the range was already set
    
    # here check for row validity (in range)
    blt $t2, 1, validErrorMessage
    bgt $t2, 15, validErrorMessage
    
    #check col validity
    addi $t3, $zero, 79 # starts with $t3 = O
    jal colValidity # check if column is valid, then continue to check if place on board is empty
    
    addi $s1, $zero, 0
    subi $s1, $t3, 65 # col index: $t3 now contains ascii value for column, subtract 65(A) from $t3 to get correct board placement
    
    
    bnez $s7, whitePrint #checking if player is white or black
    
    # print move
    li $v0, 4
    la $a0, printBlackMove
    syscall
    j printMove
    
    
    whitePrint:
    li $v0, 4
    la $a0, printWhiteMove
    syscall
    
    printMove:
    li $v0, 11
    move $a0, $t3
    syscall
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    # prints a new line
    li $v0, 4
    la $a0, newLine
    syscall
    
     # prints a new line
    li $v0, 4
    la $a0, newLine
    syscall
    
    
    addi $t7, $zero, 0
    addi $t7, $t7, 15 
    sub $t2, $t7, $t2 # getting row to be in the correct position on the board since its flipped (index 0 is on top, not bottom)
    
    la $s0, board
    # check if space is empty:
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
    
    lb $t4, emptyOnBoard
    lb $t5, ($t6) # element accessed is in $t5
    bne $t4, $t5, validErrorMessage
    beqz $s7, blackMove # move with a black piece if player chose 0
    j whiteMove # else move with white piece
    
    .end_macro
    
    ################################ printing and placing computer move #########################################
    
    .macro computerMove
    addi $t0, $zero, 15 #setting col size
    la $s0, board
    addi $t7, $zero, 0
    addi $t7, $t7, 14
    
    addi $t6, $zero, 0
    addi $t6, $s1, 65
    
    bnez $s7, blackPrint #checking if player is white or black
    # print move
    li $v0, 4
    la $a0, printWhiteMove
    syscall
    j printMove2
    
    
    blackPrint:
    li $v0, 4
    la $a0, printBlackMove
    syscall
    
    printMove2:
    li $v0, 11    #printing column as character
    move $a0, $t6
    syscall
    
    addi $t2, $t2, 1
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    addi $t2, $t2, -1
    
    # prints a new line
    li $v0, 4
    la $a0, newLine
    syscall
    
     # prints a new line
    li $v0, 4
    la $a0, newLine
    syscall
    
    sub $t2, $t7, $t2 #getting correct placement on board for row (subtract row from 14 since we have the random numbers go from 0-14)
    # check if space is empty:
    
    addi $t6, $zero, 0
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
    
    lb $t4, emptyOnBoard
    lb $t5, ($t6) # element accessed is in $t5
    bne $t4, $t5, main2
    beqz $s7, whiteMove # player chose black, computer needs to move with white
    j blackMove # else player chose white, computer moves with black
    
    .end_macro
  
    ####################################### CHECK UP ########################################################
    
    .macro checkUp
    la $s0, board
    addi $s6, $zero, 1 #set counter
    
    loopUp:
    bgt $s6, 5, done
    addi $t6, $zero, 0
    addi $t2, $t2, -1 #change index to next row up
    blt $t2, 0, done #make sure check doesn't go out of bounds
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
    
    lb $t5, ($t6) # element accessed is in $t5
    bne $t7, $t5, done
    addi $s6, $s6, 1 #increment counter
    j loopUp 
    
    done:
    bne $s6, 5, moveOn 
    whoWon:
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    moveOn:
    .end_macro
    
    ############################################ CHECK DOWN #####################################################
    
    .macro checkDown
    la $s0, board
    addi $t2, $s5, 0 #reset row position since it was changed last check
    
    loopDown:
    bgt $s6, 5, done2
    addi $t6, $zero, 0
    addi $t2, $t2, 1 #change index to next row down
    bgt $t2, 14, done2 #make sure check doesn't go out of bounds
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
    
    lb $t5, ($t6) # element accessed is in $t5
    bne $t7, $t5, done2
    addi $s6, $s6, 1 #increment counter
    j loopDown 
    
    done2:
    bne $s6, 5, moveOn2 
    whoWon2:
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    moveOn2:
    
    .end_macro
    
    ##################################### CHECK RIGHT ################################################
    .macro checkRight
    addi $s6, $zero, 1 #set counter
    addi $t0, $zero, 15 # setting col size
    la $s0, board # load the address of board
    
    move $t2, $s5 #reset row position
    towardsRight:
        bgt $s6, 5, finishRight
         addi $s1, $s1, 1 # increment column
     bgt $s1, 14, finishRight
     
      
  #get the character in the next position
       addi $t6, $zero, 0
       mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
       add $t6, $t6, $s1 # $t6 <-- '' + colIndex
       mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
       add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
       lb $t5, ($t6) # element accessed is in $t5
       bne $t5, $t7, finishRight
       addi $s6, $s6, 1
       j towardsRight
   
   
       finishRight:
        bne $s6, 5, nextDirection
    winner:
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    nextDirection:
    
    .end_macro
    
    #################################### CHECK RIGHT ##################################################
    
    
    #################################### CHECK LEFT ##################################################
    
    .macro checkLeft
    
    addi $t0, $zero, 15 # setting col size
    la $s0, board # load the address of board
    move $s1, $s4 #reset col position
        
        towardsLeft:
        bgt $s6, 5, finishLeft
         addi $s1, $s1, -1 # increment column
     blt $s1, 0, finishLeft
     
      
      #get the character in the next position
       addi $t6, $zero, 0
       mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
       add $t6, $t6, $s1 # $t6 <-- '' + colIndex
       mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
       add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board
       lb $t5, ($t6) # element accessed is in $t5
       bne $t5, $t7, finishLeft
       addi $s6, $s6, 1
       j towardsLeft
   
   
       finishLeft:
        bne $s6, 5, nextDirection2
    winner:
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    nextDirection2:
    
    .end_macro
    
    
    #################################### CHECK LEFT ##################################################

         ################################### CHECK DIAG UPPER LEFT ######################################
         
# Check upper left to lower right diagonal
    .macro checkDiagUL
    addi $t0, $zero, 15 # setting col size
    la $s0, board
    li $t8, 1 # count the number of symbols starting at 1, which is the current element
    move $t2, $s5 #restoring row and col of move
    move $s1, $s4
    
    diagUL:
    bgt $t8, 5, finished
    # row-1
    addi $t2, $t2, -1
    
    # column-1
    addi $s1, $s1, -1
    
    blt $t2, 0, finished # doesn't go out of bounds for row
    blt $s1, 0, finished # doesn't go out of bounds for column
    
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board  
     
    lb $t5, ($t6) # current element access is in $t5
    bne $t7, $t5, finished # branch to jump if the element at a new position is not equal to the element in the old position
    
    addi $t8, $t8, 1 # increments symbol counter
    j diagUL
            
    finished:
    bne $t8, 5, end
    # white wins if the input symbol matches, otherwise black wins
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    end:
    .end_macro
 
    ###################################### CHECK DIAG LOWER RIGHT #################################################
    
    .macro checkDiagLR
    addi $t0, $zero, 15 # setting col size
    la $s0, board
    move $t2, $s5 #restoring row and col of move
    move $s1, $s4
    
    diagLR:
    bgt $t8, 5, finished2
    # row+1
    addi $t2, $t2, 1
    
    # column+1
    addi $s1, $s1, 1
    
    bgt $t2, 14, finished2 # doesn't go out of bounds for row
    bgt $s1, 14, finished2 # doesn't go out of bounds for column
    
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board  
     
    lb $t5, ($t6) # current element access is in $t5
    bne $t7, $t5, finished2 # branch to jump if the element at a new position is not equal to the element in the old position
    
    addi $t8, $t8, 1 # increments symbol counter
    j diagLR
            
    finished2:
    bne $t8, 5, end2
    # white wins if the input symbol matches, otherwise black wins
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    end2:
    .end_macro

    #################################### CHECK DIAG UPPER RIGHT #################################################
    .macro checkDiagUR
    addi $t0, $zero, 15 # setting col size
    la $s0, board
    move $t2, $s5 #restoring row and col of move
    move $s1, $s4
    li $t8, 1 # count the number of symbols starting at 1, which is the current element
    
    diagUR:
    bgt $t8, 5, finished3
    # row-1
    addi $t2, $t2, -1
    
    # column+1
    addi $s1, $s1, 1
    
    blt $t2, 0, finished3 # doesn't go out of bounds for row
    bgt $s1, 14, finished3 # doesn't go out of bounds for column
    
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board  
     
    lb $t5, ($t6) # current element access is in $t5
    bne $t7, $t5, finished3 # branch to jump if the element at a new position is not equal to the element in the old position
    
    addi $t8, $t8, 1 # increments symbol counter
    j diagUR
            
    finished3:
    bne $t8, 5, end3
    # white wins if the input symbol matches, otherwise black wins
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    end3:
    .end_macro
    
    ########################################## CHECK DIAG LOWER LEFT #########################################
    
    .macro checkDiagLL
    addi $t0, $zero, 15 # setting col size
    la $s0, board
    move $t2, $s5 #restoring row and col of move
    move $s1, $s4
    
    diagLL:
    bgt $t8, 5, finished4
    # row+1
    addi $t2, $t2, 1
    
    # column-1
    addi $s1, $s1, -1
    
    bgt $t2, 14, finished4 # doesn't go out of bounds for row
    blt $s1, 0, finished4 # doesn't go out of bounds for column
    
    mul $t6, $t2, $t0 # $t6 <-- rowIndex * colsize
    add $t6, $t6, $s1 # $t6 <-- '' + colIndex
    mul $t6, $t6, 1 # $t6 <-- '' * dataSize (the one byte)
    add $t6, $t6, $s0 # $t6 <-- '' + baseAddr of board  
     
    lb $t5, ($t6) # current element access is in $t5
    bne $t7, $t5, finished4 # branch to jump if the element at a new position is not equal to the element in the old position
    
    addi $t8, $t8, 1 # increments symbol counter
    j diagLL
            
    finished4:
    bne $t8, 5, end4
    # white wins if the input symbol matches, otherwise black wins
    lb $t6, makeWhiteMove
    beq $t7, $t6, whiteWinner
    j blackWinner
    end4:
    .end_macro
    
    
.text
main:
    # ask player whether they want to play as black or white
    li $v0, 4
    la $a0, askForColor
    syscall
    
    li $v0, 5
    syscall
    
    move $s7, $v0 #store player color
        # display message showing what color the user chose to play as (also playing first or second)
    bnez $s7, main2 #if player chose white, computer goes first    
    
    askPlayerMove
    
main2:

    # prints a new line
    li $v0, 4
    la $a0, newLine
    syscall
    
    
    randomNum
    
    addi $s1, $zero, 0
    addi $s1, $s0, 0 #store column
 
    randomNum
    
    addi $t2, $zero, 0
    addi $t2, $s0, 0 #store row
    
    computerMove


printBoard:
    move $t9, $ra #saving return address from jal while other jals occur in printBoard
    
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
    move $ra, $t9 # restore original $ra from where printBoard was called
    jr $ra
    
 
    
validErrorMessage:
    li $v0, 4
    la $a0, notValidMessage
    syscall
    askPlayerMove

colValidity:
    blt $t3, 65, validErrorMessage  # min range
    beq $t1, $t3, jump
    subi $t3, $t3, 1
    j colValidity
jump:
    jr $ra
    
blackMove:
    lb $t7, makeBlackMove
    beqz $s7, changeBoard # based on what color is playing, did the player make the move?
    j changeBoardComp #if not, the computer made it
    
whiteMove:
    lb $t7, makeWhiteMove
    bnez $s7, changeBoard
    j changeBoardComp
    
changeBoard:
    sb $t7, ($t6)
    move $s5, $t2
    move $s4, $s1
    checkUp
    checkDown
    checkRight
    checkLeft
    checkDiagUL
    checkDiagLR
    checkDiagUR
    checkDiagLL
    
  
    jal printBoard
    j main2 #computer's turn now
 
    
changeBoardComp:
    sb $t7, ($t6)
    move $s5, $t2 #row
    move $s4, $s1 #col
    checkUp
    checkDown
    checkRight
    checkLeft
    checkDiagUL
    checkDiagLR
    checkDiagUR
    checkDiagLL
    
    jal printBoard
    askPlayerMove #player's turn now
    
blackWinner:
    li $v0, 4
    la $a0, black
    syscall
    
    li $v0, 4
    la $a0, winnerMsg
    syscall
    j exit


whiteWinner:
    li $v0, 4
    la $a0, white
    syscall
    
    li $v0, 4
    la $a0, winnerMsg
    syscall
    

exit:
    jal printBoard
    li $v0, 10
    syscall

