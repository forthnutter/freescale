! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise
    freescale.68000.emulator.alu 
    models models.memory ascii ;


IN: freescale.68000.emulator


CONSTANT: CPU-RESET 0
CONSTANT: CPU-RUNNING 1
CONSTANT: CPU-READY 2
CONSTANT: ACCESS-FAULT 8
CONSTANT: ADDRESS-ERROR 12
CONSTANT: ILLEGAL-INSTRUCTION 16
CONSTANT: CPU-UNKNOWN 32



TUPLE: cpu < memory alu ar dr pc rx cycles copcode opcodes state ;

: cpu-exception ( excep cpu -- )
    state<< ;

: >PC ( d cpu -- )
    pc<< ;

! test data before putting value into PC
: >PC? ( d cpu -- )
    swap
    dup f = swap dup t = swap [ or ] dip swap
    [
        drop ADDRESS-ERROR >>state drop
    ] [ swap >PC ] if ;    
    
: PC> ( cpu -- d )
    pc>> ;

! write to user sp
: >USP ( d cpu -- )
   ar>> 7 swap set-nth ;

! read the user sp
: USP> ( cpu -- d )
  ar>> 7 swap nth ;

! get user sp
! : USR> ( cpu -- d )
!   ar>> 7 swap nth ;

! write to supervisor sp
: >SSP ( d cpu -- )
   ar>> 8 swap set-nth ;

! read supervisor sp
: SSP> ( cpu -- d )
  ar>> 8 swap nth ;

! put value into A7
: >A7 ( d cpu -- )
    [ alu>> alu-mode? ] keep swap
    [ >SSP ] [ >USP ] if ;

! test data before putting value into A7
: >A7? ( d cpu -- )
    swap
    dup f = swap dup t = swap [ or ] dip swap
    [
        drop ADDRESS-ERROR >>state drop
    ] [ swap >A7 ] if ;
        
    
! get A7
: A7> ( cpu -- d )
  [ alu>> alu-mode? ] keep swap
  [ SSP> ] [ USP> ] if ;


! increment A7
: A7+ ( cpu -- )
  [ A7> 1 + ] keep >A7 ;

! decrement A7
: A7- ( cpu -- )
  [ A7> 1 - ] keep >A7 ;



: >A6 ( d cpu -- )
  ar>> 6 swap set-nth ;

: A6> ( cpu -- d )
  ar>> 6 swap nth ;

: >A5 ( d cpu -- )
  ar>> 5 swap set-nth ;

: A5> ( cpu -- d )
  ar>> 5 swap nth ;

: >A4 ( d cpu -- )
  ar>> 4 swap set-nth ;

: A4> ( cpu -- d )
  ar>> 4 swap nth ;

: >A3 ( d cpu -- )
  ar>> 3 swap set-nth ;

: A3> ( cpu -- d )
  ar>> 3 swap nth ;

: >A2 ( d cpu -- )
  ar>> 2 swap set-nth ;

: A2> ( cpu -- d )
  ar>> 2 swap nth ;

: >A1 ( d cpu -- )
  ar>> 1 swap set-nth ;

: A1> ( cpu -- d )
  ar>> 1 swap nth ;

: >A0 ( d cpu -- )
  ar>> 0 swap set-nth ;

: A0> ( cpu -- d )
  ar>> 0 swap nth ;

: >D7 ( d cpu -- )
  dr>> 6 swap set-nth ;

: D7> ( cpu -- d )
  dr>> 6 swap nth ;

: >D6 ( d cpu -- )
  dr>> 6 swap set-nth ;

: D6> ( cpu -- d )
  dr>> 6 swap nth ;

: >D5 ( d cpu -- )
  dr>> 5 swap set-nth ;

: D5> ( cpu -- d )
  dr>> 5 swap nth ;

: >D4 ( d cpu -- )
  dr>> 4 swap set-nth ;

: D4> ( cpu -- d )
  dr>> 4 swap nth ;

