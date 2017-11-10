ARR         .BYT   '0' ;0
            .BYT   '0'
            .BYT   '0'
            .BYT   '0'
            .BYT   '0'
            .BYT   '0'
            .BYT   '0' ;6
SIZE        .INT    7  ;7
TENTH       .INT    0  ;11
DATA        .INT    0  ;15
OPDV        .INT    0  ;19
CNT         .INT    0  ;23
FLAG        .INT    0  ;27
ZERO        .INT    0
ONE         .INT    1
C0          .BYT    '0'  ;39
C1          .BYT    '1'
C2          .BYT    '2'
C3          .BYT    '3'
C4          .BYT    '4'
C5          .BYT    '5'
C6          .BYT    '6'
C7          .BYT    '7'
C8          .BYT    '8'
C9          .BYT    '9'
N           .BYT   'N'
u           .BYT   'u'
m           .BYT   'm'
b           .BYT   'b'
e           .BYT   'e'
r           .BYT   'r'
i           .BYT   'i'
s           .BYT   's'
t           .BYT   't'
o           .BYT   'o'
g           .BYT   'g'
O           .BYT   'O'
p           .BYT   'p'
a           .BYT   'a'
n           .BYT   'n'
d           .BYT   'd'
AT          .BYT   '@'
PLUS        .BYT   '+'
MINUS       .BYT   '-'
SPACE       .BYT   'space'
NL          .BYT   '\n'

;RESET
    ; Test for overflow (SP <  SL)
                MOV    	R5  SP
                ADI	    R5  -24	; Adjust for space needed (Rtn Address & PFP)
                CMP     R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function reset(int w, int x, int y, int z)
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
                SUB     R4  R4  ; Set R4 to 0
                ADI     R4  1
                STR	    R4  SP  ; Place 1 on the Stack
                ADI	    SP  -4
                SUB     R4  R4  ; Set R4 to 0
                STR	    R4  SP	; Place 0 on the Stack
                ADI	    SP  -4
                STR 	R4  SP	; Place 0 on the Stack
                ADI 	SP  -4
                STR	    R4  SP	; Place 0 on the Stack
                ADI	    SP  -4
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	    R4  36	; Compute Return Address (always a fixed amount)
                STR     R4  FP  ; Return Address to the Beginning of the Frame; Call function
                JMP     RESET	; Call Function

;GETDATA
    ; Test for overflow (SP <  SL)
                MOV    	R5  SP
                ADI	    R5  -8	; Adjust for space needed (Rtn Address & PFP)
                CMP 	R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function GETDAT()
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	    R4  36	; Compute Return Address (always a fixed amount)
                STR	    R4  FP  ; Return Address to the Beginning of the Frame
                JMP	    GETDATA	; Call Function
1M_WHILE        LDA     R0  ARR
                LDB     R0  R0
                LDB     R1  AT
                CMP     R1  R0
                BRZ     R1  1M_END_WHILE
                LDB     R5  PLUS
                CMP     R5  R0
                BRZ     R5  1M_IF
                LDB     R5  MINUS
                CMP     R5  R0
                BRZ     R5  1M_IF
                JMP     1M_ELSE

;GETDATA //Get most significant byte
    ; Test for overflow (SP <  SL)
1M_IF           MOV    	R5  SP
                ADI	    R5  -8	; Adjust for space needed (Rtn Address & PFP)
                CMP 	R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function GETDATA()
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	    R4  36	; Compute Return Address (always a fixed amount)
                STR 	R4  FP  ; Return Address to the Beginning of the Frame
                JMP	    GETDATA	; Call Function
                JMP     2M_WHILE
1M_ELSE         LDA     R1  ARR
                SUB     R2  R2
                ADI     R2  1
                ADD     R1  R2      ; R1 = ARR[1]
                LDA     R4  ARR     ; R4 = ARR[0]
                LDB     R4  R4
                STB     R4  R1
                LDB     R1  PLUS    ; R1 = '+'
                LDA     R4  ARR     ; R4 = ARR[0]
                STB     R1  R4
                LDR     R4  CNT
                ADI     R4  1
                STR     R4  CNT
2M_WHILE        LDR     R1  DATA
                BRZ     R1  2M_END_WHILE
