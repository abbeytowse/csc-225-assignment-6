; Defines functions for computing greatest common divisors.
; CSC 225, Assignment 6
; Given code, Spring '21

            .ORIG x4000

; int gcd(int, int)
GCDFN       ; Callee setup:
            ADD R6, R6, #-1`    ; push space for the return value 
            ADD R6, R6, #-1     ; push the return address 
            STR R7, R6, #0  
            
            ADD R6, R6, #-1     ; push the dynamic link (the caller's R5) 
            STR R5, R6, #0 
            
            ADD R5, R6, #-1     ; set R5, frame pointer, to point to the first local 
            ADD R6, R6, #-1     ; push space for "tmp" 

            ; Retrieve "a" and "b" from the stack...
            LDR R1, R5, #4      ; Load "a" into R1 
            LDR R2, R5, #5      ; Load "b" into R2 
            
            NOT R3, R2          ; make b a negative 
            ADD R3, R3, #1
            
            ADD R3, R1, R3      ; a - b 
            ; if (a == b) {
            BRnp NOTEQUAL
            ;   tmp = a;
                STR R1, R5, #0 
                BRnzp DONE 
            ; }
            ; else if (a < b) {
NOTEQUAL    BRzp NOTNEG
            ;     Caller setup:
                LDR R0, R5, #4  ; get "a"
                NOT R1, R0      ; negate "a"
                ADD R1, R1, #1 
                
                LDR R2, R5, #5  ; get "b"
                ADD R1, R2, R1  ; "b - a"
                ADD R6, R6, #-1 ; increment the stack 
                STR R1, R6, #0  ; push "b" aka "b - a" 
                ADD R6, R6, #-1 ; increment the stack 
                STR R0, R6, #0  ; push "a"
            ;     tmp = gcd(a, b - a);
                JSR GCDFN
                STR R1, R5, #0  ; store the previous calls return value as the local variable 
            ;     Caller teardown:
                LDR R1, R6, #0  ; pop the return value 
                ADD R6, R6, #1 
                
                ADD R6, R6, #1  ; pop "a"
                ADD R6, R6, #1  ; pop "b"
            ; }
            ; else {
NOTNEG      BRnz DONE
            ;     Caller setup...
                LDR R0, R5, #4  ; get "a"
                LDR R2, R5, #5  ; get "b"
                ADD R6, R6, #-1 ; push "b"
                STR R2, R6, #0 
                
                NOT R1, R2      ; negate "b"
                ADD R1, R1, #1 
                
                ADD R1, R0, R1  ; "a - b"
                ADD R6, R6, #-1 ; increment the stack 
                STR R1, R6, #0  ; push "a" aka "a - b" 
            ;     tmp = gcd(a -b, b);
                JSR GCDFN 
                STR R1, R5, #0  ; store the previous calls return value as the local variable 
            ;     Caller teardown:
                LDR R1, R6, #0  ; pop the return value 
                ADD R6, R6, #1 

                ADD R6, R6, #1  ; pop "a"
                ADD R6, R6, #1  ; pop "b"
                
            ; }

            ; Callee teardown:
DONE        LDR R0, R5, #0      ; load "tmp" into R0 
            STR R0, R5, #3      ; set the return value to "tmp"
            ADD R6, R6, #1      ; pop "tmp"
            
            LDR R5, R6, #0      ; pop the dynamic link into R5  
            ADD R6, R6, #1 
            
            LDR R7, R6, #0      ; pop the return address into R7 
            ADD R6, R6, #1 
            
            RET                 ; return 

            .END
