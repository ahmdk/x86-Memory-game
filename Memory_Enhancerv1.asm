#make_COM#
include emu8086.inc

;PLEASE MAXIMIZE THE ASSEMBLER WINDOW 
;TO BETTER VIEW THE CODE
; COM file is loaded at CS:0100h
ORG 100h


PRINTN ' '
PRINTN 'Welcome to Memory Enhancer V1.0'	;messages displayed to the user
PRINTN 'Written by Ahmed Khalifa'
PRINTN ''

PRINTN 'Press a key from 1 to 5 to listen to different tones'
PRINTN 'Press 6 to start playing'
PRINTN ''

call Practice						;procedure that ends when the user presses 6

mov DI, 7000
mov BX, 0
mov DX, 0

Start: 	call GetRandomNumber		;generate a randon number from 1 to 5
	MOV [DI], AL					;store it into memory
	INC DI
	INC BX
	call Play						;playing a tone based on the random number generated
	
	mov CX, BX
	MOV BP, DI
	SUB BP, BX
	
check:	call GetKey					;get user response
	CMP [BP], AL					;compare it with what is stored in memory
	JNE EXIT
	INC BP
	loop check						;loop as many times as the number of tones stored in memory
	
	INC DX
	call PlaySequence				;play the sequence of tones the user has entered so far
	JMP Start


Exit:	MOV AX, DX
	LEA DX, exit_message1			;Exit messages
	call WriteMessageToScreen
	
	call print_num					;print the number of tones the user has remembered
	
	LEA DX, exit_message2
	call WriteMessageToScreen
	PRINTN ''
	PRINTN ''
	
	LEA DX, exit_message3
	call WriteMessageToScreen
	PRINTN ''
	
	LEA DX, exit_message4
	call WriteMessageToScreen
	PRINTN ''


RET


;******************************************

Delay proc
		
		PUSH CX
		mov CX, 0FFFFh		;number of times the outer loop will have
		
	outer:	PUSH CX
		mov CX, 4000		;number of times the inner loop will have
				
	
	inner:	nop				;wasting time (delaying)
		loop inner
		
		POP CX	
		loop outer
		
		POP CX
		
RET

Delay ENDP	

;******************************************

TurnSpeakerOn	proc

		PUSH AX
		
		In al, 61h			;read current state of port 61h
		Or al, 3			;set B0 and B1 to logic 1
		Out 61h, al			;write to port
		
		POP AX

RET

TurnSpeakerOn ENDP

;******************************************

GenerateTone	PROC
	
		PUSH AX
			
		Mov al, 0b6h		;select counter 2, mode 3 binary counting
		Out 43h, al			;output control word to counter/timer
		Mov al, cl			;output lower byte of counter value
		Out 42h, al
		Mov al, ch			;output upper byte of counter value
		Out 42h, al
			
		POP AX
RET

GenerateTone	ENDP

;******************************************

TurnSpeakerOff	proc	
	
		PUSH AX
				
		In al, 61h		;read current state of port 61h
		And al, 0fch	;set B0 and B1 to logic 0
		Out 61h, al		;write to port
		
		POP AX

RET

TurnSpeakerOff ENDP

;******************************************

GetKey proc
		Mov AH, 08		;INT21 Function 08H: keyboard input without echo
		Int 21h
		Sub AL, '0'		;ASCII representation is stored in AL. Subtract the ASCII of 0 to get the value
		mov AH, 00
Ret

GetKey ENDP
	
;******************************************

Practice Proc
	
	again:	call GetKey	;get user input
		CMP AL, 6		;check if it is not equal to 6
		JE Exit1	
	
		MOV CL, AL		;map user input to a valid array index (1 2 3 4 5 --->0 2 4 6 8)
		dec CL		
		mov AL, 2	
		mul CL		

		mov SI, AX
		mov CX, tones [SI]	;load a certain divisor from the tones array (see below) based on user input
	
	
		call TurnSpeakerOn
		call GenerateTone
		call Delay
		call TurnSpeakerOff
	
	
		JMP again

	Exit1:	RET	

Practice ENDP

;******************************************

GetRandomNumber proc

		PUSH CX
		PUSH DX
		
		mov AH, 2CH		;INT21 function 2CH: get time
		int 21H
	
		mov AL, DL		;DL will contain any value between 0 and 99
		mov AH, 00
		mov CL, 20
		div CL			;divide the value in DL by 20 to get an integer between 0 and 4
		mov AH,00		;ignore the remainder
		add AL, 1		;add 1 to the result to get a random number from 1 to 5
		
		POP DX
		POP CX
	
RET

GetRandomNumber ENDP

;******************************************

Play Proc

		PUSH CX
	
		MOV CL, AL			;mapping from [1 2 3 4 5] to [0 2 4 6 8]
		dec CL
		PUSH AX
		mov AL, 2
		mul CL
	
		mov SI, AX
		mov CX, tones [SI]	;loading a tone divisor value
		
		
		call TurnSpeakerOn	;play it
		call GenerateTone
		call Delay
		call TurnSpeakerOff
		
		
		POP AX
		POP CX

RET	

Play ENDP

;******************************************

PlaySequence Proc

		PUSH AX
		PUSH CX
		
		MOV BP, DI
		MOV CX, BX
		SUB BP, BX
	
	again2:	MOV AL, [BP]		;reads the values stored in momory
		CALL play				;and plays the corresponding tones
		INC BP
		loop again2
		
		POP CX
		POP AX

RET	

PlaySequence ENDP

;******************************************

WriteMessageToScreen proc
	
		PUSH AX
		Mov ah, 9			
		Int 21h				;INT21 function 09H: Display a string. the pointer to 
							;the string should be in DS:DX
		POP AX
ret
				
WriteMessageToScreen endp

;******************************************


Tones DW 3967, 1323, 0992, 0567, 0441		;array storing divisor values (1.19M / divisor = tone frequency)

exit_message1 DB 'Your memory is ', '$'		;messages to be displayed to the user
exit_message2 DB ' tones strong', '$'
exit_message3 DB 'Thank you for using Memory Enhancer V1.0', '$'
exit_message4 DB 'Good bye', '$'


define_print_num
define_print_num_uns

END