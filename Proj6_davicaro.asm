TITLE CS 271 Project 6 - MACROs and String Primitives    (Proj6_davicaro.asm)

; Author: Caroline Davis
; Last Modified: 06/06/2021
; OSU email address: davicaro@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6   Due Date: 6/6/2021
; Description: This program contains two macros. One that retrieves a string, and one that displays a specified string.
;	Additionally, there are two procedures - one that that reads a string that contains ASCII representations of integers,
;	and converts it to the numeric value of that integer. The other procedure writes an ASCII representation of a numeric value.
; The program displays an introduction to the user, and prompts the user for a signed integer input. It repeats this prompt 10 times,
;	and validates each integer to ensure that it is not too large, and does not contain invalid characters or symbols. These 10
;	integers are stored in an array. The sum and average of these integers are calculated. The program then displays to the console:
;	the array of integers, the sum of the integers, the average, and a goodbye message.


INCLUDE Irvine32.inc

; ------------------------------------------------------------------
; name: mGetString
;
; Prompts the user for a string, then stores the user's keyboard input into
;	a memory address.
;
; Preconditions: Pass all arguments as a memory OFFSET, except for maxCharacters.
;
; Receives:
; prompt = OFFSET string address
; keyboardInput = OFFSET empty array address - receiving array for keyboard input
; maxCharacters = integer input - SIZEOF keyboardInput
; byteCount = OFFSET address of empty SDWORD
;
; Returns: 
; byteCount = integer value of how many bytes were entered via keyboardInput
; keyboardInput = ASCII string inputted by user
; ------------------------------------------------------------------
mGetString	MACRO prompt, keyboardInput, maxCharacters, byteCount
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, keyboardInput
	MOV		ECX, maxCharacters
	CALL	ReadString
	MOV		byteCount, EAX
	MOV		keyboardInput, EDX
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

; ------------------------------------------------------------------
; name: mDisplayString
; 
; Displays a string to the console via an argument of the string OFFSET address.
;
; Preconditions: String must be passed by OFFSET
;
; Receives: stringToPrint = OFFSET of address of string to be printed to console.
;
; Returns: None, prints string to console.
; ------------------------------------------------------------------
mDisplayString	MACRO stringToPrint
	PUSH	EDX
	MOV		EDX, stringToPrint
	CALL	WriteString
	POP		EDX
ENDM

MAXIMUM_LENGTH = 11
.data

titleMessage			BYTE		"Programming Assignment 6: Designing Low-Level I/O Procedures",13,10
						BYTE		"Programmed by: Caroline Davis",13,10,0
instructionMessage		BYTE		"Please provide 10 signed integers.",13,10
						BYTE		"Each number needs to be small enough to fit inside a 32-bit register. After you have finished "
						BYTE		"inputting the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,0
enterNumMessage			BYTE		"Please enter a signed number: ",0
errorMessage			BYTE		"ERROR: You did not enter a signed number or your number was too big.",13,10
						BYTE		"Please try again: ",0
displayArrayMessage		BYTE		"You entered the following numbers: ",13,10,0
sumOfNumsMessage		BYTE		"The sum of these numbers is: ",0
roundedAverageMessage	BYTE		"The rounded average is: ",0
goodbyeMessage			BYTE		"Thanks for playing! Til next time...",0
isInvalidNum			BYTE		0
keyboardInput			BYTE		32 DUP(?)
byteCount				DWORD		?
asciiStringReverse		DWORD		10 DUP(?)
asciiStringForward		DWORD		10 DUP(?)
numericValuesArray		SDWORD		10 DUP(?)
lenNumericArray			SDWORD		LENGTHOF numericValuesArray
maxCharacters			SDWORD		SIZEOF keyboardInput
numsSum					SDWORD		?
numsAverage				SDWORD		?


.code

main PROC

_introductionMessage:
	PUSH	OFFSET titleMessage
	PUSH	OFFSET instructionMessage
	CALL	Introduction

