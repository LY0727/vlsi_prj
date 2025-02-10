;------------------------------------------------------------------------------------------------------
; Project1:Reset and LED waterfall light
;------------------------------------------------------------------------------------------------------



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

;------------------------------------Loop0---------------------------------------
AGAIN		   	LDR 	R1, =0x50000000				;Write to LED with value 0x01
				LDR		R0, =0x01
				STR		R0, [R1]
				LDR		R2, =0x2					;Use R2 to store delay time number
Loop0			SUBS	R2,R2,#1
				BNE Loop0

;------------------------------------Loop1---------------------------------------
				LDR 	R1, =0x50000000				;Write to LED with value 0x03
				LDR		R0, =0x03
				STR		R0, [R1]
				LDR		R2, =0x2
Loop1			SUBS	R2,R2,#1
				BNE Loop1

;------------------------------------Loop2---------------------------------------
				LDR 	R1, =0x50000000				;Write to LED with value 0x07
				LDR		R0, =0x07
				STR		R0, [R1]
				LDR		R2, =0x2
Loop2			SUBS	R2,R2,#1
				BNE Loop2
				
;------------------------------------Loop3---------------------------------------				
				LDR 	R1, =0x50000000				;Write to LED with value 0x0F
				LDR		R0, =0x0F
				STR		R0, [R1]				
				LDR		R2, =0x2
Loop3			SUBS	R2,R2,#1
				BNE Loop3

;------------------------------------Loop4---------------------------------------
				LDR 	R1, =0x50000000				;Write to LED with value 0x1F
				LDR		R0, =0x1F
				STR		R0, [R1]
				LDR		R2, =0x2
Loop4			SUBS	R2,R2,#1
				BNE Loop4
				
;------------------------------------Loop5---------------------------------------				
				LDR 	R1, =0x50000000				;Write to LED with value 0x3F
				LDR		R0, =0x3F
				STR		R0, [R1]
				LDR		R2, =0x2
Loop5			SUBS	R2,R2,#1
				BNE Loop5				
				
;------------------------------------Loop6---------------------------------------				
				LDR 	R1, =0x50000000				;Write to LED with value 0x7F
				LDR		R0, =0x7F
				STR		R0, [R1]
				LDR		R2, =0x2
Loop6			SUBS	R2,R2,#1
				BNE Loop6				
				
;------------------------------------Loop7---------------------------------------				
				LDR 	R1, =0x50000000				;Write to LED with value 0xFF
				LDR		R0, =0xFF
				STR		R0, [R1]
				LDR		R2, =0x2
Loop7			SUBS	R2,R2,#1
				BNE Loop7				
				
				B AGAIN
				ENDP

				ALIGN 		4						; Align to a word boundary

END