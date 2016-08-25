.globl main #Declare main as a global function

  .data #.data directive begins memory structure declaration

    game:         .asciiz "   |-----|   Word: _______\n   |     |\n         |   Misses:        \n         |\n         |\n         |\n         |\n ---------\n"
    msg_1:        .asciiz "Welcome to hangman!\nImplemented by Gary Dunn\n\n"
    msg_2:        .asciiz "Enter next character (A-Z), or 0 to exit: "
    msg_win:      .asciiz "\nCongratulations! You have won.\n"
    msg_lose:     .asciiz "\nYou lost; out of moves.\n"
    msg_error:    .asciiz "\nInvalid input; try again.\n"
    word:         .asciiz "HANGMAN"
    wordLength:   .word 7
    missesCount:  .word 0
    hitsCount:    .word 0

  .text #Assembler directive for text code
  main:
    li $v0, 4       #Code for string printing
    la $a0, msg_1   #Location of string in memory
    syscall         #Print welcome message

    mainLoop:
      li $v0, 4     #Code for string printing
      la $a0, game  #Location of string in memory
      syscall       #Print game

      jal getInput
      move $a0, $v0 #Put the returned character into a0 for checkInput
      jal checkInput

      lw $t7, hitsCount #Grab current hits count
      add $t7, $t7, $v0 #Add the new hits to it
      sw $t7, hitsCount #Store new hits count

      beq $v0, $zero, ifmiss #Check if there were no hits with this char
      j endifmiss #if structure
      ifmiss:     #if structure
        jal miss  #if no hits, call miss function; a0 still has char input in it
      endifmiss:  #if structure

      lw $t0, missesCount #Get number of misses
      beq $t0, 6, lose    #If max misses has been hit, quit

      lw $t0, hitsCount   #Get number of hits
      lw $t1, wordLength  #Get length of word
      beq $t0, $t1, win   #If all word letters hit, win


      j mainLoop #repeat loop
    endMainLoop:
  j exit #Exit program

##This function adds the missed guess to the board and increments the miss counter
##Takes in $a0 the character missed
  miss:
    la $t6, game  #Grab start address of the game drawing for editing
    lw $t7, missesCount #Grab misses count to increment and figure spacing
    addi $t5, $t6, 58  #t5 = address of first letter of misses
    add $t5, $t5, $t7  #t5 = address of next open space in misses land
    sb $a0, 0($t5)     #Update the board with the new misses

    #Choose which part of the hangman to update
    beq $t7, 0, head
    beq $t7, 1, body
    beq $t7, 2, leftArm
    beq $t7, 3, rightArm
    beq $t7, 4, leftLeg
    beq $t7, 5, rightLeg
    j endHangmanUpdate #Or just end

    head:
      addi $t5, $t6, 41 #Get address of head character
      li $t4, 79        #Set character code for 'O'
      sb $t4, 0($t5)    #Set head character to 'O'
      j endHangmanUpdate
    body:
      addi $t5, $t6, 70 #Get address of body1 character
      li $t4, 124        #Set character code for '|'
      sb $t4, 0($t5)    #Set game character to '|'
      addi $t5, $t6, 81 #Get address of body2 character
      li $t4, 124        #Set character code for '|'
      sb $t4, 0($t5)    #Set game character to '|'
      j endHangmanUpdate
    leftArm:
      addi $t5, $t6, 69 #Get address of leftArm character
      li $t4, 92        #Set character code for '\'
      sb $t4, 0($t5)    #Set game character to '\'
      j endHangmanUpdate
    rightArm:
      addi $t5, $t6, 71 #Get address of rightArm character
      li $t4, 47        #Set character code for '/'
      sb $t4, 0($t5)    #Set game character to '/'
      j endHangmanUpdate
    leftLeg:
      addi $t5, $t6, 91 #Get address of leftLeg character
      li $t4, 47        #Set character code for '/'
      sb $t4, 0($t5)    #Set game character to '/'
      j endHangmanUpdate
    rightLeg:
      addi $t5, $t6, 93 #Get address of rightLeg character
      li $t4, 92        #Set character code for '\'
      sb $t4, 0($t5)    #Set game character to '\'
      j endHangmanUpdate

    endHangmanUpdate:

    addi $t7, $t7, 1 #Misses++
    sw $t7, missesCount #Store misses count back after incrementing

  endMiss:
  jr $ra



##This function reads a character input from the user, silently ignoring newlines,
##and passes the read character back in $v0
  getInput:
    li $v0, 4     #Code for string printing
    la $a0, msg_2 #Location of string in memory
    syscall       #Print prompt

    purgeNL:
      li $v0, 12    #Code for get char input
      syscall       #Get char input into v0
    beq $v0, 10, purgeNL #Get next char in buffer if current is a NL char
    move $t0, $v0   #t0 = input character

    li $v0, 11   #Code for print char
    li $a0, 10   #Char to print (newline)
    syscall
    syscall      #Print a couple newlines

    beq $t0, 48, exit #If zero, exit program
    blt $t0, 65, invalidInput #Check lower ascii number than 'A'
    bgt $t0, 90, invalidInput #Check higher ascii number than 'Z'
    j endGetInput #No input error

    invalidInput:
      li $v0, 4         #Code for string printing
      la $a0, msg_error #Location of string in memory
      syscall           #Print error message
      j getInput         #Start the loop over

  endGetInput:
  move $v0, $t0 #Return character
  jr $ra        #End function



  #This function iterates through the hangman word, checking if each character
  #matches the input character, revealing it on the board if so, and then
  #incrementing the counter of correct guesses
  checkInput:
    li $v0, 0  #Initialize return value "count" to zero
    li $t0, 0  #Initialize iterator to zero
    lw $t1, wordLength #Grab the word length
    la $t7, word  #Grab start address of word for checking
    la $t6, game  #Grab start address of the game drawing for editing
    forLoop:
      beq $t0, $t1, endCheckInput #End for when iterator = word length
      add $t2, $t0, $t7 #t2 = address of current character
      lb $t3, 0($t2)    #Load current character to t3
      beq $t3, $a0, match #Check if input equals current char
      j repeatForLoop   #Else repeat loop, check next char

      match: #Can use t2,4,5
        add $t2, $t6, 19 #t2 = address of first char of word in game
        add $t2, $t2, $t0     #t2 = address of char being checked
        lb $t4, 0($t2)   #t4 = char in Game being checked
        bne $t4, $t3, nonrepeat #Check if char not already revealed
        j repeatForLoop #Else, silently repeat loop


      nonrepeat:
        addi $v0, $v0, 1 #count++
        sb $t3, 0($t2)   #Reveal char on game board

    repeatForLoop:
      addi $t0, 1 #iterator++
      j forLoop   #Restart loop

    endForLoop:

  endCheckInput:
  jr $ra #Return value already set in $v0 at this point



  win:
    li $v0, 4     #Code for string printing
    la $a0, game  #Location of string in memory
    syscall       #Print game

    li $v0, 4       #Code for string printing
    la $a0, msg_win #Location of string in memory
    syscall         #Print win message
    j exit          #Stop execution
  lose:
    li $v0, 4     #Code for string printing
    la $a0, game  #Location of string in memory
    syscall       #Print game
  
    li $v0, 4       #Code for string printing
    la $a0, msg_lose#Location of string in memory
    syscall         #Print win message
    j exit          #Stop execution


  exit:
  li $v0, 10 # Sets $v0 to "10" to select exit syscall
	syscall # Exit