2M_IF           LDR     R4  CNT
                ADI     R4  -1
                LDA     R5  ARR
                ADD     R5  R4
                LDB     R5  R5
                LDB     R6  NL
                CMP     R6  R5
                BNZ     R6  2M_ELSE
                SUB     R1  R1
                STR     R1  DATA
                ADI     R1  1
                STR     R1  TENTH
                LDR     R1  CNT
                ADI     R1  -2
                STR     R1  CNT
3M_WHILE        LDR     R2  FLAG
                BNZ     R2  3M_IF
                LDR     R4  CNT    ; R4 = CNT
                BRZ     R4  3M_IF
               ; CMP     R4  R2     ; IF (R4 == R2)
               ; BRZ     R4  2M_ELSE
;OPD
    ; Test for overflow (SP <  SL)
                MOV    	R5  SP
                ADI	    R5  -20	; Adjust for space needed (Rtn Address & PFP)
                CMP     R5  SL	    ; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function reset(int w, int x, int y, int z)
                MOV 	R4  FP	    ; Save FP in R4, this will be the PFP
                MOV 	FP  SP	    ; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	    ; Adjust Stack Pointer for Return Address
                STR	    R4  SP	    ; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	    ; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
                LDB     R4  ARR     ; Load ARR[0] to R4
                STR	    R4  SP      ; Place ARR[0] on the Stack
                ADI	    SP  -4      ; Move SP
                LDR     R4  TENTH   ; Set R4 to TENTH
                STR	    R4  SP	    ; Place TENTH on the Stack
                ADI	    SP  -4      ; Move SP
                LDA     R4  ARR     ; Load ARR[0] to R4
                LDR     R5  CNT     ; Load CNT to R5
                ADD     R4  R5      ; Load ARR[CNT] into R4
                LDB     R4  R4
                STR	    R4  SP	    ; Place ARR[CNT] on the Stack
                ADI	    SP  -4      ; Move SP
    ; Set return address
                MOV 	R4  PC	    ; PC incremented by 1 instruction
                ADI	    R4  36	    ; Compute Return Address (always a fixed amount)
                STR	    R4  FP      ; Return Address to the Beginning of the Frame
    ; Call function
                JMP	    OPD	        ; Call Function
                LDR     R1  CNT
                ADI     R1  -1
                STR     R1  CNT
                SUB     R2  R2
                ADI     R2  10
                LDR     R1  TENTH
                MUL     R1  R2
                STR     R1  TENTH
                JMP     3M_WHILE
3M_IF           LDR     R1  FLAG
                BNZ     R1  2M_WHILE
                LDB     R3  O
                TRP     3
                LDB     R3  p
                TRP     3
                LDB     R3  e
                TRP     3
                LDB     R3  r
                TRP     3
                LDB     R3  a
                TRP     3
                LDB     R3  n
                TRP     3
                LDB     R3  d
                TRP     3
                LDB     R3  SPACE
                TRP     3
                LDB     R3  i
                TRP     3
                LDB     R3  s
                TRP     3
                LDB     R3  SPACE
                TRP     3
                LDR     R3  OPDV
                TRP     1
                LDB     R3  NL
                TRP     3
                JMP     2M_END_WHILE
;GETDATA
    ; Test for overflow (SP <  SL)
2M_ELSE         MOV    	R5  SP
                ADI	    R5  -8	; Adjust for space needed (Rtn Address & PFP)
                CMP 	R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function GETDATA()
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	    R4  36	; Compute Return Address (always a fixed amount)
                STR	    R4  FP  ; Return Address to the Beginning of the Frame
                JMP	    GETDATA	; Call Function
                JMP     2M_WHILE

;RESET
    ; Test for overflow (SP <  SL)
2M_END_WHILE    MOV    	R5  SP
                ADI	    R5  -24	; Adjust for space needed (Rtn Address & PFP)
                CMP     R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function reset(int w, int x, int y, int z)
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
                SUB     R4  R4  ; Set R4 to 0
                ADI     R4  1
                STR	    R4  SP  ; Place 1 on the Stack
                ADI	    SP  -4
                SUB     R4  R4  ; Set R4 to 0
                STR	    R4  SP	; Place 0 on the Stack
                ADI	    SP  -4
                STR 	R4  SP	; Place 0 on the Stack
                ADI 	SP  -4
                STR	    R4  SP	; Place 0 on the Stack
                ADI	    SP  -4
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	R4  36	; Compute Return Address (always a fixed amount)
                STR	R4  FP  ; Return Address to the Beginning of the Frame
    ; Call function
                JMP	RESET	; Call Function
