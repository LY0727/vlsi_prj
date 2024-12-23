; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x000003FC							; 1K Internal Memory
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0 
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		BTN_Handler
        				DCD		TIMER_Handler
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
                
				LDR     R1, =0xE000E100         ;Interrupt Set Enable Register
                LDR     R0, =0x00000003           
                STR     R0, [R1]

				LDR 	R1, =0x50000000			; Reset LED
				MOVS	R0,#0
				STR		R0,[R1]
				;Configure the timer
				
				LDR 	R1, =0x52000000	     	;timer load value register
				LDR 	R0, =0x00001388   	    ;=50,000,000 (system tick frequency)//0x02faf080
				STR		R0,	[R1]			
				LDR 	R1, =0x52000008		    ;timer control register
				MOVS	R0, #0x07			    ;prescaler=1, enable timer, reload mode
				STR		R0,	[R1]
	
AGAIN			B AGAIN
				ENDP
					
BTN_Handler PROC
              	PUSH {LR}
				POP{PC}
			ENDP
TIMER_Handler  PROC
                PUSH    {R0,R1,LR}
				LDR 	R0, =0x50000000
				MOVS	R1, #0x1	
				STR		R1,[R0]             ; send to led
				
                LDR		R2, =0xF				;Delay
Loop			SUBS	R2,R2,#1
				BNE Loop

				LDR 	R0, =0x50000000
				MOVS	R1, #0x0	
				STR		R1,[R0]             ; send to led
 			   POP     {R0,R1,PC}
	    ENDP
		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
   