T2CON   EQU   0C8H
RCAP2L  EQU   0CAH
RCAP2H  EQU   0CBH

        ORG   0000H
        LJMP  START

        ORG   0100H
START:
        MOV   SP, #3FH
        CLR   EA
        MOV   TMOD, #20H 
        MOV   SCON, #50H
        MOV   TH1, #0FDH
        SETB  TR1
        MOV   R1, #0      
        MOV   R2, #0      

MAIN_LOOP:
        CLR   RI
        JNB   RI, $
        MOV   A, SBUF     
        MOV   R0, A       

        MOV   A, R0
        CLR   C
        SUBB  A, #31H     
        JC    CHECK_ZERO
        MOV   A, R0
        CLR   C
        SUBB  A, #3AH     
        JNC   CHECK_PLUS

        MOV   A, R0
        ANL   A, #0FH     
        MOV   R3, A       
BLINK_LOOP:
        CLR   P3.7        
        CALL  DELAY
        SETB  P3.7        
        CALL  DELAY
        DJNZ  R3, BLINK_LOOP
        SJMP  SHOW_NUM

CHECK_ZERO:
        MOV   A, R0
        CJNE  A, #'0', CHECK_PLUS
        MOV   R1, #0      
        SJMP  PROCESS_COUNT

CHECK_PLUS:
        CJNE  A, #'+', CHECK_MINUS
        MOV   R1, #1      
        SJMP  PROCESS_COUNT

CHECK_MINUS:
        CJNE  A, #'-', CHECK_ETC
        MOV   R1, #2      
        SJMP  PROCESS_COUNT

CHECK_ETC:
        SETB  P3.2        
        MOV   A, #16      
        CALL  DISPLAY
        SJMP  MAIN_LOOP

PROCESS_COUNT:
        CJNE  R1, #1, TRY_DOWN
        INC   R2
        MOV   A, R2
        CJNE  A, #10, SHOW_NUM
        MOV   R2, #0      
        SJMP  SHOW_NUM
TRY_DOWN:
        CJNE  R1, #2, SHOW_NUM 
        DEC   R2
        MOV   A, R2
        CJNE  A, #0FFH, SHOW_NUM
        MOV   R2, #9      

SHOW_NUM:
        MOV   A, R2       
        CALL  DISPLAY
        SJMP  MAIN_LOOP

DISPLAY:
        MOV   DPTR, #SEG_TAB
        MOVC  A, @A+DPTR
        CPL   A           
        MOV   P2, A
        CLR   P1.4        
        CLR   P1.5
        RET

DELAY:
        MOV   R6, #200
D1:     MOV   R7, #255
        DJNZ  R7, $
        DJNZ  R6, D1
        RET

SEG_TAB:
        DB    3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H  
        DB    7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 71H  
        DB    40H                                     

        END