;GETDATA
    ; Test for overflow (SP <  SL)
                MOV    	R5  SP
                ADI	    R5  -8	; Adjust for space needed (Rtn Address & PFP)
                CMP 	    R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
                BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function GETDAT()
                MOV 	R4  FP	; Save FP in R4, this will be the PFP
                MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
                ADI	    SP  -4	; Adjust Stack Pointer for Return Address
                STR	    R4  SP	; PFP to Top of Stack 			(PFP = FP)
                ADI	    SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
    ; Set return address
                MOV 	R4  PC	; PC incremented by 1 instruction
                ADI	    R4  36	; Compute Return Address (always a fixed amount)
                STR	    R4  FP  ; Return Address to the Beginning of the Frame
                JMP	    GETDATA	; Call Function
                JMP     1M_WHILE
1M_END_WHILE    TRP   0

;GETDATA DECLARATION
    ; Test for overflow (SP <  SL)
    ; Put local variable on the stack
GETDATA   LDR   R4  CNT
          LDR   R5  SIZE
          CMP   R4  R5
          BLT   R4  GD_IF
          JMP   GD_ELSE
GD_IF     LDA   R0  ARR
          LDR   R1  CNT
          ADD   R0  R1
          TRP   4
          STB   R3  R0
          ADI   R1  1
          STR   R1  CNT
          JMP   GD_ENDIF
GD_ELSE   LDB     R3  N
          TRP     3
          LDB     R3  u
          TRP     3
          LDB     R3  m
          TRP     3
          LDB     R3  b
          TRP     3
          LDB     R3  e
          TRP     3
          LDB     R3  r
          TRP     3
          LDB     R3  SPACE
          TRP     3
          LDB     R3  t
          TRP     3
          LDB     R3  o
          TRP     3
          TRP     3
          LDB     R3  SPACE
          TRP     3
          LDB     R3  b
          TRP     3
          LDB     R3  i
          TRP     3
          LDB     R3  g
          TRP     3
          LDB     R3  NL
          TRP     3
;FLUSH
    ; Test for overflow (SP <  SL)
          MOV    	R5  SP
          ADI	    R5  -8	; Adjust for space needed (Rtn Address & PFP)
          CMP 	    R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
          BLT	    R5  OVERFLOW

    ; Create Activation Record and invoke function FLUSH()
          MOV 	R4  FP	; Save FP in R4, this will be the PFP
          MOV 	FP  SP	; Point at Current Activation Record 	(FP = SP)
          ADI	SP  -4	; Adjust Stack Pointer for Return Address
          STR	R4  SP	; PFP to Top of Stack 			(PFP = FP)
          ADI	SP  -4	; Adjust Stack Pointer for PFP

    ; Passed Parameters onto the Stack (Pass by Value)
    ; Set return address
          MOV 	R4  PC	; PC incremented by 1 instruction
          ADI	R4  36	; Compute Return Address (always a fixed amount)
          STR	R4  FP  ; Return Address to the Beginning of the Frame
          JMP	FLUSH	; Call Function
    ; Test for Underflow (SP > SB)
GD_ENDIF    MOV  	SP  FP	  ; De-allocate Current Activation Record 	(SP = FP)
            MOV 	R5  SP
            CMP 	R5  SB	  ; 0 (SP=SB), Pos (SP > SB), Neg (SP < SB)
            BGT	    R5  UNDERFLOW

    ; Set Previous Frame to Current Frame and Return
            LDR 	R5  FP	   ; Return Address Pointed to by FP
            MOV     R0  FP
            ADI     R0  -4
            LDR     FP  R0     ; Point at Previous Activation Record 	(FP = PFP)
            JMR	    R5	       ; Jump to Return Address in Register R5

;FLUSH DECLARATION
    ; Test for overflow of local variables(SP <  SL)
    ; Put local variable on the stack
FLUSH       SUB     R4  R4
            STR     R4  DATA
            LDA     R0  ARR
            TRP     4            ;TRAP 4
            STB     R3  ARR

