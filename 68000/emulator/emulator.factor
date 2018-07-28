! Copyright (C) 2016 Joseph Moschini.  a.k.a. forthnutter
! See http://factorcode.org/license.txt for BSD license.
!
USING:
    accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise freescale.68000.emulator.exception
    freescale.68000.emulator.alu models ascii ;


IN: freescale.68000.emulator


CONSTANT: CPU-RESET 0
CONSTANT: CPU-RUNNING 1
CONSTANT: CPU-READY 2
CONSTANT: ACCESS-FAULT 8
CONSTANT: CPU-ADDRESS-ERROR 12
CONSTANT: ILLEGAL-INSTRUCTION 16
CONSTANT: CPU-UNKNOWN 32

! Table of number of bytes for each opcode
CONSTANT: nbytes-seq {
        1 2 3 1 1 2 1 1 1 1 1 1 1 1 1 1
        3 2 3 1 1 2 1 1 1 1 1 1 1 1 1 1
        3 2 1 1 2 2 1 1 1 1 1 1 1 1 1 1
        3 2 1 1 2 2 1 1 1 1 1 1 1 1 1 1
        2 2 2 3 2 2 1 1 1 1 1 1 1 1 1 1
        2 2 2 3 2 2 1 1 1 1 1 1 1 1 1 1
        2 2 2 3 3 3 1 1 1 1 1 1 1 1 1 1
        2 2 2 1 2 3 2 2 2 2 2 2 2 2 2 2
        2 2 2 1 1 3 2 2 2 2 2 2 2 2 2 2
        3 2 2 1 2 2 1 1 1 1 1 1 1 1 1 1
        2 2 2 1 1 1 2 2 2 2 2 2 2 2 2 2
        2 2 2 1 3 3 3 3 3 3 3 3 3 3 3 3
        2 2 2 1 1 2 1 1 1 1 1 1 1 1 1 1
        2 2 2 1 1 3 1 1 2 2 2 2 2 2 2 2
        1 2 1 1 1 2 1 1 1 1 1 1 1 1 1 1
        1 2 1 1 1 2 1 1 1 1 1 1 1 1 1 1
    }



! Generic functions read and write memory
GENERIC: read-bytes ( n address cpu -- seq )
GENERIC: write-bytes ( seq address cpu -- )

! cpu name of class
! alu is Arithmatic Logic Unit
! ar is a set of address registers
! dr is a set of data registes
! pc is the program counter
! rx
! cashe instrcution cashe
! opcode array of opcodes call
! state of cpu
! reset is model to run all things that need to reset
! exception
! doublefault
! stop
! trace
! halt
! sync
TUPLE: cpu alu ar dr pc rx cashe opcodes state
    reset exception doublefault stop trace halt sync ;






: cpu-exception ( excep cpu -- )
    drop drop ;

: >PC ( d cpu -- )
    pc<< ;

