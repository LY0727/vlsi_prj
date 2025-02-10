;------------------------------------------------------------------------------------------------------
; Project2: 7 Segment display
;------------------------------------------------------------------------------------------------------

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
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY

;------------------------------------Begin---------------------------------------
		MOVS	R2,#0x4			;R2 = cyc num, need 4 cycle
AGAIN0	LDR		R1,=0x51000000
		LDR 	R4,=1			;First code = 1
AGAIN1	STR		R4,[R1]			;STORE "1-2-3-4"
		ADDS	R4,R4,#9		;cyc1--Second code = 1+9 = A, cyc2--4th code = 2+9 = B, cyc3--6th code = 3+9 = C, cyc4--8th code = 4+9 = D
			
		LDR		R0,=0x2			;Delay
Loop0	SUBS 	R0,R0,#1
		BNE		Loop0

		STR		R4,[R1]			;STORE "A-B-C-D"
		SUBS	R4,R4,#8		;cyc1--Third code = A-8 = 2, cyc2--5th code = B-8 = 3, cyc3--7th code = C-8 = 4

		LDR		R0,=0x2			;Delay
Loop1	SUBS 	R0,R0,#1
		BNE		Loop1
		
		SUBS	R2,#0x01		;jump to AGAIN1 to begin cyc2, jump to AGAIN1 to begin cyc3, jump to AGAIN1 to begin cyc4


		BNE AGAIN1
		BNE AGAIN0
		ENDP
		 
END  