: >D3 ( d cpu -- )
  dr>> 3 swap set-nth ;

: D3> ( cpu -- d )
  dr>> 3 swap nth ;

: >D2 ( d cpu -- )
  dr>> 2 swap set-nth ;

: D2> ( cpu -- d )
  dr>> 2 swap nth ;

: >D1 ( d cpu -- )
  dr>> 1 swap set-nth ;

: D1> ( cpu -- d )
  dr>> 1 swap nth ;

: >D0 ( d cpu -- )
  dr>> 0 swap set-nth ;

: D0> ( cpu -- d )
  dr>> 0 swap nth ;

! split a word value to bytes
: word-bytes ( w -- a b )
    [ 15 8 bit-range ] keep 7 0 bit-range ;

! join two bytes into word
: bytes-word ( a b -- w )
    [ 8 bits 8 shift ] dip 8 bits bitor ;

! join two words into long
: words-long ( wh wl -- l )
    [ 16 bits 16 shift ] dip 16 bits bitor ;


! split a long into 4 bytes
: long-bytes ( l -- a b c d )
    [ 31 16 bit-range word-bytes ] keep
    15 0 bit-range word-bytes ;

! split long into words
: long-words ( l -- wh wl )
    [ 31 16 bit-range ] keep
    15 0 bit-range ;

: cpu-write-byte ( d address cpu -- ? )
    [ 1byte-array ] 2dip
    memory-write ;

! write word to memory
: cpu-write-word ( d address cpu -- ? )
    [ word-bytes 2byte-array ] 2dip
    memory-write ;


! write long to memory
: cpu-write-long ( dddd address cpu -- ? )
    [ long-bytes 4byte-array ] 2dip
    memory-write ;


: bytes>number ( seq -- number )
    0 [ [ 8 shift ] dip bitor ] reduce ;

: cpu-read-byte ( address cpu -- d )
    [ 1 ] 2dip memory-read bytes>number ;

: cpu-read-word ( address cpu -- d )
    [ 2 ] 2dip memory-read bytes>number ;

: cpu-read-long ( address cpu -- d )
    [ 4 ] 2dip memory-read bytes>number ;

: cpu-pc-read ( cpu -- d )
    [ PC> ] keep cpu-read-word ;
 

 : extract-opcode ( instruct -- opcode )
    15 12 bit-range 4 bits ;
    
    
! extract destination mode

! the opcodes are divide into 16
! opcode 0 Bit Manipulation MOVEP Immediate
! ADDI ANDI
! BCHG BCLR BSET BTST
! CALLM CAS CAS2 CHK2 CMPI CMP2
! EORI
! MOVEP
! ORI
! RTM
! SUBI
: (opcode-0) ( cpu -- )
  drop ;


! Move Byte
: (opcode-1) ( cpu -- )
  drop ;

! Move Long MOVE MOVEA
: (opcode-2) ( cpu -- )
  drop ;

! Move word MOVE MOVEA
: (opcode-3) ( cpu -- )
  drop ;

! Miscellaneous
! CHK CLR
! EXT EXTB
! ILLEGAL
! JMP JSR
! LEA LINK
! MOVEM
! NBCD NEG NEGX NOP NOT
! PACK PEA
! RTD RTR RTS
! SWAP
! TAS TRAP TRAPV TST
! UNLK
: (opcode-4) ( cpu -- )
  drop ;

! ADDQ
! DBcc
! SUBQ SUBX Scc
! TRAPcc
: (opcode-5) ( cpu -- )
  drop ;

! Bcc BSR BRA
: (opcode-6) ( cpu -- )
  drop ;

! MOVEQ
: (opcode-7) ( cpu -- )
  drop ;

! DIV DIVS DIVL DIVU DIVUL
! OR
! SBCD
! UNPK
: (opcode-8) ( cpu -- )
  drop ;

! SUB SUBA SUBX
: (opcode-9) ( cpu -- )
  drop ;

