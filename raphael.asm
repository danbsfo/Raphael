; IU Robotics Club
; Created : 30 July 2003
; Modified: 30 July 2003
; Author  : Daniel Bulwinkle
;
; Robot   : Raphael
;
; The task of the robot is to roam around without hitting walls
; or other objects it detects with its IR sensor. The program
; waits for a signal drop from the IR output line signifying
; that an object is inches in front of the robot. The robot
; then manuevers backward and turns for a period and then
; proceeds forward.
;

#DEFINE PAGE0 BCF $03,5
#DEFINE PAGE1 BSF $03,5

OPTION: .EQU $01
STATUS: .EQU $03
PORTA:  .EQU $05
PORTB:  .EQU $06
TRISA:  .EQU $05
TRISB:  .EQU $06
INTCON: .EQU $0B
F:      .EQU 1

CLKCNT: .EQU $0D        ; clock division counter

        .ORG 4
        .ORG 5

        clrf PORTA	; clear the ports
        clrf PORTB
	PAGE1
	movlw %00000001 ; A0 as input
        movwf TRISA     ; make sure A is input 
        clrf TRISB	; set as output
	movlw %00000110	; set timer ratio 1:128
        movwf OPTION
        PAGE0
STRT:	movlw 25	; set CLKCNT to 35
	movwf CLKCNT
	bcf INTCON,2	; clear time-out flag
	bsf PORTB,4	; turn on the left LED
	bcf PORTB,5	; turn off right LED
INTRPT: btfss INTCON,2	; timer cycle over?
	goto INTRPT	; if no, wait until it is
	bcf INTCON,2	; if yes, clear the flag
	btfsc PORTB,4	; is the right LED on?
	goto LEDON	; if yes, turn off 
	bsf PORTB,4	; if no, turn on
	bcf PORTB,5	; turn off the left LED
	goto LEDOFF
LEDON:	bsf PORTB,5	; turn on the left LED
	bcf PORTB,4	; turn off the right LED
LEDOFF:	btfss PORTA,0	; IR Detect anything?
	goto DANGER	; if not, continue
	bsf PORTB,0	; forward
	bsf PORTB,2	;
	bcf PORTB,1	; forward
	bcf PORTB,3	;
	goto INTRPT	; go to interrupt
DANGER:
	bcf PORTB,0	; reverse to get boost of energy
	bcf PORTB,2	;
	bsf PORTB,1
	bsf PORTB,3
BOOST:  btfss INTCON,2	; timer cycle over?
	goto BOOST	; if no, wait until it is
	bcf INTCON,2	; if yes, clear the flag
	decfsz CLKCNT,F	; dec counter, zero?
	goto BOOST	; if no, wait til it is
	movlw 55
	movwf CLKCNT
BACKUP:	btfss INTCON,2	; timer cycle over?
	goto BACKUP	; if no, wait until it does
	bcf INTCON,2	; if yes, clear flag
	btfss PORTB,4	; right LED on?
	goto LFTLED	; if not, led LED is on
	bsf PORTB,1	; turn back and right 
	bcf PORTB,3	; 
	bcf PORTB,0	;
	bcf PORTB,2	;
	goto RGTLED	
LFTLED:	bcf PORTB,1	; turn back and left 
	bsf PORTB,3	; 
	bcf PORTB,0	;
	bcf PORTB,2	;
RGTLED:	decfsz CLKCNT,F	; dec counter, is it zero?
	goto BACKUP	; if no, wait until it is
	goto STRT	; if yes, go forward again
	
	.END
