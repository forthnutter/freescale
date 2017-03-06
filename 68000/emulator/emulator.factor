! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
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


! memory is a memory model
! alu is Arithmatic Logic Unit
! ar is a set of address registers
! dr is a set of data registes
! reset is model to run all things that need to reset
TUPLE: cpu < memory alu ar dr pc rx cycles cashe copcode opcodes state reset exception ;

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

! increment PC+2
: PC+ ( cpu -- )
  [ PC> 2 + ] keep >PC ;

! increment PC+4
: PC++ ( cpu -- )
  [ PC+ ] keep PC+ ;

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

! returns array of words
: cpu-pc-read-array ( n cpu -- array )
    [ 0 swap 2 <range> >array ] dip
    [ [ PC> + ] curry map ] keep
    [ cpu-read-word ] curry map ;


: extract-opcode ( instruct -- opcode )
    15 12 bit-range 4 bits ;

: destination-register ( instruct -- regnum )
    11 9 bit-range 3 bits ;

: destination-mode ( instruct -- mode )
    8 6 bit-range 3 bits ;

: source-register ( instruct -- regnum )
    2 0 bit-range 3 bits ;

: source-mode ( instruct -- mode )
    5 3 bit-range 3 bits ;

! generates a 6 bit mode value
: move-mode ( instruct -- mode )
  8 3 bit-range 6 bits ;

: cpu-absolute-data-long ( cpu -- l )
  [ cashe>> second ] keep
  cashe>> third words-long ;

: cpu-absolute-data-word ( cpu -- w )
  cashe>> second ;


: cpu-read-dregister ( d cpu -- n )
  swap
  {
    { 0 [ D0> ] }
    { 1 [ D1> ] }
    { 2 [ D2> ] }
    { 3 [ D3> ] }
    { 4 [ D4> ] }
    { 5 [ D5> ] }
    { 6 [ D6> ] }
    { 7 [ D7> ] }
    [ drop drop f ]
  } case ;

: cpu-write-dregister ( d reg cpu -- )
  swap
  {
    { 0 [ >D0 ] }
    { 1 [ >D1 ] }
    { 2 [ >D2 ] }
    { 3 [ >D3 ] }
    { 4 [ >D4 ] }
    { 5 [ >D5 ] }
    { 6 [ >D6 ] }
    { 7 [ >D7 ] }
    [ drop drop drop ]
  } case ;

: cpu-absolute-data-address ( d cpu -- n )
  swap
  {
    { 0 [ [ cpu-absolute-data-word ] keep PC++ ] }
    { 1 [ [ cpu-absolute-data-long ] keep [ PC++ ] keep PC+ ] }
    [ drop drop f ]
  } case ;


: cpu-wb-dreg-mem ( cpu -- )
  [ cashe>> first source-register ] keep
  [ cpu-read-dregister ] keep
  [ cashe>> first destination-register ] keep
  [ cpu-absolute-data-address ] keep
  cpu-write-byte drop ;

: cpu-move-effective-address ( mode cpu -- )
  swap
  {
    { 0  [ drop ] }
    { 1  [ drop ] }
    { 56 [ cpu-wb-dreg-mem ] }
    [ drop drop ]
  } case ;


: cpu-read-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ drop ]} ! Status register
    [ drop drop ]
  } case ;

: cpu-write-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    [ drop drop drop drop ]
  } case ;

: ori-ea-mode ( d -- mode )
  5 3 bit-range 3 bits ;

: ori-ea-reg ( d -- reg )
  2 0 bit-range 3 bits ;

: cpu-ori-byte-data ( cpu -- )
  [ cashe>> second 8 bits ] keep
  [ cashe>> first ori-ea-reg ] keep
  [ cashe>> first ori-ea-mode ] keep
  [ cpu-read-ea ] keep
  [ bitor ] dip
  [ cashe>> first ori-ea-reg ] keep
  [ cashe>> first ori-ea-mode ] keep
  [ cpu-write-ea ] keep
  PC++ ;


: cpu-ori-word-data ( cpu -- )
  [ cashe>> second 16 bits ] keep
  [ cashe>> first ori-ea-reg ] keep
  [ cashe>> first ori-ea-mode ] keep
  [ cpu-read-ea ] keep
  [ bitor ] dip
  [ cashe>> first ori-ea-reg ] keep
  [ cashe>> first ori-ea-mode ] keep
  [ cpu-write-ea ] keep
  PC++ ;

: cpu-ori ( cpu -- )
  [ cashe>> first 7 6 bit-range 2 bits ] keep swap ! size
  {
    { 0 [ cpu-ori-byte-data ] }     ! Byte
    { 1 [ cpu-ori-word-data ] }     ! word
    { 2 [ drop ] }     ! long
    [ drop drop ]
  } case ;


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
  break
  [ cashe>> first 11 8 bit-range 4 bits ] keep swap
  {
    { 0 [ cpu-ori ] }  ! ORI
    [ drop drop ]
  } case ;



! Move Byte
: (opcode-1) ( cpu -- )
  [ cashe>> first move-mode ] keep
  cpu-move-effective-address ;

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



! reset models
: cpu-reset-models ( cpu -- cpu )
    [ f ] dip [ reset>> set-model ] keep
    [ t ] dip [ reset>> set-model ] keep ;

: reset-exception ( cpu -- )
    [ alu>> alu-s-set ] keep
    [ alu>> alu-t-clr ] keep
    [ alu>> 7 swap alu-imask-write ] keep
    [ 0 ] dip [ cpu-read-long ] keep [ >A7? ] keep
    [ 4 ] dip [ cpu-read-long ] keep [ >PC? ] keep
    cpu-reset-models
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
    [ 6 swap cpu-pc-read-array ] keep [ cashe<< ] keep [ cashe>> first ] keep
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


! here we process exception
: cpu-exception-execute ( cpu -- )
    dup exception>> drop drop ;

! Execute one cycles
: execute-cycle ( cpu -- )
    [ dup cpu-ready? ]
    [
        dup cpu-state
        {
            { CPU-RESET [ dup reset-exception ] }   ! do reset cycle
            { CPU-UNKNOWN [ dup reset ] }
            { CPU-RUNNING [ dup execute-pc-opcode ] }
            [ drop CPU-UNKNOWN >>state ]
        } case
    ] until drop ;

! Reset Process
: cpu-power ( reset cpu -- )
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
  [ f swap cpu-power ] keep
  16 [ not-implemented ] <array> >>opcodes
  [ opcode-build ] keep
    f <model> >>reset ;
