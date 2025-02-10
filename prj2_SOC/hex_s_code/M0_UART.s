;------------------------------------------------------------------------------------------------------
; Project4:use UART to output code
;------------------------------------------------------------------------------------------------------



; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x0000FFFC
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


;------------------------------------begin---------------------------------------
				LDR 	R1, =0x53000000
				MOVS	R0, #0x01
				STR		R0, [R1]		;send 0x0000_0001

				LDR 	R1, =0x53000000
				MOVS	R0, #0x02
				STR		R0, [R1]		;send 0x0000_0010

				LDR 	R1, =0x53000000
				MOVS	R0, #0x04
				STR		R0, [R1]		;send 0x0000_0100
				
				LDR 	R1, =0x53000000
				MOVS	R0, #0x08
				STR		R0, [R1]		;send 0x0000_1000
				
	            LDR 	R1, =0x53000000
				MOVS	R0, #0x10
				STR		R0, [R1]		;send 0x0001_0000

				LDR 	R1, =0x53000000
				MOVS	R0, #0x20
				STR		R0, [R1]		;send 0x0010_0000

				LDR 	R1, =0x53000000
				MOVS	R0, #0x40
				STR		R0, [R1]		;send 0x0100_0000
				
				LDR 	R1, =0x53000000
				MOVS	R0, #0x80
				STR		R0, [R1]		;send 0x1000_0000
				

;wait until receive buffer is not empty

WAIT			LDR 	R1, =0x53000004
				LDR		R0, [R1]
				MOVS	R1, #01
				ANDS	R0, R0, R1
				CMP		R0,	#0x00
				BNE		WAIT		

;print received text to UART

				LDR 	R1, =0x53000000
				LDR 	R0, [R1]
				STR		R0, [R1]
				B		WAIT

			ENDP
			ALIGN 		4					 ; Align to a word boundary

END