! test data before putting value into PC
: >PC? ( d cpu -- )
    swap
    dup f = swap dup t = swap [ or ] dip swap
    [
        drop CPU-ADDRESS-ERROR >>state drop
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
        drop CPU-ADDRESS-ERROR >>state drop
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

: SR> ( cpu -- d )
    alu>> alu-sr> ;

: >SR ( d cpu -- )
    alu>> >alu-sr ;


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

: cpu-write-byte ( d address cpu --  )
    [ 1byte-array ] 2dip
    write-bytes ;

! write word to memory
: cpu-write-word ( d address cpu --  )
    [ word-bytes 2byte-array ] 2dip
    write-bytes ;


! write long to memory
: cpu-write-long ( dddd address cpu --  )
    [ long-bytes 4byte-array ] 2dip
    write-bytes ;


: bytes>number ( seq -- number )
    0 [ [ 8 shift ] dip bitor ] reduce ;

: cpu-read-byte ( address cpu -- d )
    [ 1 ] 2dip read-bytes bytes>number ;

: cpu-read-word ( address cpu -- d )
    [ 2 ] 2dip read-bytes bytes>number ;

: cpu-read-long ( address cpu -- d )
    [ 4 ] 2dip read-bytes bytes>number ;

: cpu-pc-read ( cpu -- d )
    [ PC> ] keep cpu-read-word ;

! returns array of words
: cpu-pc-read-array ( n cpu -- array )
    [ 0 swap 2 <range> >array ] dip
    [ [ PC> + ] curry map ] keep
    [ cpu-read-word ] curry map ;


: extract-opcode ( instruct -- opcode )
    15 12 bit-range 4 bits ;

: move-dest-reg ( instruct -- regnum )
    11 9 bit-range 3 bits ;

: move-dest-mode ( instruct -- mode )
    8 6 bit-range 3 bits ;

: move-source-reg ( instruct -- regnum )
    2 0 bit-range 3 bits ;

: move-source-mode ( instruct -- mode )
    5 3 bit-range 3 bits ;

! generates a 6 bit mode value
: move-mode ( instruct -- mode )
  8 3 bit-range 6 bits ;


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




! get absolute word address read byte
: cpu-rb-aword ( cpu -- w )
  [ PC++ ] keep
  [ cashe>> second ] keep
  cpu-read-byte ;





: cpu-write-mode-one ( d reg cpu -- )
  swap
  {
    { 0 [ >A0 ] }
    { 1 [ >A1 ] }
    { 2 [ >A2 ] }
    { 3 [ >A3 ] }
    { 4 [ >A4 ] }
    { 5 [ >A5 ] }
    { 6 [ >A6 ] }
    { 7 [ >A7 ] }
    [ drop drop drop ]
  } case ;

: cpu-rb-along ( cpu -- b )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep
  [ cpu-read-byte ] keep
  PC+ ;

! read byte
: cpu-0-rb-seven ( reg cpu -- d )
    swap
    {
        { 0 [ cpu-rb-aword ] }   ! absolute word
        { 1 [ cpu-rb-along ] }    ! absolute long
        { 4 [ SR> ] }
        [ drop drop f ]
    } case ;


: cpu-0-rb-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister 8 bits ] }
    { 7 [ cpu-0-rb-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-wb-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ drop drop drop ] } ! cpu-wb-mode-seven ] }
    [ drop drop drop drop ]
  } case ;


: code0-ea-mode ( d -- mode )
  5 3 bit-range 3 bits ;

: code0-ea-reg ( d -- reg )
  2 0 bit-range 3 bits ;

: cpu-ori-byte-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 8 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rb-ea ] keep
  [ bitor ] dip
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-wb-ea ] keep
  PC+ ;

! read byte
: cpu-0-rw-mode-seven ( reg cpu -- d )
    swap
    {
        { 0 [ cpu-rb-aword ] }   ! absolute word
        { 1 [ cpu-rb-along ] }    ! absolute long
        { 4 [ SR> ] }
        [ drop drop f ]
    } case ;

! read word of the effective address
: cpu-0-rw-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ cpu-0-rw-mode-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-ww-mode-seven ( data reg cpu -- )
  swap
  {
    { 0 [ drop drop ] }
    { 1 [ drop drop ] } ! cpu-0-ww-along ] }
    { 4 [ >SR ] }
    [ drop drop drop ]
  } case ;



: cpu-0-ww-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-0-ww-mode-seven ] }
    [ drop drop drop drop ]
  } case ;



: cpu-ori-word-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 16 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rw-ea ] keep
  [ alu>> alu-or-word ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-ww-ea ] keep
  PC+ ;

! get the size from instruction
: cpu-size ( cpu -- size )
  cashe>> first 7 6 bit-range 2 bits ;


: cpu-ori ( cpu -- )
  [ cpu-size ] keep swap ! size
  {
    { 0 [ cpu-ori-byte-data ] }     ! Byte
    { 1 [ cpu-ori-word-data ] }     ! word
    { 2 [ drop ] }     ! long
    [ drop drop ]
  } case ;

! reset models
: cpu-reset-models ( cpu -- cpu )
    [ f ] dip [ reset>> set-model ] keep
    [ t ] dip [ reset>> set-model ] keep ;

: cpu-add-reset ( obj cpu -- cpu )
  [ reset>> add-connection ] keep ;


: cpu-andi-word-data ( cpu -- )
  [ cashe>> second 16 bits ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rw-ea ] keep
  [ bitor ] dip
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-ww-ea ] keep
  PC++ ;

! read word of the effective address
: cpu-0-rl-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ cpu-0-rw-mode-seven ] }
    [ drop drop ]
  } case ;

: cpu-0-wl-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-0-ww-mode-seven ] }
    [ drop drop drop drop ]
  } case ;



