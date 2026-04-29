ORG 0000H
    LJMP START 

    ORG 0030H
START:
    MOV SCON, #50H 
    MOV TMOD, #20H
    MOV TH1, #0FDH
    SETB TR1
    
    MOV R7, #10
    
B_LOOP:
    MOV DPTR,#DATAB     
    LCALL SEND           
    LCALL DELAY_500MS
    DJNZ R7, B_LOOP
    
    MOV DPTR, #FINAL     
    LCALL SEND
    SJMP $

SEND:   
    CLR A
    MOVC A, @A+DPTR
    JZ EXIT_SEND
    MOV SBUF, A 
WAIT_TI:    
    JNB TI, WAIT_TI
    CLR TI
    INC DPTR
    SJMP SEND
EXIT_SEND:
    RET 

DELAY_500MS:
    MOV R2, #5
D1: MOV R1, #200
D2: MOV R0, #250
    DJNZ R0, $
    DJNZ R1, D2
    DJNZ R2, D1
    RET 
    
DATAB:   
    DB 'B6740269 Thanawut Phumakew', 0DH, 0AH, 0
FINAL:
    DB 'I WANT A', 0DH, 0AH, 0    
    END