FLUSH_WHILE LDB     R0  ARR
            LDB     R1  NL
            CMP     R0  R1

            BRZ     R0  END_FLUSH_WHILE
            TRP     4
            STB     R3  ARR
            JMP     FLUSH_WHILE
    ; Test for Underflow (SP > SB)
END_FLUSH_WHILE MOV  	SP  FP	  ; De-allocate Current Activation Record 	(SP = FP)
                MOV 	R5  SP
                CMP 	R5  SB	  ; 0 (SP=SB), Pos (SP > SB), Neg (SP < SB)
                BGT	    R5  UNDERFLOW

    ; Set Previous Frame to Current Frame and Return
            LDR 	R5  FP	   ; Return Address Pointed to by FP
            MOV     R0  FP
            ADI     R0  -4
            LDR     FP  R0   ; Point at Previous Activation Record 	(FP = PFP)
            JMR	    R5	       ; Jump to Return Address in Register R5

;RESET DECLARATION
    ; Test for overflow (SP <  SL)
RESET       MOV     R5  SP  ; check for stack overflow for local variable k
            ADI     R5  -4
            CMP 	R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
            BLT	    R5  OVERFLOW
    ; Put local variable on the stack
            SUB     R5  R5
            STR	    R5  SP	; Place K initialized to 0 on the Stack
            ADI	    SP  -4
    ; Initialize ARR
            LDA     R0  ARR
            LDR     R1  SIZE
            MOV     R2  FP
            ADI     R2  -24 ; local variable k address
            LDR     R4   R2 ; local var k value
    ; For loop
 R_FOR      CMP     R1   R4
            BRZ     R1   R_FOR_END
            SUB     R5   R5
            STB     R5   R0 ; set ARR[k] = 0
            ADI     R4   1  ; increment k
            ADI     R0   1  ; increment ARR pointer
            STR     R4   R2
            JMP     R_FOR
 R_FOR_END  MOV     R0   FP
            ADI     R0   -8
            LDR     R1   R0     ; R1 = w (1)
            STR     R1   DATA
            MOV     R0   FP
            ADI     R0   -12
            LDR     R1   R0     ; R1 = x (0)
            STR     R1   OPDV
            MOV     R0   FP
            ADI     R0   -16
            LDR     R1   R0     ; R1 = y (0)
            STR     R1   CNT
            MOV     R0   FP
            ADI     R0   -20
            LDR     R1   R0     ; R1 = z (0)
            STR     R1   FLAG

    ; Test for Underflow (SP > SB)
            MOV  	SP  FP	  ; De-allocate Current Activation Record 	(SP = FP)
            MOV 	R5  SP
            CMP 	R5  SB	  ; 0 (SP=SB), Pos (SP > SB), Neg (SP < SB)
            BGT	    R5  UNDERFLOW

    ; Set Previous Frame to Current Frame and Return
            LDR 	R5  FP	   ; Return Address Pointed to by FP
            MOV     R0  FP
            ADI     R0  -4
            LDR     FP  R0   ; Point at Previous Activation Record 	(FP = PFP)
            JMR	    R5	       ; Jump to Return Address in Register R5

;OPD DECLARATION
    ; Test for overflow (SP <  SL)
OPD         MOV     R5  SP  ; check for stack overflow for local variable k
            ADI     R5  -4
            CMP 	R5  SL	; 0 (SP=SL), Pos (SP > SL), Neg (SP < SL)
            BLT	    R5  OVERFLOW
    ; Put local variable on the stack
            SUB     R5  R5
            STR	    R5  SP	; Place T initialized to 0 on the Stack
            ADI	    SP  -4
    ;if/else statements
            SUB     R7  R7     ;Integer value to store
            MOV     R0  FP
            ADI     R0  -16
