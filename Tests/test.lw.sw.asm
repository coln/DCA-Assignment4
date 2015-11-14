; Test LW/SW

lui $1, 0x4000     ; Load address
ori $30, $0, 0     ; Let it propagate through the pipeline
ori $30, $0, 0
ori $30, $0, 0
ori $30, $0, 0
ori $1, $1, 0x0804

lui $2, 0x1234     ; Load some data
ori $30, $0, 0     ; Let it propagate through the pipeline
ori $30, $0, 0
ori $30, $0, 0
ori $30, $0, 0
ori $2, $2, 0xABCD
ori $30, $0, 0     ; Let it propagate through the pipeline
ori $30, $0, 0
ori $30, $0, 0
ori $30, $0, 0

sw $2, 0($1)     ; mem[0] = 0x12345678
sw $2, 4($1)     ; mem[4] = 0x12345678
lw $3, 0($1)     ; $3 = 0x12345678
lw $4, 1($1)     ; $3 = 0x34567812
lbu $5, 4($1)    ; $3 = 0x00000012


sh $2, 6($1)     ; mem[6] = 0x56FA
lhu $3, 6($1)    ; $3 = 0x000056FA

lw $4, 0($1)         ; $4 = 0x123456FA
lw $4, -1($1)        ; $4 = 0x00123456
lw $4, -2($1)        ; $4 = 0x00001234
lw $4, -3($1)        ; $4 = 0x00000012
lw $4, -4($1)        ; $4 = 0x00000000