: cpu-andi-long-data ( cpu -- )
  [ PC+ ] keep
  [ cashe>> second 16 bits ] keep
  [ PC+ ] keep
  [ cashe>> third 16 bits ] keep
  [ words-long ] dip
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-rl-ea ] keep
  [ alu>> alu-and-long ] keep
  [ cashe>> first code0-ea-reg ] keep
  [ cashe>> first code0-ea-mode ] keep
  [ cpu-0-wl-ea ] keep
  PC+ ;

: cpu-andi ( cpu -- )
  [ cpu-size ] keep swap
  {
    { 0 [ drop ] }  ! byte
    { 1 [ drop ] }  ! word
    { 2 [ cpu-andi-long-data ] }  ! long
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
    { 2 [ cpu-andi ] } ! ANDI
    [ drop drop ]
  } case ;



: cpu-move-rb-mode-seven ( reg cpu -- d )
  swap
  {
    { 0 [ drop f ] }
    { 1 [ cpu-rb-along ] }
    [ drop drop f ]
  } case ;


: cpu-move-rb-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister 8 bits ] }
    { 7 [ cpu-move-rb-mode-seven ] }
    [ drop drop ]
  } case ;


: cpu-move-wb-along ( data cpu -- )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep
  [ cpu-write-byte ] keep
  PC+ ;

: cpu-move-wb-mode-seven ( data reg cpu -- )
  swap
  {
    { 0 [ drop drop ] }
    { 1 [ cpu-move-wb-along ] }
    { 4 [ >SR ] }
    [ drop drop drop ]
  } case ;



: cpu-move-wb-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ cpu-move-wb-mode-seven ] }
    [ drop drop drop drop ]
  } case ;


! Move Byte
: (opcode-1) ( cpu -- )
    break
  dup
  [ cashe>> first move-source-reg ]
  [ cashe>> first move-source-mode ] bi
  [ cpu-move-rb-ea ] keep
  [ cashe>> first move-dest-reg ] keep
  [ cashe>> first move-dest-mode ] keep
  [ cpu-move-wb-ea ] keep drop ;

: cpu-read-along ( cpu -- l )
  [ PC+ ] keep
  [ cashe>> second ] keep
  [ PC+ ] keep
  [ cashe>> third words-long ] keep
  [ cpu-read-long ] keep
  PC+ ;

: cpu-move-rl-mode-seven ( reg cpu -- d )
  swap
  {
    { 0 [ drop f ] }
    { 1 [ cpu-read-along ] }
    [ drop drop f ]
  } case ;


: cpu-move-rl-ea ( reg mode cpu -- d )
  swap
  {
    { 0 [ cpu-read-dregister ] }
    { 7 [ cpu-move-rl-mode-seven ] }
    [ drop drop drop f ]
  } case ;


: cpu-move-wl-ea ( data reg mode cpu -- )
  swap
  {
    { 0 [ cpu-write-dregister ] }
    { 1 [ cpu-write-mode-one ] }
    { 7 [ drop drop drop ] } ! cpu-wl-mode-seven ] }
    [ drop drop drop drop ]
  } case ;


! Move Long MOVE MOVEA
: (opcode-2) ( cpu -- )
    break
    [ cashe>> first move-source-reg ] keep
    [ cashe>> first move-source-mode ] keep
    [ cpu-move-rl-ea ] keep
    [ cashe>> first move-dest-reg ] keep
    [ cashe>> first move-dest-mode ] keep
    [ cpu-move-wl-ea ] keep drop ;


! Move word MOVE MOVEA
: (opcode-3) ( cpu -- )
  break
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
! RESET RTD RTR RTS
! SWAP
! TAS TRAP TRAPV TST
! UNLK
: (opcode-4) ( cpu -- )
  break
  [ cashe>> first ] keep swap
  {
    { 0x4E70 [ cpu-reset-models PC+ ] }
    [ drop drop ]
  } case ;

! ADDQ
! DBcc
! SUBQ SUBX Scc
! TRAPcc
: (opcode-5) ( cpu -- )
  break
  drop ;

! get branch condition
: branch-condition ( op -- con )
    11 8 bit-range 4 bits ;

: branch-displacement ( op -- disp )
    7 0 bit-range 8 bits ;

: cpu-word-displacement ( cpu -- )
  [ PC+ ] keep
  [ alu>> alu-n? ] keep swap
  [
    [ PC+ ] keep
    [ cashe>> second 16 >signed ] keep
    [ PC> + ] keep >PC
  ]
  [
    PC+
  ] if ;