_ReadValLoopBlock:
; ------------------------------------------------------------------
; ReadValLoop loops 10 times, calling the ReadVal procedure 10 times. This
;	prompts the user to enter a valid signed integer - the integer should not 
;	contain invalid symbols or characters, and should be able to fit in a 32-bit 
;	register. EDI is initially pointing to the OFFSET of an empty array, and this
;	pointer is passed to the ReadVal procedure. ESI points to the OFFSET of the
;	prompt to be displayed to the user.
; If an invalid number is entered - it is not added to the numeric array,
;	and does not decrement the loop counter.
; Each time the loop iterates, it incrememnts the receiving array by 4 
;	because each numeric value is 1 SDWORD (4 bytes).
; ------------------------------------------------------------------
_readValLoopPreconditions:
	MOV		ECX, 10
	MOV		EDI, OFFSET numericValuesArray
	MOV		ESI, OFFSET enterNumMessage

_readValLoop:
	PUSH	OFFSET isInvalidNum
	PUSH	OFFSET keyboardInput  
	PUSH	maxCharacters
	PUSH	OFFSET byteCount
	PUSH	ESI										; Contains address of prompt
	PUSH	EDI										; Contains address of empty index in numericValuesArray 
	CALL	ReadVal
	CMP		isInvalidNum, 0
	JNE		_invalidNum

_copyInputToArray:
	ADD		EDI, 4
	MOV		ESI, OFFSET enterNumMessage
	LOOP	_readValLoop
	JMP		_endReadValLoop

_invalidNum:
	MOV		ESI, OFFSET errorMessage
	MOV		isInvalidNum, 0
	JMP		_readValLoop

_endReadValLoop:

; ------------------------------------------------------------------
; The WriteValLoop iterates 10 times to write 10 ASCII representations
;	of numeric values via the WriteVal procedure. The source array, where
;	the initial numeric values are stored is being pointed to by ESI.
;	ESI is incremented by 4 (1 SDWORD) each iteration. 
; ExtraChars (a comma and a space) are added after each value is printed to 
;	the console until the last value is printed (i.e. ECX == 1).
; ------------------------------------------------------------------
_WriteValLoopBlock:

_descriptiveMessage:
	CALL	CrLf
	mDisplayString OFFSET displayArrayMessage

	MOV		ECX, 10
	MOV		ESI, OFFSET numericValuesArray		
_writeValLoop:
	MOV		EBX, [ESI]
	PUSH	OFFSET asciiStringForward
	PUSH	EBX										; Contains next numericValueArray value to be printed 		
	PUSH	OFFSET asciiStringReverse 
	CALL	WriteVal				  
	CMP		ECX, 1
	JE		_endWriteLoopBlock

_extraChars:
	MOV		AL, 2Ch									; 2Ch == ASCII ","
	CALL	WriteChar
	MOV		AL, 20h									; 20h == ASCII *SPACE*
	CALL	WriteChar

_incrementArray:
	ADD		ESI, 4
	LOOP	_writeValLoop

_endWriteLoopBlock:

; Passes arguments to CalculateSum procedure.
_calculateSumBlock:
	PUSH	OFFSET numericValuesArray  
	PUSH	lenNumericArray			   
	PUSH	OFFSET numsSum			   
	CALL	CalculateSum

; Displays a message, indicating the sum, and the ASCII representation of the sum.
_sumDisplay:	
	CALL	CrLf
	mDisplayString OFFSET sumOfNumsMessage
	PUSH	OFFSET asciiStringForward
	PUSH	numsSum
	PUSH	OFFSET asciiStringReverse
	CALL	WriteVal

; Passes arguments to CalculateAverage procedure.
_calculateAverageBlock:
	PUSH	numsSum					
	PUSH	OFFSET numsAverage		
	CALL	CalculateAverage

; Displays a message, indicating the average, and the ASCII representation of the average.
_averageDisplay:
	CALL	CrLf
	mDisplayString OFFSET roundedAverageMessage
	PUSH	OFFSET asciiStringForward
	PUSH	numsAverage
	PUSH	OFFSET asciiStringReverse
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf

; Displays a goodbye message.
_goodbyeMessage:
	mDisplayString OFFSET goodbyeMessage
	Invoke ExitProcess,0

main ENDP


