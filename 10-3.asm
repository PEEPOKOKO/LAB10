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
        
        SETB  P3.2          
        SETB  P3.3          
        SETB  P3.4          
        SETB  P3.5          

MAIN_LOOP:
        JNB   P3.2, SEND_0  
        JNB   P3.3, SEND_1  
        JNB   P3.4, SEND_2  
        JNB   P3.5, SEND_3  

        JNB   RI, MAIN_LOOP 
        MOV   A, SBUF       
        CLR   RI            

        MOV   R0, A         
        CLR   C
        SUBB  A, #30H       
        JC    MAIN_LOOP     
        MOV   A, R0
        CLR   C
        SUBB  A, #3AH       
        JNC   MAIN_LOOP     

        MOV   A, R0
        ANL   A, #0FH       
        CALL  DISPLAY
        SJMP  MAIN_LOOP

SEND_0: 
        MOV   A, #'0'
        CALL  TX_DATA
        SJMP  MAIN_LOOP
SEND_1: 
        MOV   A, #'1'
        CALL  TX_DATA
        SJMP  MAIN_LOOP
SEND_2: 
        MOV   A, #'2'
        CALL  TX_DATA
        SJMP  MAIN_LOOP
SEND_3: 
        MOV   A, #'3'
        CALL  TX_DATA
        SJMP  MAIN_LOOP

TX_DATA:
        MOV   SBUF, A       
        JNB   TI, $         
        CLR   TI            
        RET

DISPLAY:
        MOV   DPTR, #SEG_TAB
        MOVC  A, @A+DPTR
        CPL   A             
        MOV   P2, A         
        CLR   P1.4          
        CLR   P1.5
        RET

SEG_TAB:
        DB    3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH

        END