: cpu-bmi ( cpu -- )
  [ cashe>> first branch-displacement ] keep swap
  {
    { 0 [ cpu-word-displacement ] }  ! 16 bit displacement
    [ drop drop ]   ! default is 8 bit displacement
  } case ;


! Bcc BSR BRA
: (opcode-6) ( cpu -- )
  break
  [ cashe>> first branch-condition ] keep swap
  {
    { 0 [ drop ] }  ! BRA
    { 1 [ drop ] }  ! BSR
    { 2 [ drop ] }  ! BHI
    { 3 [ drop ] }  ! BLS
    { 4 [ drop ] }  ! BCC
    { 5 [ drop ] }  ! BCS
    { 6 [ drop ] }  ! BNE
    { 7 [ drop ] }  ! BEQ
    { 8 [ drop ] }  ! BVC
    { 9 [ drop ] }  ! BVS
    { 10 [ drop ] } ! BPL
    { 11 [ cpu-bmi ] } ! BMI
    { 12 [ drop ] } ! BGE
    { 13 [ drop ] } ! BLT
    { 14 [ drop ] } ! BGT
    { 15 [ drop ] } ! BLE
    [ drop drop ]
} case ;

! MOVEQ
: (opcode-7) ( cpu -- )
  break
  drop ;

! DIV DIVS DIVL DIVU DIVUL
! OR
! SBCD
! UNPK
: (opcode-8) ( cpu -- )
  break
  drop ;

! SUB SUBA SUBX
: (opcode-9) ( cpu -- )
  break
  drop ;

! Reserved
: (opcode-A) ( cpu -- )
  break
  drop ;

! CMP CMPA CMPM
! EOR
: (opcode-B) ( cpu -- )
  break
  drop ;

! AND ABCD EXG MUL MULS MULU
: (opcode-C) ( cpu -- )
  break
  drop ;

! ADD ADDA ADDX
: (opcode-D) ( cpu -- )
  break
  drop ;

: cpu-shift-ir ( cpu -- ? )
  cashe>> first 5 bit? ;

: cpu-shift-rcount ( cpu -- reg )
  cashe>> first 11 9 bit-range 3 bits ;

: cpu-shift-dir ( cpu -- ? )
  cashe>> first 8 bit? ;

: cpu-shift-register ( cpu -- reg )
  cashe>> first 2 0 bit-range 3 bits ;

: cpu-ls-byte ( cpu -- )
  [ PC+ ] keep
  [ cpu-shift-ir ] keep swap
  [
    [ cpu-shift-rcount ] keep
    [ cpu-read-dregister ] keep
    [ cpu-shift-register ] keep
    [
      [ alu>> ] keep
      cpu-shift-dir
      [ alu>> alu-lsl-byte ] [ alu>> alu-lsr-byte ] if
    ] keep
    [ cpu-shift-register ] keep
    cpu-write-dregister
  ]
  [
    [ cpu-shift-rcount ] keep
    [ cpu-shift-register ] keep
    [
      [ alu>> ] keep
      cpu-shift-dir
      [ alu-lsl-byte ] [ alu-lsr-byte ] if
    ] keep
    [ cpu-shift-register ] keep
    cpu-write-dregister
  ] if ;

: cpu-shift-byte ( cpu -- )
  [ cashe>> first 4 3 bit-range 2 bits ] keep swap ! what function
  {
    { 0 [ drop ] }  ! Arithmatic shift
    { 1 [ cpu-ls-byte ] }  ! Logical shift
    { 2 [ drop ] }  ! Rotate with extend
    [ drop  drop ]  ! Rotate
  } case ;


: cpu-as-long ( cpu -- )
  [ PC+ ] keep
  [ cpu-shift-ir ] keep swap
  [
    [ cpu-shift-rcount ] keep
    [ cpu-read-dregister ] keep
  ]
  [
    [ cpu-shift-rcount ] keep
  ] if
  [ cpu-shift-register ] keep
  [
    [ alu>> ] keep
    cpu-shift-dir
    [ alu-asl-long ] [ alu-asr-long ] if
  ] keep
  [ cpu-shift-register ] keep
  cpu-write-dregister ;

: cpu-shift-long ( cpu -- )
  [ cashe>> first 4 3 bit-range 2 bits ] keep swap
  {
    { 0 [ cpu-as-long ] }  ! Arithmatic Shift
    { 1 [ drop ] }  ! Logical Shift
    { 2 [ drop ] }  ! Rotate with extend
    [ drop drop ]   ! Rotate
  } case ;