; ------------------------------------------------------------------
; name: Introduction
;
; Uses the macro mDispalyString to display the introduction and
;	program instructions to the user.
;
; Receives: OFFSET of each message to be passed to mDisplayString
;
; Returns: None
; ------------------------------------------------------------------
Introduction PROC USES EBP
	MOV		EBP, ESP

	mDisplayString [EBP + 12]
	CALL	CrLf
	mDisplayString [EBP + 8]
	CALL	CrLf
	RET		8
	
Introduction ENDP


; ------------------------------------------------------------------
; Name: ReadVal
;
; Preconditions: Variables should be PUSHED to this procedure to fill the 
;	pre/post-conditions for the Irvine Library Read/WriteString functions, in
;	the following order:
;		1. isInvalidNum - empty SDWORD that will hold 0 or 1 to identify
;			if the user entered input is invalid or not
;		2. Array Pointer (ESI) - points to OFFSET of userPrompt
;		3. OFFSET of a bufferArray - an empty array 
;		4. maxCharacters - a value set to SIZEOF bufferArray
;		5. OFFSET byteCount - an empty SDWORD to store the number of BYTEs the user inputted
;		6. OFFSET keyboardInput - an empty SDWORD to store the user input
;		7. Array Pointer (EDI) - points to empty index in receiving array
;
; Receives: Variables listed above. 
;
; Returns: 
; 1. isInvalidNum - either remains 0, or changed to 1 if an invalid input is detected. 
; 2. Numeric value (converted from inputted ASCII string), moved into empty array index,
;	pointed to by EDI.
; ------------------------------------------------------------------
ReadVal	PROC USES EBP EAX EBX ECX EDX EDI ESI
	MOV		EBP, ESP

_invokeGetString:
	; Arguments passed to mGetString: prompt, keyboardInput, maxCharacters, byteCount
	mGetString [EBP + 36], [EBP + 48], [EBP + 44], [EBP + 40]
	MOV		ESI, [EBP + 48]							; ESI = OFFSET keyboardInput
	MOV		ECX, [EBP + 40]							; ECX = OFFSET byteCount					
	MOV		EBX, MAXIMUM_LENGTH						; EBX = MAXIMUM_LENGTH

_firstValidation:	
	CMP		ECX, 0									; Evaluates if byteCount == 0 (this means the string is empty)
	JE		_invalidNum
	CMP		ECX, EBX								; Evaluates if byteCount (i.e. length of input) > MAXIMUM_LENGTH

; ------------------------------------------------------------------
; The convertASCIItoNumeric LOOP, loops through the ASCII string inputted
;	by the user. For each character in the string, the character is converted
;	to its numeric value, and validated as being between number 0-9.
; Direction flag is cleared to traverse the ASCII string array "forward", and
;	EAX, EBX, and EDX are set to 0.
; EDX holds the running total while the function iterates through the ASCII string.
;	EBX holds 0 or 1 to indicate if the string is negative or not. If, at the end of 
;	the loop, EBX == 1, the value in EDX (the numeric value) is negated.
; If an invalid number is detected, invalidNum is set to 1, and the function returns
;	to main to reprompt the user to enter a number. This invalid number is not added
;	to the array, and is not counted towards the overlying loop.
; ------------------------------------------------------------------
	CLD
	MOV		EAX, 0
	MOV		EBX, 0
	MOV		EDX, 0
_convertASCIItoNumeric:
	LODSB
	CMP		AL, 45									; Evaluates if the first character is "-"
	JE		_negativeInput
	CMP		AL, 43									; Evaluates if first character is "+"
	JE		_positiveSign
	SUB		AL, 48
	CMP		AL, 9									; Each individual character should == numbers between 0-9
	JG		_invalidNum
	CMP		AL, 0
	JL		_invalidNum
	IMUL	EDX, 10									; Multiplies the running total by 10
	ADD		EDX, EAX
	LOOP	_convertASCIItoNumeric
	JMP		_isNegativeTrue

_negativeInput:
	CMP		EBX, 1
	JE		_invalidNum
	MOV		EBX, 1									; Moves 1 to EBX to indicate a negative value

_positiveSign:
	LOOP	_convertASCIItoNumeric

_isNegativeTrue:
	CMP		EBX, 1
	JNE		_endReadLoop
	NEG		EDX

_endReadLoop:
	MOV		EDI, [EBP + 32]
	MOV		[EDI], EDX								; [EBP + 32] == EDI; Numeric value is moved to EDI
	JMP		_returnToMain