! Reserved
: (opcode-A) ( cpu -- )
  drop ;

! CMP CMPA CMPM
! EOR
: (opcode-B) ( cpu -- )
  drop ;

! AND ABCD EXG MUL MULS MULU
: (opcode-C) ( cpu -- )
  drop ;

! ADD ADDA ADDX
: (opcode-D) ( cpu -- )
  drop ;

! Shift Rotate Bit Field
! ASR
! BFCHG BFCLR BFEXTS BFEXTU BFFFO BFINS BFSET BFTST BKPT
! LSL LSR
! ROL ROR ROXL ROXR
: (opcode-E) ( cpu -- )
  drop ;

! Coprocessor Interface
! cpBcc cpDBcc cpGEN cpScc cpTRAPcc
! MOVE16
: (opcode-F) ( cpu -- )
  drop ;

! temp opcode 
: not-implemented ( cpu -- )
  drop ;

! generate the opcode array here
: opcode-build ( cpu -- )
    opcodes>> dup
    [
        [ drop ] dip
        [
            >hex >upper
            "(opcode-" swap append ")" append
            "freescale.68000.emulator" lookup-word 1quotation
        ] keep
        [ swap ] dip swap [ set-nth ] keep
    ] each-index drop ;
  
: reset-exception ( cpu -- )
    break
    [ alu>> alu-s-set ] keep
    [ alu>> alu-t-clr ] keep
    [ alu>> 7 swap alu-imask-write ] keep
    [ 0 ] dip [ cpu-read-long ] keep [ >A7? ] keep
    [ 4 ] dip [ cpu-read-long ] keep [ >PC? ] keep
    CPU-RUNNING >>state drop ;

: reset ( cpu -- )
    CPU-RESET >>state drop ;

: opcode-save ( opc cpu -- cpu )
    >>copcode ;

: opcode-read ( cpu -- opc cpu )
    [ copcode>> ] keep ;


! execute one instruction
: execute-pc-opcodes ( cpu -- )
!    [ rom-pc-read ] keep
!    [ opcodes>> nth [ break ] prepose ] keep swap call( cpu -- )
        drop
;

! Deep within the instruction is the opcode
! routine to extract


! execute one instruction
: execute-pc-opcode ( cpu -- )
    [ cpu-pc-read ] keep
    [ extract-opcode ] dip [ opcodes>> nth ] keep swap call( cpu -- )
;

! Execute to an address
: execute-address ( addr cpu -- )
!    [
 !       [ pc>> = ] 2keep rot ]
!        [ [ execute-pc-opcode ] keep
!    ] until
    2drop
;

! Get the cpu state
: cpu-state ( cpu -- state )
    state>> ;

! I want to know if we are in Ready to execute state
: cpu-ready? ( cpu -- ? )
    cpu-state CPU-READY = ;

! Execute one cycles
: execute-cycle ( cpu -- )
    [ cpu-ready? ]
    [
        [ cpu-state ] keep swap
        {
            { [ CPU-RESET [ reset-exception ] ] keep }   ! do reset cycle
            { [ CPU-UNKNOWN [ reset ] ] keep }
            { [ CPU-RUNNING [ execute-pc-opcode ] ] keep }
            [ drop CPU-UNKNOWN >>state ]
        } case
    ] until ;

! Reset Process
: power ( reset cpu -- )
    [ 0 swap >USP ] keep
    [ dr>> [ drop 0 ] map ] keep swap >>dr
    [ ar>> [ drop 0 ] map ] keep swap >>ar
    swap [ reset ] [ drop ] if ;



: <cpu> ( -- cpu )
  f cpu new-model
  <alu> >>alu
  8 f <array> >>dr
  9 f <array> >>ar
  [ alu>> 7 swap alu-imask-write ] keep
  [ alu>> alu-s-set ] keep
  [ f swap power ] keep 
  16 [ not-implemented ] <array> >>opcodes 
  [ opcode-build ] keep ;
  
  
  