IF0_OPD     LDB     R2  R0
            LDB     R1  C0
            CMP     R2  R1
            BNZ     R2  IF1_OPD
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF1_OPD     LDB     R2  R0
            LDB     R1  C1
            CMP     R2  R1
            BNZ     R2  IF2_OPD
            ADI     R7  1
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF2_OPD     LDB     R2  R0
            LDB     R1  C2
            CMP     R2  R1
            BNZ     R2  IF3_OPD
            ADI     R7  2
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF3_OPD     LDB     R2  R0
            LDB     R1  C3
            CMP     R2  R1
            BNZ     R2  IF4_OPD
            ADI     R7  3
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF4_OPD     LDB     R2  R0
            LDB     R1  C4
            CMP     R2  R1
            BNZ     R2  IF5_OPD
            ADI     R7  4
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF5_OPD     LDB     R2  R0
            LDB     R1  C5
            CMP     R2  R1
            BNZ     R2  IF6_OPD
            ADI     R7  5
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF6_OPD     LDB     R2  R0
            LDB     R1  C6
            CMP     R2  R1
            BNZ     R2  IF7_OPD
            ADI     R7  6
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF7_OPD     LDB     R2  R0
            LDB     R1  C7
            CMP     R2  R1
            BNZ     R2  IF8_OPD
            ADI     R7  7
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF8_OPD     LDB     R2  R0
            LDB     R1  C8
            CMP     R2  R1
            BNZ     R2  IF9_OPD
            ADI     R7  8
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
IF9_OPD     LDB     R2  R0
            LDB     R1  C9
            CMP     R2  R1
            BNZ     R2  OPD_NOT_NUM
            ADI     R7  9
            MOV     R6  FP
            ADI     R6  -20
            STR     R7  R6
            JMP     OPD_LAST_IF
OPD_NOT_NUM LDB     R3  R0
            TRP     3
            LDB     R3  SPACE
            TRP     3
            LDB     R3  i
            TRP     3
            LDB     R3  s
            TRP     3
            LDB     R3  SPACE
            TRP     3
            LDB     R3  n
            TRP     3
            LDB     R3  o
            TRP     3
            LDB     R3  t
            TRP     3
            LDB     R3  SPACE
            TRP     3
            LDB     R3  a
            TRP     3
            LDB     R3  SPACE
            TRP     3
            LDB     R3  n
            TRP     3
            LDB     R3  u
            TRP     3
            LDB     R3  m
            TRP     3
            LDB     R3  b
            TRP     3
            LDB     R3  e
            TRP     3
            LDB     R3  r
            TRP     3
            LDB     R3  NL
            TRP     3
            ADI     R7  1
            STR     R7  FLAG
            JMP     OPD_RETURN
    ;OPD_LAST_IF statement
OPD_LAST_IF LDR     R7  FLAG
            BNZ     R7  OPD_RETURN
            MOV     R0  FP
            ADI     R0  -8     ; R0 = s
            LDR     R0  R0
            MOV     R1  FP
            ADI     R1  -12     ; R1 = k
            LDR     R1  R1
            MOV     R2  FP
            ADI     R2  -20     ; R2 = t
            LDR     R2  R2
            LDB     R4  PLUS
            CMP     R0  R4
            BNZ     R0  OPDFIN_ELSE
            MUL     R2  R1      ; t *= k
            JMP     ADD_OPDV
OPDFIN_ELSE SUB     R6  R6
            ADI     R6  -1
            MUL     R1  R6      ; k *= -1
            MUL     R2  R1      ; t *= k
ADD_OPDV    LDR     R4  OPDV    ; R4 = OPDV
            ADD     R4  R2      ; OPDV += t
            STR     R4  OPDV
    ; Test for Underflow (SP > SB)
OPD_RETURN  MOV  	SP  FP	  ; De-allocate Current Activation Record 	(SP = FP)
            MOV 	R5  SP
            CMP 	R5  SB	  ; 0 (SP=SB), Pos (SP > SB), Neg (SP < SB)
            BGT	    R5  UNDERFLOW

    ; Set Previous Frame to Current Frame and Return
            LDR 	R5  FP	   ; Return Address Pointed to by FP
            MOV     R0  FP
            ADI     R0  -4
            LDR     FP  R0   ; Point at Previous Activation Record 	(FP = PFP)
            JMR	    R5	       ; Jump to Return Address in Register R5

;OVERFLOW DECLARATION
OVERFLOW    SUB R3 R3
            ADI R3 9
            TRP 1
            TRP 0

; UNDERFLOW DECLARATION
UNDERFLOW   SUB R3 R3
            ADI R3 8
            TRP 1
            TRP 0