! Shift Rotate Bit Field
! ASR
! LSL LSR
! ROL ROR ROXL ROXR
: (opcode-E) ( cpu -- )
  break
  [ cpu-size ] keep swap
  {
    { 0 [ cpu-shift-byte ] }  ! byte
    { 1 [ drop ] }  ! word
    { 2 [ cpu-shift-long ] }  ! long
    [ drop drop ]   ! memory shift
  } case ;


! Coprocessor Interface
! cpBcc cpDBcc cpGEN cpScc cpTRAPcc
! MOVE16
: (opcode-F) ( cpu -- )
  break
  drop ;

! temp opcode
: not-implemented ( cpu -- )
  break
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
    [ alu>> alu-s-set ] keep
    [ alu>> alu-t-clr ] keep
    [ alu>> 7 swap alu-imask-write ] keep
    [ 0 ] dip [ cpu-read-long ] keep [ >A7? ] keep
    [ 4 ] dip [ cpu-read-long ] keep [ >PC? ] keep
    cpu-reset-models
    CPU-RUNNING >>state drop ;

: reset ( cpu -- )
    CPU-RESET >>state drop ;

! execute one instruction
: execute-pc-opcodes ( cpu -- )
!    [ rom-pc-read ] keep
!    [ opcodes>> nth [ break ] prepose ] keep swap call( cpu -- )
        drop
;


! execute one instruction
: execute-pc-opcode ( cpu -- )
    [ 6 swap cpu-pc-read-array ] keep [ cashe<< ] keep [ cashe>> first ] keep
    [ extract-opcode ] dip [ opcodes>> nth ] keep swap call( cpu -- )
;


! Get the cpu state
: cpu-state ( cpu -- state )
    state>> ;

! I want to know if we are in Ready to execute state
: cpu-ready? ( cpu -- ? )
    cpu-state CPU-READY = ;

: cpu-running? ( cpu -- ? )
  cpu-state CPU-RUNNING = ;


! here we process exception
: cpu-exception-execute ( cpu -- )
    dup exception>> drop drop ;

! from the instruct get the nuber of bytes
: get-nbytes ( exe -- n )
  extract-opcode nbytes-seq nth ;

! get the number of bytes for instrction in the array
: number-bytes ( array -- n )
  first get-nbytes ;

! : cpu-address-exception ( cpu -- )
!  [ exception>> ] keep swap
!  [  ]
!  [
!    [ t >>exception drop ] keep
!
!    [ f >>exception drop ] keep
!  ] if ;


! Execute one cycles
: execute-cycle ( cpu -- )
    [ dup cpu-running? ]
    [
        dup cpu-state
        {
            { CPU-RESET [ dup reset-exception ] }   ! do reset cycle
            { CPU-ADDRESS-ERROR [ dup execute-pc-opcode ] }
            { CPU-UNKNOWN [ dup reset ] }
            { CPU-RUNNING [ dup execute-pc-opcode ] }
            [ drop CPU-UNKNOWN >>state ]
        } case
    ] do until drop ;

! Reset Process
: cpu-power ( reset cpu -- )
    [ 0 swap >USP ] keep
    [ dr>> [ drop 0 ] map ] keep swap >>dr
    [ ar>> [ drop 0 ] map ] keep swap >>ar
    swap [ reset ] [ drop ] if ;

: cpu-halted ( cpu -- ? )
  doublefault>> ;

! : process ( cpu -- )
!  [ cpu-halted ] keep swap
!  [
!    [ halt>> 0 set-model ] keep
!    [ sync>> 4 set-model ] keep
!  ]
!  [
!    [ 1 swap exception ] keep
!    [
!      [ stop>> ] keep swap
!      [
!        [ irq-sample ] keep
!        [ sync>> 2 set-model ] keep
!      ]
!      [
!        [ alu>> t? ] keep swap >>trace
!        execute-pc-opcode
!      ] if
!    ] keep
!  ] if ;


: new-cpu ( cpu -- cpu' )
  new
  <alu> >>alu
  8 f <array> >>dr
  9 f <array> >>ar
  [ f swap cpu-power ] keep
  16 [ not-implemented ] <array> >>opcodes
  [ opcode-build ] keep
  f <model> >>reset
  f <exception> >>exception
  f >>doublefault
  f >>stop
  f >>trace
  f <model> >>halt
  f <model> >>sync ;

: <cpu> ( -- cpu )
  cpu new-cpu ;