_invalidNum:
	MOV		EAX, 1
	MOV		EDI, [EBP + 52]
	MOV		[EDI], EAX								; [EBP + 56] == isInvalidNum; Moves 1 into isInvalidNum

_returnToMain:
	RET		24

ReadVal	ENDP


; ------------------------------------------------------------------
; Name: CalculateSum
;
; Calculates the sum of all integers in the numericValuesArray.
;
; Preconditions: an array of integers must be present, and the integers
;	must be numeric instead of their initial ASCII representation.
;
; Receives: 
; 1. OFFSET of array to be summed
; 2. Value equal to the length of the array to be summed
; 3. OFFSET of receiving variable for storing the result
;
; Returns: The sum of all integers in a given array - in numeric form.
; ------------------------------------------------------------------
CalculateSum PROC USES EBP EDI EAX EBX ECX
	MOV		EBP, ESP

; ------------------------------------------------------------------
; sumLoop initializes the first value of the array into EBX and the length
;	of the array into ECX (the counter). Each iteration, the loop increments
;	the array pointer by 4 (1 SDWORD), and adds the current array value to
;	the previous array value. This loop iterates through the length of
;	the list. Thus, adding each value in the list to the running total.
; Finally, the value in EBX (the total sum), is moved into the memory address
;	containing the variable numsSum.
; ------------------------------------------------------------------
	MOV		EDI, [EBP + 32]							; EDI = OFFSET numericValuesArray
	MOV		ECX, [EBP + 28]							; ECX = len(NumericValuesArray)
	DEC		ECX
	MOV		EBX, [EDI]								; EBX = first value of numericValuesArray
_sumLoop:
	ADD		EDI, 4
	ADD		EBX, [EDI]
	LOOP	_sumLoop

_endSumLoop:
	MOV		EDI, [EBP + 24]
	MOV		[EDI], EBX								; Moves total sum into memory address holding numsSum
	RET		12

CalculateSum ENDP


; ------------------------------------------------------------------
; Name: CalculateAverage
;
; Calculates the average of the 10 numbers in numericValuesArray.
;
; Preconditions: numsSum must be calculated already, and in numeric form.
;
; Receives: 
; 1. Value in numsSum
; 2. OFFSET of address where numsAverage will be stored
;
; Returns: The average of the numbers in a predetermined array - in numeric form.
; ------------------------------------------------------------------
CalculateAverage PROC USES EBP EDI EAX EBX EDX
	MOV		EBP, ESP

	MOV		EBX, 10
	MOV		EAX, [EBP + 28]							; EAX = numsSum
	CDQ
	IDIV	EBX
	MOV		EDI, [EBP + 24]							; EDI = OFFSET numsAverage, EAX is now holding the average
	MOV		[EDI], EAX
	RET		8

CalculateAverage ENDP


; ------------------------------------------------------------------
; Name: WriteVal
;
; Takes a numeric value, converts it to the ASCII representation of that
;	number, and prints it to the console.
;
; Preconditions: The input should be a numeric value, and two empty strings.
;
; Receives:
; 1. OFFSET address to empty string 1 - will temporarily hold "reverse" ASCII
;	representation
; 2. OFFSET address to empty string 2 - will temporarily hold "forward" ASCII
;	representation
; 3. Numeric Value
;
; Returns: None - prints the ASCII representation of the numeric argument to 
;	the console.
; ------------------------------------------------------------------
WriteVal PROC USES EBP EDI ESI EAX EBX ECX EDX
	MOV		EBP, ESP

; ------------------------------------------------------------------
; The initial step in this procedure will be to establish the numeric 
;	value being converted to ASCII, and where the ASCII character will
;	go. 
; Then the EFLAGs register will be PUSHed to hold the negative status of the original 
;	number. The number is compared to 0 to establish if it is a negative number. 
; If the sign flag is set, _isNegative runs. This step increments EDI and EDX.
;	Incrementing EDI will allow the program to save a space at the beginning of the empty
;	string for a negative sign, and the count (ECX) should increment to include the negative
;	sign in the eventual storing process.
; Finally, the numeric value is negated to allow the conversion process to continue with the
;	non-negative integer. The sign flag is affected by the negation, which is why the flags
;	register was PUSHed prior to this step.
; ------------------------------------------------------------------

	MOV		EAX, [EBP + 36]							; EAX = numericValue
	MOV		EDI, [EBP + 32]							; EDI = asciiStringReverse
	MOV		ECX, 0
	CMP		EAX, 0
	PUSHFD
	JS		_isNegative
	JMP		_writeValLoopForward

_isNegative:
	INC		EDI
	INC		ECX
	NEG		EAX

; ------------------------------------------------------------------
; writeValLoopForward first evaluates if the number is a single digit already
;	(i.e. this number in the array is any number, 0-9). If this is the case,
;	48 is added to the digit to generate the ASCII decimal that corresponds with that
;	digit - this is stored in AL. STOSB is called to place the BYTE in AL into the 
;	memory address held in EDI (asciiStringReverse). Beacause AL is used as the 
;	accumulator for STOSB, for each iteration, EAX is PUSH/POPed when the BYTE has 
;	to be stored - this is to preserve the overarching value in EAX that will continue 
;	to be divided by 10.
; If the digit is not already between 0-9, it is divided by 10. The remainder of
;	this is the rightmost digit of the numeric representation of the value (e.g.
;	109/10 == R9, 9 being the rightmost number in "109"). This division process
;	continues until the remaining value in EAX is <= 9. This final value is the
;	leftmost number in the whole value.
; Each time a BYTE is stored in asciiStringReverse, ECX is incremented.
; ------------------------------------------------------------------
_writeValLoopForward:
	CMP		EAX, 9
	JLE		_endWriteValLoopForward
	MOV		EDX, 0
	MOV		EBX, 10
	CDQ
	IDIV	EBX
	ADD		EDX, 48									; ADD 48 to yield decimal that == ASCII char
	PUSH	EAX
	MOV		AL, DL
	STOSB
	INC		ECX
	POP		EAX										
	JMP		_writeValLoopForward					

_endWriteValLoopForward:
	ADD		AL, 48
	STOSB
	INC		ECX
	DEC		EDI										; EDI is decremented at this point because STOSB incremented it to the next EMPTY slot.
	INC		ECX
	MOV		ESI, EDI								; ESI = EDI (last character in asciiStringReverse)
	MOV		EDI, [EBP + 40]							; EDI = OFFSET asciiStringForward
	POPFD
	JS		_writeNegativeFirst
	JMP		_writeValLoopReverse

; ------------------------------------------------------------------
; When the ASCII conversion is complete, and all characters reside in
;	asciiStringReverse, the digits are being held in the reverse of the
;	final ASCII representation (e.g. if the program starts with 109, at
;	this point asciiStringReverse will be holding "901").
; In order to ameliorate this, asciiStringReverse has to be iterated through
;	in reverse, while asciiStringForward is appended "forward". The address
;	of the last value in asciiStringReverse has been placed in ESI, and the
;	EFLAGs register has been POPed to assess the initial negative status of
;	the number. If the sign flag is set, a negative sign is the first character
;	stored in asciiStringForward. 
; The writeValLoopReverse LOOPs as many times as ECX was incremented (this is
;	equivalent to how many BYTEs were stored in asciiStringReverse. Each iteration
;	the direction flag is first set in order to load the next index in the reversed
;	string, then the direction flag is cleared to store the next index in the forward
;	string. 
; Finally, the resulting ASCII string is passed as an argument to mDisplayString, and
;	the two string inputs are set to 0.
; ------------------------------------------------------------------
_writeNegativeFirst:
	MOV		AL, 45										; 45 = decimal equivalent to ASCII "-"
	STOSB
	DEC		ECX

_writeValLoopReverse:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_writeValLoopReverse

_writeValEndLoop:
	MOV		EDI, [EBP + 40]								
	MOV		EBX, EDI									; EBX = OFFSET asciiStringForward
	mDisplayString	EBX
	MOV		EAX, 0
	MOV		[EDI], EAX									; asciiStringForward = 0
	MOV		EDI, [EBP + 32]
	MOV		[EDI], EAX									; asciiStringReverse = 0

	RET		12

WriteVal ENDP

END main
